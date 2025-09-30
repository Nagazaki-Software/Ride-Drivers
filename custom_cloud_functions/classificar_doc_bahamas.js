/* eslint-disable no-console */
const { onRequest } = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const admin = require("firebase-admin");
admin.apps.length ? admin.app() : admin.initializeApp();
const { GoogleGenerativeAI } = require("@google/generative-ai");

// ----------------------- CORS -----------------------
function applyCors(req, res) {
  res.set("Access-Control-Allow-Origin", "*");
  res.set("Access-Control-Allow-Methods", "POST,OPTIONS,GET");
  res.set("Access-Control-Allow-Headers", "Content-Type, Authorization");
  if (req.method === "OPTIONS") {
    res.status(204).send("");
    return true;
  }
  return false;
}

// ----------------------- Image helpers -----------------------
const isStr = (v) => typeof v === "string";
const isHttpUrl = (s) => isStr(s) && /^https?:\/\/.+/i.test(s);
const isDataUrl = (s) => isStr(s) && /^data:image\/[a-zA-Z0-9+.\-]+;base64,/.test(s);
const isGsUrl = (s) => isStr(s) && /^gs:\/\/[^/]+\/.+/.test(s);
const isGsPath = (s) => isStr(s) && /^[^/]+\/.+/.test(s) && !/^https?:\/\//i.test(s) && !/^data:/i.test(s);
const isInlineDataObj = (o) => o && typeof o === "object" && o.inlineData && typeof o.inlineData.data === "string";
const isBase64Obj = (o) => o && typeof o === "object" && typeof o.base64 === "string"; // { base64, mimeType? }
const isBytesObj = (o) => o && typeof o === "object" && (Array.isArray(o.bytes) || Array.isArray(o.data) || Array.isArray(o.buffer));
const looksLikeImageRef = (ref) =>
  isHttpUrl(ref) || isDataUrl(ref) || isGsUrl(ref) || isGsPath(ref) || isInlineDataObj(ref) || isBase64Obj(ref) || isBytesObj(ref);

const base64FromDataUrl = (dataUrl) => dataUrl.split(",")[1];
const mimeFromDataUrl = (dataUrl) => {
  const m = dataUrl.match(/^data:(image\/[a-zA-Z0-9+.\-]+);base64,/);
  return m ? m[1] : "image/jpeg";
};

async function inlineDataFromUrl(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Falha ao baixar imagem: ${url} (HTTP ${res.status})`);
  const contentType = res.headers.get("content-type") || "image/jpeg";
  const buf = Buffer.from(await res.arrayBuffer());
  return { inlineData: { data: buf.toString("base64"), mimeType: contentType.split(";")[0] } };
}

async function inlineDataFromGs(gs) {
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
  const [meta] = await file.getMetadata().catch(() => [{ contentType: "image/jpeg" }]);
  const [buf] = await file.download();
  return { inlineData: { data: buf.toString("base64"), mimeType: (meta && meta.contentType) || "image/jpeg" } };
}

function inlineDataFromBase64Obj(obj) {
  return { inlineData: { data: obj.base64, mimeType: obj.mimeType || "image/jpeg" } };
}

function inlineDataFromBytesObj(obj) {
  const arr = obj.bytes || obj.data || obj.buffer;
  if (!Array.isArray(arr)) throw new Error("Objeto de bytes inválido.");
  const buf = Buffer.from(arr);
  return { inlineData: { data: buf.toString("base64"), mimeType: obj.mimeType || "image/jpeg" } };
}

async function toInlineData(ref) {
  if (!ref) throw new Error("Ref de imagem ausente.");
  if (isInlineDataObj(ref)) return ref;
  if (isBase64Obj(ref)) return inlineDataFromBase64Obj(ref);
  if (isBytesObj(ref)) return inlineDataFromBytesObj(ref);
  if (isDataUrl(ref)) return { inlineData: { data: base64FromDataUrl(ref), mimeType: mimeFromDataUrl(ref) } };
  if (isHttpUrl(ref)) return inlineDataFromUrl(ref);
  if (isGsUrl(ref) || isGsPath(ref)) return inlineDataFromGs(ref);
  throw new Error("Ref de imagem inválida. Use https, dataURL, gs://, {base64,mimeType}, {inlineData}, ou {bytes,mimeType}.");
}

// ----------------------- Gemini classification -----------------------
async function classifySingleImage(imageRef, apiKey, modelName = "gemini-1.5-pro") {
  const genAI = new GoogleGenerativeAI(apiKey);
  const model = genAI.getGenerativeModel({
    model: modelName,
    systemInstruction: "Você é um classificador de documentos. Responda apenas JSON válido.",
  });

  const prompt = `Classifique o documento na imagem e responda SOMENTE JSON válido:
{
  "type": "driver_license|taxi_license|insurance|vehicle_registration|other",
  "countryLikely": string|null,
  "confidence": number, // 0..1
  "reason": string
}`;

  const parts = [{ text: prompt }, await toInlineData(imageRef)];
  const result = await model.generateContent({
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
  parsed = parsed || {};
  parsed.type = parsed.type || "other";
  parsed.countryLikely = parsed.countryLikely || null;
  parsed.confidence = typeof parsed.confidence === "number" ? parsed.confidence : 0;
  parsed.reason = parsed.reason || "";
  return parsed;
}

// ----------------------- Gen2 HTTP function -----------------------
exports.classificarDocBahamas = onRequest(
  { region: "us-central1", timeoutSeconds: 60, memory: "256MiB" },
  async (req, res) => {
    if (applyCors(req, res)) return;

    if (req.method === "GET") {
      return res.status(200).json({ ok: true, msg: "classificarDocBahamas up" });
    }
    if (req.method !== "POST") {
      res.set("Allow", "POST,OPTIONS,GET");
      return res.status(405).send("Method Not Allowed");
    }

    try {
      let body = req.body;
      if (typeof body === "string") {
        try { body = JSON.parse(body); } catch {}
      }
      const data = body && typeof body === "object" ? (body.data ?? body) : {};

      const img = data?.image;
      const minConfidence = typeof data?.minConfidence === "number" ? data.minConfidence : 0.7;
      const model = data?.model || "gemini-1.5-pro"; // pode usar "gemini-1.5-flash" por custo/latência

      if (!looksLikeImageRef(img)) {
        return res.status(400).json({
          ok: false,
          errors: [
            "Campo 'image' ausente ou inválido. Envie https, dataURL, gs://, {base64,mimeType}, {inlineData}, ou {bytes,mimeType}.",
          ],
        });
      }

      const apiKey = process.env.GEMINI_API_KEY || "";
      if (!apiKey) {
        return res.status(500).json({ ok: false, errors: ["GEMINI_API_KEY não configurada."] });
      }

      const out = await classifySingleImage(img, apiKey, model);
      const isBahamasDoc = out.type !== "other" && out.countryLikely === "Bahamas";
      const meetsConfidence = out.confidence >= minConfidence;
      const accepted = isBahamasDoc && meetsConfidence;
      const http = accepted ? 200 : 422;

      return res.status(http).json({ ok: accepted, accepted, minConfidence, result: out });
    } catch (e) {
      logger.error(e);
      return res.status(500).json({ ok: false, errors: [`Falha ao classificar: ${e && e.message ? e.message : String(e)}`] });
    }
  },
);

