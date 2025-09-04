import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "describeYourExperience" field.
  String? _describeYourExperience;
  String get describeYourExperience => _describeYourExperience ?? '';
  bool hasDescribeYourExperience() => _describeYourExperience != null;

  // "whatVeichleDrive" field.
  String? _whatVeichleDrive;
  String get whatVeichleDrive => _whatVeichleDrive ?? '';
  bool hasWhatVeichleDrive() => _whatVeichleDrive != null;

  // "MAXGuestsPerride" field.
  String? _mAXGuestsPerride;
  String get mAXGuestsPerride => _mAXGuestsPerride ?? '';
  bool hasMAXGuestsPerride() => _mAXGuestsPerride != null;

  // "SelectTaxiAcessibilty" field.
  String? _selectTaxiAcessibilty;
  String get selectTaxiAcessibilty => _selectTaxiAcessibilty ?? '';
  bool hasSelectTaxiAcessibilty() => _selectTaxiAcessibilty != null;

  // "DoesYourCarHaveAC" field.
  String? _doesYourCarHaveAC;
  String get doesYourCarHaveAC => _doesYourCarHaveAC ?? '';
  bool hasDoesYourCarHaveAC() => _doesYourCarHaveAC != null;

  // "AreYouAfiliatedWithaTaxiCompany" field.
  String? _areYouAfiliatedWithaTaxiCompany;
  String get areYouAfiliatedWithaTaxiCompany =>
      _areYouAfiliatedWithaTaxiCompany ?? '';
  bool hasAreYouAfiliatedWithaTaxiCompany() =>
      _areYouAfiliatedWithaTaxiCompany != null;

  // "WhichOne" field.
  String? _whichOne;
  String get whichOne => _whichOne ?? '';
  bool hasWhichOne() => _whichOne != null;

  // "pricePkilometer" field.
  double? _pricePkilometer;
  double get pricePkilometer => _pricePkilometer ?? 0.0;
  bool hasPricePkilometer() => _pricePkilometer != null;

  // "driver" field.
  bool? _driver;
  bool get driver => _driver ?? false;
  bool hasDriver() => _driver != null;

  // "driverOnline" field.
  bool? _driverOnline;
  bool get driverOnline => _driverOnline ?? false;
  bool hasDriverOnline() => _driverOnline != null;

  // "plaform" field.
  List<String>? _plaform;
  List<String> get plaform => _plaform ?? const [];
  bool hasPlaform() => _plaform != null;

  // "rideOn" field.
  DocumentReference? _rideOn;
  DocumentReference? get rideOn => _rideOn;
  bool hasRideOn() => _rideOn != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _describeYourExperience = snapshotData['describeYourExperience'] as String?;
    _whatVeichleDrive = snapshotData['whatVeichleDrive'] as String?;
    _mAXGuestsPerride = snapshotData['MAXGuestsPerride'] as String?;
    _selectTaxiAcessibilty = snapshotData['SelectTaxiAcessibilty'] as String?;
    _doesYourCarHaveAC = snapshotData['DoesYourCarHaveAC'] as String?;
    _areYouAfiliatedWithaTaxiCompany =
        snapshotData['AreYouAfiliatedWithaTaxiCompany'] as String?;
    _whichOne = snapshotData['WhichOne'] as String?;
    _pricePkilometer = castToType<double>(snapshotData['pricePkilometer']);
    _driver = snapshotData['driver'] as bool?;
    _driverOnline = snapshotData['driverOnline'] as bool?;
    _plaform = getDataList(snapshotData['plaform']);
    _rideOn = snapshotData['rideOn'] as DocumentReference?;
    _location = snapshotData['location'] as LatLng?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? describeYourExperience,
  String? whatVeichleDrive,
  String? mAXGuestsPerride,
  String? selectTaxiAcessibilty,
  String? doesYourCarHaveAC,
  String? areYouAfiliatedWithaTaxiCompany,
  String? whichOne,
  double? pricePkilometer,
  bool? driver,
  bool? driverOnline,
  DocumentReference? rideOn,
  LatLng? location,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'describeYourExperience': describeYourExperience,
      'whatVeichleDrive': whatVeichleDrive,
      'MAXGuestsPerride': mAXGuestsPerride,
      'SelectTaxiAcessibilty': selectTaxiAcessibilty,
      'DoesYourCarHaveAC': doesYourCarHaveAC,
      'AreYouAfiliatedWithaTaxiCompany': areYouAfiliatedWithaTaxiCompany,
      'WhichOne': whichOne,
      'pricePkilometer': pricePkilometer,
      'driver': driver,
      'driverOnline': driverOnline,
      'rideOn': rideOn,
      'location': location,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    const listEquality = ListEquality();
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.describeYourExperience == e2?.describeYourExperience &&
        e1?.whatVeichleDrive == e2?.whatVeichleDrive &&
        e1?.mAXGuestsPerride == e2?.mAXGuestsPerride &&
        e1?.selectTaxiAcessibilty == e2?.selectTaxiAcessibilty &&
        e1?.doesYourCarHaveAC == e2?.doesYourCarHaveAC &&
        e1?.areYouAfiliatedWithaTaxiCompany ==
            e2?.areYouAfiliatedWithaTaxiCompany &&
        e1?.whichOne == e2?.whichOne &&
        e1?.pricePkilometer == e2?.pricePkilometer &&
        e1?.driver == e2?.driver &&
        e1?.driverOnline == e2?.driverOnline &&
        listEquality.equals(e1?.plaform, e2?.plaform) &&
        e1?.rideOn == e2?.rideOn &&
        e1?.location == e2?.location;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.describeYourExperience,
        e?.whatVeichleDrive,
        e?.mAXGuestsPerride,
        e?.selectTaxiAcessibilty,
        e?.doesYourCarHaveAC,
        e?.areYouAfiliatedWithaTaxiCompany,
        e?.whichOne,
        e?.pricePkilometer,
        e?.driver,
        e?.driverOnline,
        e?.plaform,
        e?.rideOn,
        e?.location
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
