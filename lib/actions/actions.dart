import '/auth/firebase_auth/auth_util.dart';
import '/custom_code/actions/index.dart' as actions;
import 'package:flutter/material.dart';

Future userGetLocation(BuildContext context) async {
  await actions.locationPinger(
    currentUserReference!,
    6000,
  );
}
