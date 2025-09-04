import '/backend/api_requests/api_calls.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import 'taxi_onboarding_widget.dart' show TaxiOnboardingWidget;
import 'package:flutter/material.dart';

class TaxiOnboardingModel extends FlutterFlowModel<TaxiOnboardingWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadData5f23 = false;
  FFUploadedFile uploadedLocalFile_uploadData5f23 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadData5f23 = '';

  DateTime? datePicked1;
  bool isDataUploading_uploadDataIv9 = false;
  FFUploadedFile uploadedLocalFile_uploadDataIv9 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataIv9 = '';

  DateTime? datePicked2;
  bool isDataUploading_uploadDataGh8 = false;
  FFUploadedFile uploadedLocalFile_uploadDataGh8 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataGh8 = '';

  DateTime? datePicked3;
  bool isDataUploading_uploadData049 = false;
  FFUploadedFile uploadedLocalFile_uploadData049 =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadData049 = '';

  DateTime? datePicked4;
  bool isDataUploading_uploadDataSr0 = false;
  List<FFUploadedFile> uploadedLocalFiles_uploadDataSr0 = [];
  List<String> uploadedFileUrls_uploadDataSr0 = [];

  // Stores action output result for [Backend Call - API (verificarDocument AI)] action in Container widget.
  ApiCallResponse? verificarDocumentsWithAI;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {}
}
