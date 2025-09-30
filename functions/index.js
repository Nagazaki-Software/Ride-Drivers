/* eslint-disable no-console */
const { onCall, HttpsError } = require("firebase-functions/v2/https");
const functionsV1 = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const braintree = require("braintree");

// Sandbox (test) credentials
const K_TEST_MERCHANT_ID = "brg8dhjg5tqpw496";
const K_TEST_PUBLIC_KEY = "syt9g3c79t58wk82";
const K_TEST_PRIVATE_KEY = "0f7de713fa2bbb810f183f628f51d86d";

// Production credentials (for Gen2, prefer Cloud Run env vars)
const K_PROD_MERCHANT_ID = process.env.BRAINTREE_PROD_MERCHANT_ID || "";
const K_PROD_PUBLIC_KEY = process.env.BRAINTREE_PROD_PUBLIC_KEY || "";
const K_PROD_PRIVATE_KEY = process.env.BRAINTREE_PROD_PRIVATE_KEY || "";

function getGateway(isProd) {
  return new braintree.BraintreeGateway({
    environment: isProd
      ? braintree.Environment.Production
      : braintree.Environment.Sandbox,
    merchantId: isProd ? K_PROD_MERCHANT_ID : K_TEST_MERCHANT_ID,
    publicKey: isProd ? K_PROD_PUBLIC_KEY : K_TEST_PUBLIC_KEY,
    privateKey: isProd ? K_PROD_PRIVATE_KEY : K_TEST_PRIVATE_KEY,
  });
}

async function ensureCustomer(gateway, customerId, email) {
  try {
    return await gateway.customer.find(customerId);
  } catch (_) {
    const res = await gateway.customer.create({ id: customerId, email });
    if (!res.success)
      throw new Error(res.message || "Falha ao criar customer");
    return res.customer;
  }
}

function isPassInstrument(method) {
  const instr = (method && method.paymentInstrumentType
    ? method.paymentInstrumentType
    : "").toLowerCase();
  const ctype = (method && method.cardType ? method.cardType : "").toLowerCase();
  return (
    instr.indexOf("apple_pay") >= 0 ||
    instr.indexOf("android_pay") >= 0 ||
    instr.indexOf("google_pay") >= 0 ||
    ctype.indexOf("apple pay") >= 0 ||
    ctype.indexOf("android pay") >= 0 ||
    ctype.indexOf("google pay") >= 0
  );
}

function methodMetaFF(method) {
  if (method && method.cardType && method.last4) {
    return {
      token: method.token,
      paymentMethodToken: method.token,
      brand: method.cardType,
      last4: method.last4,
      last4Numbers: method.last4,
      type: "card",
      default: !!method.default,
      isDefault: !!method.default,
      pass: isPassInstrument(method),
    };
  }
  if (method && method.email) {
    return {
      token: method.token,
      paymentMethodToken: method.token,
      brand: "PayPal",
      last4: method.email,
      last4Numbers: method.email,
      type: "paypal",
      default: !!method.default,
      isDefault: !!method.default,
      pass: false,
    };
  }
  return {
    token: method && method.token,
    paymentMethodToken: method && method.token,
    brand: "PaymentMethod",
    last4: "****",
    last4Numbers: "****",
    type: "unknown",
    default: !!(method && method.default),
    isDefault: !!(method && method.default),
    pass: false,
  };
}

// Charge using a payment nonce and return the vaulted payment method metadata
exports.payAndReturnPaymentMethod = onCall(
  { region: "us-central1", timeoutSeconds: 60, memory: "256MiB" },
  async (request) => {
    const data = request.data || {};
    const context = request;
    if (!context.auth) {
      throw new HttpsError("unauthenticated", "Faca login primeiro.");
    }
    const { amount, paymentNonce, deviceData, isProd = false, makeDefault } =
      data || {};
    if (amount == null || paymentNonce == null) {
      throw new HttpsError(
        "invalid-argument",
        "amount e paymentNonce sao obrigatorios.",
      );
    }

    const amtStr =
      typeof amount === "string" ? amount : Number(amount).toFixed(2);

    const uid = context.auth.uid;
    const email = context.auth.token && context.auth.token.email;
    const gateway = getGateway(isProd);

    await ensureCustomer(gateway, uid, email);
    let existingCount = 0;
    try {
      const found = await gateway.customer.find(uid);
      existingCount = Array.isArray(found && found.paymentMethods)
        ? found.paymentMethods.length
        : 0;
    } catch (_) {}

    const pmRes = await gateway.paymentMethod.create({
      customerId: uid,
      paymentMethodNonce: paymentNonce,
      deviceData,
      options: {
        verifyCard: true,
        makeDefault:
          makeDefault !== undefined ? !!makeDefault : existingCount === 0,
      },
    });

    if (!pmRes.success) {
      throw new HttpsError(
        "failed-precondition",
        pmRes.message || "Falha ao vaultar metodo de pagamento.",
      );
    }

    const pm = pmRes.paymentMethod;
    const meta = methodMetaFF(pm);

    const saleRes = await gateway.transaction.sale({
      amount: amtStr,
      paymentMethodToken: pm.token,
      deviceData,
      options: { submitForSettlement: true },
    });

    if (!saleRes.success) {
      return {
        success: false,
        error: saleRes.message || "Erro ao processar pagamento.",
        paymentMethod: meta,
      };
    }

    return {
      success: true,
      transactionId: saleRes.transaction.id,
      paymentMethod: meta,
    };
  },
);

// Vault a card (no charge)
exports.saveCardPayment = onCall(
  { region: "us-central1", timeoutSeconds: 60, memory: "256MiB" },
  async (request) => {
    const data = request.data || {};
    const context = request;
    if (!context.auth) {
      throw new HttpsError("unauthenticated", "Faca login primeiro.");
    }
    const { paymentNonce, deviceData, isProd = false, makeDefault } = data || {};
    if (!paymentNonce) {
      throw new HttpsError(
        "invalid-argument",
        "paymentNonce e obrigatorio.",
      );
    }

    try {
      const uid = context.auth.uid;
      const email = context.auth.token && context.auth.token.email;
      const gateway = getGateway(isProd);

      await ensureCustomer(gateway, uid, email);
      let existingCount = 0;
      try {
        const found = await gateway.customer.find(uid);
        existingCount = Array.isArray(found && found.paymentMethods)
          ? found.paymentMethods.length
          : 0;
      } catch (_) {}

      const res = await gateway.paymentMethod.create({
        customerId: uid,
        paymentMethodNonce: paymentNonce,
        deviceData,
        options: {
          verifyCard: true,
          makeDefault:
            makeDefault !== undefined ? !!makeDefault : existingCount === 0,
        },
      });

      if (!res.success) {
        return { success: false, error: res.message || "Falha ao salvar metodo." };
      }

      const meta = methodMetaFF(res.paymentMethod);
      return { success: true, paymentMethod: meta };
    } catch (e) {
      const msg = (e && e.message) || String(e);
      console.warn("[saveCardPayment] error:", msg);
      return { success: false, error: msg };
    }
  },
);

// Charge with a saved payment method token
exports.payWithSavedPaymentMethod = onCall(
  { region: "us-central1", timeoutSeconds: 60, memory: "256MiB" },
  async (request) => {
    const data = request.data || {};
    const context = request;
    if (!context.auth) {
      throw new HttpsError("unauthenticated", "Faca login primeiro.");
    }
    const { amount, paymentMethodToken, deviceData, isProd = false } =
      data || {};
    if (amount == null || !paymentMethodToken) {
      throw new HttpsError(
        "invalid-argument",
        "amount e paymentMethodToken sao obrigatorios.",
      );
    }

    const amtStr =
      typeof amount === "string" ? amount : Number(amount).toFixed(2);
    const gateway = getGateway(isProd);

    const saleRes = await gateway.transaction.sale({
      amount: amtStr,
      paymentMethodToken,
      deviceData,
      options: { submitForSettlement: true },
    });

    if (!saleRes.success) {
      return {
        success: false,
        error: saleRes.message || "Erro ao processar pagamento.",
      };
    }

    return { success: true, transactionId: saleRes.transaction.id };
  },
);

// Apply subscription: updates user ridePoints and expiration
const { Timestamp, FieldValue } = admin.firestore;
exports.applySubscription = onCall(
  { region: "us-central1", timeoutSeconds: 30, memory: "256MiB" },
  async (request) => {
    const data = request.data || {};
    const context = request;
    if (!context.auth) {
      throw new HttpsError("unauthenticated", "Faca login primeiro.");
    }
    const { tier, period = "Monthly" } = data;
    if (!tier || (tier !== "Silver" && tier !== "Gold" && tier !== "silver" && tier !== "gold")) {
      throw new HttpsError("invalid-argument", "tier deve ser Silver ou Gold");
    }
    const normTier = tier.toLowerCase();
    const points = normTier === "gold" ? 500000 : 250000;
    const normPeriod = (period || "Monthly").toLowerCase();
    const days = normPeriod === "weekly" ? 7 : 30;
    const now = new Date();
    const expiresAt = new Date(now.getTime() + days * 24 * 60 * 60 * 1000);

    const uid = context.auth.uid;
    const userRef = admin.firestore().collection("users").doc(uid);

    await userRef.set(
      {
        ridePoints: points,
        subscription: {
          tier: normTier, // 'silver' | 'gold'
          period: normPeriod, // 'weekly' | 'monthly'
          expiresAt: Timestamp.fromDate(expiresAt),
          updatedAt: FieldValue.serverTimestamp(),
        },
      },
      { merge: true },
    );

    return {
      success: true,
      ridePoints: points,
      expiresAt: expiresAt.toISOString(),
      tier: normTier,
      period: normPeriod,
    };
  },
);

// Scheduled task: reset ridePoints to 0 when subscription expires
const { onSchedule } = require("firebase-functions/v2/scheduler");
exports.expireSubscriptions = onSchedule(
  { schedule: "every 24 hours", timeZone: "America/Nassau" },
  async () => {
    const db = admin.firestore();
    const nowTs = Timestamp.now();
    const batchSize = 500;
    let processed = 0;
    const usersCol = db.collection("users");
    let query = usersCol
      .where("subscription.expiresAt", "<=", nowTs)
      .where("ridePoints", ">", 0)
      .limit(batchSize);

    while (true) {
      const snap = await query.get();
      if (snap.empty) break;
      const batch = db.batch();
      snap.docs.forEach((doc) => {
        batch.set(
          doc.ref,
          {
            ridePoints: 0,
            subscription: {
              // keep tier/period for reference, just mark expired
              expiresAt: doc.get("subscription.expiresAt") || nowTs,
              expiredAt: nowTs,
              updatedAt: FieldValue.serverTimestamp(),
            },
          },
          { merge: true },
        );
      });
      await batch.commit();
      processed += snap.size;
      if (snap.size < batchSize) break; // done
    }
    return { success: true, processed };
  },
);

// Gen2 Identity trigger to cleanup Firestore user
exports.onUserDeleted = functionsV1.auth.user().onDelete(async (user) => {
  const firestore = admin.firestore();
  await firestore.collection("users").doc(user.uid).delete();
});
