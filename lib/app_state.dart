import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _valueDailyGoal = prefs.getInt('ff_valueDailyGoal') ?? _valueDailyGoal;
    });
    _safeInit(() {
      _ridesDailyGoal = prefs.getInt('ff_ridesDailyGoal') ?? _ridesDailyGoal;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  String _navbarpags = '';
  String get navbarpags => _navbarpags;
  set navbarpags(String value) {
    _navbarpags = value;
  }

  int _valueDailyGoal = 0;
  int get valueDailyGoal => _valueDailyGoal;
  set valueDailyGoal(int value) {
    _valueDailyGoal = value;
    prefs.setInt('ff_valueDailyGoal', value);
  }

  int _ridesDailyGoal = 0;
  int get ridesDailyGoal => _ridesDailyGoal;
  set ridesDailyGoal(int value) {
    _ridesDailyGoal = value;
    prefs.setInt('ff_ridesDailyGoal', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}
