import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RideOrdersRecord extends FirestoreRecord {
  RideOrdersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user" field.
  DocumentReference? _user;
  DocumentReference? get user => _user;
  bool hasUser() => _user != null;

  // "latlng" field.
  LatLng? _latlng;
  LatLng? get latlng => _latlng;
  bool hasLatlng() => _latlng != null;

  // "dia" field.
  DateTime? _dia;
  DateTime? get dia => _dia;
  bool hasDia() => _dia != null;

  // "option" field.
  String? _option;
  String get option => _option ?? '';
  bool hasOption() => _option != null;

  // "latlngAtual" field.
  LatLng? _latlngAtual;
  LatLng? get latlngAtual => _latlngAtual;
  bool hasLatlngAtual() => _latlngAtual != null;

  // "driver" field.
  DocumentReference? _driver;
  DocumentReference? get driver => _driver;
  bool hasDriver() => _driver != null;

  void _initializeFields() {
    _user = snapshotData['user'] as DocumentReference?;
    _latlng = snapshotData['latlng'] as LatLng?;
    _dia = snapshotData['dia'] as DateTime?;
    _option = snapshotData['option'] as String?;
    _latlngAtual = snapshotData['latlngAtual'] as LatLng?;
    _driver = snapshotData['driver'] as DocumentReference?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rideOrders');

  static Stream<RideOrdersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RideOrdersRecord.fromSnapshot(s));

  static Future<RideOrdersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RideOrdersRecord.fromSnapshot(s));

  static RideOrdersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RideOrdersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RideOrdersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RideOrdersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RideOrdersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RideOrdersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRideOrdersRecordData({
  DocumentReference? user,
  LatLng? latlng,
  DateTime? dia,
  String? option,
  LatLng? latlngAtual,
  DocumentReference? driver,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user': user,
      'latlng': latlng,
      'dia': dia,
      'option': option,
      'latlngAtual': latlngAtual,
      'driver': driver,
    }.withoutNulls,
  );

  return firestoreData;
}

class RideOrdersRecordDocumentEquality implements Equality<RideOrdersRecord> {
  const RideOrdersRecordDocumentEquality();

  @override
  bool equals(RideOrdersRecord? e1, RideOrdersRecord? e2) {
    return e1?.user == e2?.user &&
        e1?.latlng == e2?.latlng &&
        e1?.dia == e2?.dia &&
        e1?.option == e2?.option &&
        e1?.latlngAtual == e2?.latlngAtual &&
        e1?.driver == e2?.driver;
  }

  @override
  int hash(RideOrdersRecord? e) => const ListEquality()
      .hash([e?.user, e?.latlng, e?.dia, e?.option, e?.latlngAtual, e?.driver]);

  @override
  bool isValidKey(Object? o) => o is RideOrdersRecord;
}
