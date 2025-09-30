const admin = require("firebase-admin/app");
admin.initializeApp();

const verificarDocumentos = require("./verificar_documentos.js");
// Use Gen2 HTTP version that also persists to Firestore
exports.verificarDocumentos = verificarDocumentos.verificarDocumentosV2;
const classificarDocBahamas = require("./classificar_doc_bahamas.js");
exports.classificarDocBahamas = classificarDocBahamas.classificarDocBahamas;
