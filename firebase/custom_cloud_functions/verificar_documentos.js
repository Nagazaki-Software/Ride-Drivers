/* eslint-disable no-console */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.apps.length ? admin.app() : admin.initializeApp(); // precisamos de Storage
const { GoogleGenerativeAI } = require("@google/generative-ai");

// ----------------------- Utils: tipos/refs -----------------------
const isStr = (v) => typeof v === "string";
const isHttpUrl = (s) => isStr(s) && /^https?:\/\/.+/i.test(s);
const isDataUrl = (s) =>
  isStr(s) && /^data:image\/[a-zA-Z0-9+.\-]+;base64,/.test(s);
const isGsUrl = (s) => isStr(s) && /^gs:\/\/[^/]+\/.+/.test(s);
const isGsPath = (s) =>
  isStr(s) &&
  /^[^/]+\/.+/.test(s) &&
  !/^https?:\/\//i.test(s) &&
  !/^data:/i.test(s);

const isInlineDataObj = (o) =>
  o &&
  typeof o === "object" &&
  o.inlineData &&
  typeof o.inlineData.data === "string";
const isBase64Obj = (o) =>
  o && typeof o === "object" && typeof o.base64 === "string"; // { base64, mimeType? }
const isBytesObj = (o) =>
  o &&
  typeof o === "object" &&
  (Array.isArray(o.bytes) || Array.isArray(o.data) || Array.isArray(o.buffer));

const looksLikeImageRef = (ref) =>
  isHttpUrl(ref) ||
  isDataUrl(ref) ||
  isGsUrl(ref) ||
  isGsPath(ref) ||
  isInlineDataObj(ref) ||
  isBase64Obj(ref) ||
  isBytesObj(ref);

// ----------------------- Datas e vencimentos -----------------------
const toDate = (d) => {
  if (!d) return null;
  if (d instanceof Date && !isNaN(d)) return d;
  const x = new Date(String(d));
  return isNaN(x) ? null : x;
};
const isExpired = (exp, now = new Date()) =>
  !(exp instanceof Date) || exp.getTime() <= now.getTime();

// ----------------------- Helpers imagem -----------------------
const base64FromDataUrl = (dataUrl) => dataUrl.split(",")[1];
const mimeFromDataUrl = (dataUrl) => {
  const m = dataUrl.match(/^data:(image\/[a-zA-Z0-9+.\-]+);base64,/);
  return m ? m[1] : "image/jpeg";
};

async function inlineDataFromUrl(url) {
  const res = await fetch(url); // Node 18+
  if (!res.ok)
    throw new Error(`Falha ao baixar imagem: ${url} (HTTP ${res.status})`);
  const contentType = res.headers.get("content-type") || "image/jpeg";
  const buf = Buffer.from(await res.arrayBuffer());
  return {
    inlineData: {
      data: buf.toString("base64"),
      mimeType: contentType.split(";")[0],
    },
  };
}

async function inlineDataFromGs(gs) {
  // Aceita "gs://bucket/path" OU "bucket/path"
  let bucketName, filePath;
  if (isGsUrl(gs)) {
    const u = new URL(gs);
    bucketName = u.host;
    filePath = u.pathname.replace(/^\//, "");
  } else {
    const parts = gs.split("/");
    bucketName = parts.shift();
    filePath = parts.join("/");
  }
  const bucket = admin.storage().bucket(bucketName);
  const file = bucket.file(filePath);
  const [exists] = await file.exists();
  if (!exists) throw new Error(`GCS: arquivo não existe: ${gs}`);
  const [meta] = await file
    .getMetadata()
    .catch(() => [{ contentType: "image/jpeg" }]);
  const [buf] = await file.download();
  return {
    inlineData: {
      data: buf.toString("base64"),
      mimeType: (meta && meta.contentType) || "image/jpeg",
    },
  };
}

function inlineDataFromBase64Obj(obj) {
  return {
    inlineData: { data: obj.base64, mimeType: obj.mimeType || "image/jpeg" },
  };
}

function inlineDataFromBytesObj(obj) {
  const arr = obj.bytes || obj.data || obj.buffer;
  if (!Array.isArray(arr)) throw new Error("Objeto de bytes inválido.");
  const buf = Buffer.from(arr);
  return {
    inlineData: {
      data: buf.toString("base64"),
      mimeType: obj.mimeType || "image/jpeg",
    },
  };
}

// Converte QUALQUER entrada suportada para { inlineData:{data,mimeType} }
async function toInlineData(ref) {
  if (!ref) throw new Error("Ref de imagem ausente.");
  if (isInlineDataObj(ref)) return ref;
  if (isBase64Obj(ref)) return inlineDataFromBase64Obj(ref);
  if (isBytesObj(ref)) return inlineDataFromBytesObj(ref);
  if (isDataUrl(ref))
    return {
      inlineData: {
        data: base64FromDataUrl(ref),
        mimeType: mimeFromDataUrl(ref),
      },
    };
  if (isHttpUrl(ref)) return inlineDataFromUrl(ref);
  if (isGsUrl(ref) || isGsPath(ref)) return inlineDataFromGs(ref);
  throw new Error(
    "Ref de imagem inválida. Use https, dataURL, gs://, {base64,mimeType}, {inlineData}, ou {bytes,mimeType}.",
  );
}

// ----------------------- Checagens locais -----------------------
function localChecks(payload, now) {
  const errors = [];
  const insuranceImg = payload.insurance || payload.insurence;
  const insuranceExp =
    payload.insuranceExpiration || payload.insurenceExpiration;

  if (!looksLikeImageRef(payload.driverLicense))
    errors.push("driverLicense ausente/ inválido (imagem).");
  if (!looksLikeImageRef(insuranceImg))
    errors.push("insurance/insurence ausente/ inválido (imagem).");
  if (!looksLikeImageRef(payload.vehicleRegistration))
    errors.push("vehicleRegistration ausente/ inválido (imagem).");

  const photos = Array.isArray(payload.vehiclePhotos)
    ? payload.vehiclePhotos
    : [];
  if (photos.length === 0)
    errors.push("vehiclePhotos vazio; inclua ao menos 1 foto do veículo.");
  else if (photos.some((p) => !looksLikeImageRef(p)))
    errors.push("Há refs inválidas em vehiclePhotos.");

  const expLicense = toDate(payload.expirationLicense);
  const expTaxi = payload.taxiLicense
    ? toDate(payload.taxiLicenseExpiration)
    : null;
  const expInsurance = toDate(insuranceExp);
  const expVehicle = toDate(payload.vehicleExpiration);

  if (!expLicense) errors.push("expirationLicense ausente/ inválida.");
  if (payload.taxiLicense && !expTaxi)
    errors.push("taxiLicenseExpiration ausente/ inválida.");
  if (!expInsurance)
    errors.push("insuranceExpiration/insurenceExpiration ausente/ inválida.");
  if (!expVehicle) errors.push("vehicleExpiration ausente/ inválida.");

  if (expLicense && isExpired(expLicense, now))
    errors.push("CNH expirada hoje.");
  if (expTaxi && isExpired(expTaxi, now))
    errors.push("Licença de táxi expirada hoje.");
  if (expInsurance && isExpired(expInsurance, now))
    errors.push("Seguro expirado hoje.");
  if (expVehicle && isExpired(expVehicle, now))
    errors.push("CRLV expirado hoje.");

  return errors;
}

// ----------------------- Chamada Gemini -----------------------
async function callGemini(payload, apiKey, model = "gemini-1.5-flash") {
  const genAI = new GoogleGenerativeAI(apiKey);
  const modelClient = genAI.getGenerativeModel({
    model,
    systemInstruction:
      "Você é um verificador de conformidade de documentos (Bahamas). Responda SOMENTE JSON válido.",
  });

  const insuranceImg = payload.insurance || payload.insurence;
  const insuranceExp =
    payload.insuranceExpiration || payload.insurenceExpiration;

  const nowISO = new Date().toISOString();
  const prompt = `Tarefa: validar pacote de documentos de motorista.
Agora (UTC): ${nowISO}

Regras:
1) Classifique cada imagem: CNH, Licença de Táxi (se houver), Apólice/Seguro, CRLV, Fotos do veículo.
2) Se possível, extraia datas de vencimento visíveis.
3) Aponte sinais fortes de adulteração.
4) Verifique coerência (mesma pessoa/veículo/placa).
5) Compare os vencimentos informados com os visíveis.
6) Retorne SOMENTE JSON com o formato:

{
  "ok": boolean,
  "errors": string[],
  "classification": {
    "driverLicense": { "looksCorrect": boolean, "visibleExpiration": string|null, "reason": string },
    "taxiLicense": { "looksCorrect": boolean, "visibleExpiration": string|null, "reason": string } | null,
    "insurance": { "looksCorrect": boolean, "visibleExpiration": string|null, "reason": string },
    "vehicleRegistration": { "looksCorrect": boolean, "visibleExpiration": string|null, "reason": string },
    "vehiclePhotos": { "count": number, "lookLikeVehicle": boolean, "reason": string }
  },
  "consistency": {
    "samePersonLikely": boolean | null,
    "sameVehicleLikely": boolean | null,
    "notes": string
  }
}

Vencimentos informados:
- expirationLicense: ${String(payload.expirationLicense)}
- taxiLicenseExpiration: ${String(payload.taxiLicense ? payload.taxiLicenseExpiration : null)}
- insuranceExpiration: ${String(insuranceExp)}
- vehicleExpiration: ${String(payload.vehicleExpiration)}
`;

  const parts = [{ text: prompt }];
  if (payload.driverLicense)
    parts.push(await toInlineData(payload.driverLicense));
  if (payload.taxiLicense) parts.push(await toInlineData(payload.taxiLicense));
  if (insuranceImg) parts.push(await toInlineData(insuranceImg));
  if (payload.vehicleRegistration)
    parts.push(await toInlineData(payload.vehicleRegistration));
  if (Array.isArray(payload.vehiclePhotos)) {
    for (const p of payload.vehiclePhotos.slice(0, 6))
      parts.push(await toInlineData(p));
  }

  const result = await modelClient.generateContent({
    contents: [{ role: "user", parts }],
    generationConfig: { responseMimeType: "application/json", temperature: 0 },
  });

  const raw =
    result.response?.text?.() ||
    result.response?.candidates?.[0]?.content?.parts?.[0]?.text ||
    "";
  if (!raw) throw new Error("Resposta vazia do Gemini.");

  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    throw new Error("Gemini não retornou JSON válido.");
  }

  if (typeof parsed.ok !== "boolean")
    throw new Error("JSON fora do esquema esperado.");
  return parsed;
}

// ----------------------- Núcleo reutilizável -----------------------
async function verificarCore(data) {
  const now = new Date();
  const localErrors = localChecks(data, now);
  if (localErrors.length) return { ok: false, error: localErrors.join(" ") };

  const apiKey = process.env.GEMINI_API_KEY || "SUA_GEMINI_API_KEY_AQUI";
  if (!apiKey) return { ok: false, error: "GEMINI_API_KEY não configurada." };

  try {
    const ai = await callGemini(data, apiKey, "gemini-1.5-flash");
    if (!ai.ok) {
      const msg =
        Array.isArray(ai.errors) && ai.errors.length
          ? ai.errors.join(" ")
          : "Falha na verificação visual.";
      return { ok: false, error: msg };
    }
    return { ok: true, error: null };
  } catch (err) {
    console.error(err);
    return {
      ok: false,
      error: `Erro ao chamar Gemini: ${err.message || String(err)}`,
    };
  }
}

exports.verificarDocumentos = functions.https.onCall(async (data, context) => {
  // if (!context.auth) return { ok:false, error:"Não autenticado." };
  return verificarCore(data);
});

// ----------------------- HTTP espelho (para API Call/Postman) ---------
exports.verificarDocumentosHttp = functions.https.onRequest(
  async (req, res) => {
    if (req.method !== "POST") {
      res.set("Allow", "POST");
      return res.status(405).send("Method Not Allowed");
    }
    try {
      const body = req.body && typeof req.body === "object" ? req.body : {};
      const data = body.data ?? body; // aceita {data:{...}} ou {...}
      const result = await verificarCore(data);
      return res.status(200).json(result);
    } catch (e) {
      console.error(e);
      return res.status(500).json({ ok: false, error: "Falha inesperada." });
    }
  },
);
