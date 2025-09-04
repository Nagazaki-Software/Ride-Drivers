import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'driver_profile_widget.dart' show DriverProfileWidget;
import 'package:flutter/material.dart';

class DriverProfileModel extends FlutterFlowModel<DriverProfileWidget> {
  ///  Local state fields for this page.

  String driverRewards = 'All';

  ///  State fields for stateful widgets in this page.

  // Model for navbar component.
  late NavbarModel navbarModel;

  @override
  void initState(BuildContext context) {
    navbarModel = createModel(context, () => NavbarModel());
  }

  @override
  void dispose() {
    navbarModel.dispose();
  }
}
