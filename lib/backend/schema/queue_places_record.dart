import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class QueuePlacesRecord extends FirestoreRecord {
  QueuePlacesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "locationName" field.
  String? _locationName;
  String get locationName => _locationName ?? '';
  bool hasLocationName() => _locationName != null;

  // "latlng" field.
  LatLng? _latlng;
  LatLng? get latlng => _latlng;
  bool hasLatlng() => _latlng != null;

  void _initializeFields() {
    _locationName = snapshotData['locationName'] as String?;
    _latlng = snapshotData['latlng'] as LatLng?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('queuePlaces');

  static Stream<QueuePlacesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => QueuePlacesRecord.fromSnapshot(s));

  static Future<QueuePlacesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => QueuePlacesRecord.fromSnapshot(s));

  static QueuePlacesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      QueuePlacesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static QueuePlacesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      QueuePlacesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'QueuePlacesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is QueuePlacesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createQueuePlacesRecordData({
  String? locationName,
  LatLng? latlng,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'locationName': locationName,
      'latlng': latlng,
    }.withoutNulls,
  );

  return firestoreData;
}

class QueuePlacesRecordDocumentEquality implements Equality<QueuePlacesRecord> {
  const QueuePlacesRecordDocumentEquality();

  @override
  bool equals(QueuePlacesRecord? e1, QueuePlacesRecord? e2) {
    return e1?.locationName == e2?.locationName && e1?.latlng == e2?.latlng;
  }

  @override
  int hash(QueuePlacesRecord? e) =>
      const ListEquality().hash([e?.locationName, e?.latlng]);

  @override
  bool isValidKey(Object? o) => o is QueuePlacesRecord;
}
