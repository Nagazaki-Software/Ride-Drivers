import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'lat_lng.dart';
import 'place.dart';
import 'uploaded_file.dart';
import '/backend/backend.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';

double? latlngToValor(
  LatLng latlngDestino,
  LatLng latlngOrigem,
  double valorPorKm,
) {
  // Validação de entrada
  if (valorPorKm.isNaN || valorPorKm.isInfinite || valorPorKm < 0) {
    return null;
  }

  // Se as coordenadas forem exatamente iguais, custo é zero
  if (latlngDestino.latitude == latlngOrigem.latitude &&
      latlngDestino.longitude == latlngOrigem.longitude) {
    return 0.0;
  }

  // Conversão para radianos
  double _toRad(double deg) => deg * (math.pi / 180.0);

  final double lat1 = _toRad(latlngOrigem.latitude);
  final double lon1 = _toRad(latlngOrigem.longitude);
  final double lat2 = _toRad(latlngDestino.latitude);
  final double lon2 = _toRad(latlngDestino.longitude);

  // Diferenças
  final double dLat = lat2 - lat1;
  final double dLon = lon2 - lon1;

  // Fórmula de Haversine
  const double R = 6371.0; // raio da Terra em km
  final double a = math.pow(math.sin(dLat / 2), 2).toDouble() +
      math.cos(lat1) *
          math.cos(lat2) *
          math.pow(math.sin(dLon / 2), 2).toDouble();
  final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  final double distanciaKm = R * c;

  // Valor total
  final double total = distanciaKm * valorPorKm;

  // Retorna com duas casas decimais para estabilidade monetária (opcional)
  return double.parse(total.toStringAsFixed(2));
}
