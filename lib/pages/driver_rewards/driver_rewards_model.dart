import '/components/navbar_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'driver_rewards_widget.dart' show DriverRewardsWidget;
import 'package:flutter/material.dart';

class DriverRewardsModel extends FlutterFlowModel<DriverRewardsWidget> {
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
