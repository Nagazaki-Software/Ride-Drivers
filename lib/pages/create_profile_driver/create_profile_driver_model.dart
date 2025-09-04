import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import '/index.dart';
import 'create_profile_driver_widget.dart' show CreateProfileDriverWidget;
import 'package:flutter/material.dart';

class CreateProfileDriverModel
    extends FlutterFlowModel<CreateProfileDriverWidget> {
  ///  State fields for stateful widgets in this page.

  bool isDataUploading_uploadDataJdh = false;
  FFUploadedFile uploadedLocalFile_uploadDataJdh =
      FFUploadedFile(bytes: Uint8List.fromList([]));
  String uploadedFileUrl_uploadDataJdh = '';

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;
  // State field(s) for TextFieldEmail widget.
  FocusNode? textFieldEmailFocusNode;
  TextEditingController? textFieldEmailTextController;
  String? Function(BuildContext, String?)?
      textFieldEmailTextControllerValidator;
  // State field(s) for TextFieldPassword widget.
  FocusNode? textFieldPasswordFocusNode;
  TextEditingController? textFieldPasswordTextController;
  late bool textFieldPasswordVisibility;
  String? Function(BuildContext, String?)?
      textFieldPasswordTextControllerValidator;
  // State field(s) for TextFieldExperience widget.
  FocusNode? textFieldExperienceFocusNode;
  TextEditingController? textFieldExperienceTextController;
  late bool textFieldExperienceVisibility;
  String? Function(BuildContext, String?)?
      textFieldExperienceTextControllerValidator;
  // State field(s) for TextFieldVeichleDrive widget.
  FocusNode? textFieldVeichleDriveFocusNode;
  TextEditingController? textFieldVeichleDriveTextController;
  late bool textFieldVeichleDriveVisibility;
  String? Function(BuildContext, String?)?
      textFieldVeichleDriveTextControllerValidator;
  // State field(s) for DropDown widget.
  String? dropDownValue1;
  FormFieldController<String>? dropDownValueController1;
  // State field(s) for DropDown widget.
  String? dropDownValue2;
  FormFieldController<String>? dropDownValueController2;
  // State field(s) for DropDown widget.
  String? dropDownValue3;
  FormFieldController<String>? dropDownValueController3;
  // State field(s) for DropDown widget.
  String? dropDownValue4;
  FormFieldController<String>? dropDownValueController4;
  // State field(s) for DropDown widget.
  String? dropDownValue5;
  FormFieldController<String>? dropDownValueController5;

  @override
  void initState(BuildContext context) {
    textFieldPasswordVisibility = false;
    textFieldExperienceVisibility = false;
    textFieldVeichleDriveVisibility = false;
  }

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();

    textFieldEmailFocusNode?.dispose();
    textFieldEmailTextController?.dispose();

    textFieldPasswordFocusNode?.dispose();
    textFieldPasswordTextController?.dispose();

    textFieldExperienceFocusNode?.dispose();
    textFieldExperienceTextController?.dispose();

    textFieldVeichleDriveFocusNode?.dispose();
    textFieldVeichleDriveTextController?.dispose();
  }
}
