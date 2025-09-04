import 'dart:convert';
import 'package:flutter/foundation.dart';

import '/flutter_flow/flutter_flow_util.dart';
import 'api_manager.dart';

export 'api_manager.dart' show ApiCallResponse;

const _kPrivateApiFunctionName = 'ffPrivateApiCall';

class VerificarDocumentAICall {
  static Future<ApiCallResponse> call({
    String? driverLicense = '',
    String? taxiLicense = '',
    String? insurance = '',
    String? vehicleRegistration = '',
    List<String>? vehiclePhotosList,
    String? expirationLicense = '',
    String? taxiLicenseExpiration = '',
    String? insuranceExpiration = '',
    String? vehicleExpiration = '',
  }) async {
    final vehiclePhotos = _serializeList(vehiclePhotosList);

    final ffApiRequestBody = '''
{
  "driverLicense": "${escapeStringForJson(driverLicense)}",
  "taxiLicense": "${escapeStringForJson(taxiLicense)}",
  "insurance": "${escapeStringForJson(insurance)}",
  "vehicleRegistration": "${escapeStringForJson(vehicleRegistration)}",
  "vehiclePhotos": ${vehiclePhotos},
  "expirationLicense": "${escapeStringForJson(expirationLicense)}",
  "taxiLicenseExpiration": "${escapeStringForJson(taxiLicenseExpiration)}",
  "insuranceExpiration": "${escapeStringForJson(insuranceExpiration)}",
  "vehicleExpiration": "${escapeStringForJson(vehicleExpiration)}"
}''';
    return ApiManager.instance.makeApiCall(
      callName: 'verificarDocument AI',
      apiUrl:
          'https://us-central1-quick-b108e.cloudfunctions.net/verificarDocumentos',
      callType: ApiCallType.POST,
      headers: {},
      params: {},
      body: ffApiRequestBody,
      bodyType: BodyType.JSON,
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static bool? ok(dynamic response) => castToType<bool>(getJsonField(
        response,
        r'''$.ok''',
      ));
  static List<String>? erros(dynamic response) => (getJsonField(
        response,
        r'''$.errors''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class LatlngToStringCall {
  static Future<ApiCallResponse> call({
    String? latlng = '',
  }) async {
    return ApiManager.instance.makeApiCall(
      callName: 'latlng To String',
      apiUrl:
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${latlng}&language=en-US&result_type=street_address&key=AIzaSyCxq0iBKdwc2F7SdBnYCzMhC-nXIMIEyyU',
      callType: ApiCallType.GET,
      headers: {},
      params: {
        'latlng': latlng,
      },
      returnBody: true,
      encodeBodyUtf8: false,
      decodeUtf8: false,
      cache: false,
      isStreamingApi: false,
      alwaysAllowBody: false,
    );
  }

  static List<String>? formatedCompleted(dynamic response) => (getJsonField(
        response,
        r'''$.results[:].formatted_address''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
  static List<String>? shortName(dynamic response) => (getJsonField(
        response,
        r'''$.results[:].address_components[:].long_name''',
        true,
      ) as List?)
          ?.withoutNulls
          .map((x) => castToType<String>(x))
          .withoutNulls
          .toList();
}

class ApiPagingParams {
  int nextPageNumber = 0;
  int numItems = 0;
  dynamic lastResponse;

  ApiPagingParams({
    required this.nextPageNumber,
    required this.numItems,
    required this.lastResponse,
  });

  @override
  String toString() =>
      'PagingParams(nextPageNumber: $nextPageNumber, numItems: $numItems, lastResponse: $lastResponse,)';
}

String _toEncodable(dynamic item) {
  if (item is DocumentReference) {
    return item.path;
  }
  return item;
}

String _serializeList(List? list) {
  list ??= <String>[];
  try {
    return json.encode(list, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("List serialization failed. Returning empty list.");
    }
    return '[]';
  }
}

String _serializeJson(dynamic jsonVar, [bool isList = false]) {
  jsonVar ??= (isList ? [] : {});
  try {
    return json.encode(jsonVar, toEncodable: _toEncodable);
  } catch (_) {
    if (kDebugMode) {
      print("Json serialization failed. Returning empty json.");
    }
    return isList ? '[]' : '{}';
  }
}

String? escapeStringForJson(String? input) {
  if (input == null) {
    return null;
  }
  return input
      .replaceAll('\\', '\\\\')
      .replaceAll('"', '\\"')
      .replaceAll('\n', '\\n')
      .replaceAll('\t', '\\t');
}
