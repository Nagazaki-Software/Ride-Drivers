// Automatic FlutterFlow imports
import '/backend/backend.dart';
import '/actions/actions.dart' as action_blocks;
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
import 'package:flutter/material.dart';
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

import 'dart:async';

StreamController<int>? _controller;
Timer? _timer;
int _counter = 0;

/// Inicia um loop que gera inteiros até 35 enquanto o usuário estiver
/// segurando.
Future<int> loopNumber() async {
  // Cancela qualquer loop anterior
  await stopLoop();

  _controller = StreamController<int>.broadcast();
  _counter = 0;

  // Cria um loop que incrementa a cada 300ms (ajuste conforme quiser)
  _timer = Timer.periodic(const Duration(milliseconds: 300), (timer) {
    if (_counter < 35) {
      _counter++;
      _controller?.add(_counter);
    } else {
      // Para automaticamente ao chegar em 35
      stopLoop();
    }
  });

  // Retorna o primeiro valor (obrigatório pelo FlutterFlow)
  return _counter;
}

/// Para o loop quando o usuário soltar ou chegar em 35.
Future<void> stopLoop() async {
  _timer?.cancel();
  _timer = null;
  await _controller?.close();
  _controller = null;
}
