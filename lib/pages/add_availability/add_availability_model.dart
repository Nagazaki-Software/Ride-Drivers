import '/flutter_flow/flutter_flow_util.dart';
import 'add_availability_widget.dart' show AddAvailabilityWidget;
import 'package:flutter/material.dart';

class AddAvailabilityModel extends FlutterFlowModel<AddAvailabilityWidget> {
  ///  Local state fields for this page.

  List<String> repeatOn = ['segunda', 'quarta'];
  void addToRepeatOn(String item) => repeatOn.add(item);
  void removeFromRepeatOn(String item) => repeatOn.remove(item);
  void removeAtIndexFromRepeatOn(int index) => repeatOn.removeAt(index);
  void insertAtIndexInRepeatOn(int index, String item) =>
      repeatOn.insert(index, item);
  void updateRepeatOnAtIndex(int index, Function(String) updateFn) =>
      repeatOn[index] = updateFn(repeatOn[index]);

  List<String> allowRides = ['Local • App Fare'];
  void addToAllowRides(String item) => allowRides.add(item);
  void removeFromAllowRides(String item) => allowRides.remove(item);
  void removeAtIndexFromAllowRides(int index) => allowRides.removeAt(index);
  void insertAtIndexInAllowRides(int index, String item) =>
      allowRides.insert(index, item);
  void updateAllowRidesAtIndex(int index, Function(String) updateFn) =>
      allowRides[index] = updateFn(allowRides[index]);

  ///  State fields for stateful widgets in this page.

  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode1;
  TextEditingController? textController1;
  String? Function(BuildContext, String?)? textController1Validator;
  // State field(s) for TextField widget.
  FocusNode? textFieldFocusNode2;
  TextEditingController? textController2;
  String? Function(BuildContext, String?)? textController2Validator;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    textFieldFocusNode1?.dispose();
    textController1?.dispose();

    textFieldFocusNode2?.dispose();
    textController2?.dispose();
  }
}
