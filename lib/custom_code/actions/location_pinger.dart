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
import 'package:cloud_firestore/cloud_firestore.dart'
    show DocumentReference, FieldValue, GeoPoint, SetOptions;
import 'package:geolocator/geolocator.dart';

/// Mantemos a assinatura POSICIONAL p/ o FlutterFlow não quebrar.
/// Registre os parâmetros nessa mesma ordem no painel da Action.
StreamSubscription<Position>? _posSub;

/// Inicia rastreamento contínuo e envia localização ao Firestore a cada X segundos.
///
/// Parâmetros (POSICIONAIS!):
/// - [userDocRef] (DocumentReference) -> doc do usuário para atualizar
/// - [intervalSeconds] (int?, opcional) -> intervalo em segundos (default interno = 5)
Future locationPinger(
  DocumentReference userDocRef,
  int? intervalSeconds,
) async {
  // Cancela listener antigo, se existir
  await _posSub?.cancel();
  _posSub = null;

  final int tick = (intervalSeconds ?? 5);
  final int safeTick = tick < 1 ? 1 : (tick > 60 ? 60 : tick);
  final Duration gate = Duration(seconds: safeTick);

  // Checa serviço
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Serviço de localização está desligado.');
  }

  // Permissões
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Permissão de localização negada.');
  }

  // Stream de posição
  final positionStream = Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0, // emite mesmo sem deslocamento
    ),
  );

  DateTime lastSent = DateTime.fromMillisecondsSinceEpoch(0);

  _posSub = positionStream.listen((pos) async {
    final now = DateTime.now();
    if (now.difference(lastSent) < gate) return;
    lastSent = now;

    try {
      await userDocRef.set({
        // Campo principal (GeoPoint) no próprio doc do usuário
        'location': GeoPoint(pos.latitude, pos.longitude),

        // Extras úteis (opcional manter)
        'latitude': pos.latitude,
        'longitude': pos.longitude,
        'accuracy': pos.accuracy,
        'heading': pos.heading,
        'speed': pos.speed,

        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {
      // Ignora erros de rede temporários para não matar o stream.
    }
  }, onError: (e) {
    // Você pode logar se quiser; não paramos automaticamente.
    // print('Erro no stream: $e');
  }, cancelOnError: false);
}
