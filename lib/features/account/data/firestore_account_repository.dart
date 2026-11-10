import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/firebase/firestore_guard.dart';
import '../../../core/firebase/firestore_schema.dart';
import '../../auth/domain/user_profile.dart';
import '../../bids/data/bid_mapper.dart';
import '../../create_shipment/data/draft_mapper.dart';
import '../../create_shipment/domain/shipment_draft.dart';
import '../../shipments/data/demo_seed.dart';
import '../../shipments/data/shipment_mapper.dart';
import '../../shipments/domain/request_limit.dart';
import '../../shipments/domain/shipment.dart';
import '../domain/account_repository.dart';
import 'profile_mapper.dart';

/// Shipper profiles and per-account data.
///
/// - `users/{uid}`: profile, request-limit counter, alert preferences.
/// - `users/{uid}/drafts/current`: the saved Post Load draft.
/// - `phoneIndex/{phone}`: `{uid, email}` so shippers can sign in with
///   their phone number (Firebase identity is the email).
/// - `feedback/{id}`: messages sent from Help & support.
class FirestoreAccountRepository implements AccountRepository {
  FirestoreAccountRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final FirebaseFirestore _db;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(Col.users);
  CollectionReference<Map<String, dynamic>> get _phones =>
      _db.collection(Col.phoneIndex);
  CollectionReference<Map<String, dynamic>> get _shipments =>
      _db.collection(Col.shipments);
  CollectionReference<Map<String, dynamic>> get _bids =>
      _db.collection(Col.bids);
  DocumentReference<Map<String, dynamic>> get _counters =>
      _db.collection(Col.meta).doc(Col.countersDoc);
  DocumentReference<Map<String, dynamic>> _draftRef(String uid) =>
      _users.doc(uid).collection(Col.drafts).doc(Col.currentDraft);

  @override
  Stream<UserProfile?> watchProfile(String uid) => _users
      .doc(uid)
      .snapshots()
      .map((snap) {
        final data = snap.data();
        return data == null ? null : ProfileMapper.fromMap(uid, data);
      })
      .transform(mapStreamErrors());

  @override
  Future<void> createProfile(String uid, Registration r) => guarded(
    () => _db.runTransaction<void>((tx) async {
      final phoneRef = _phones.doc(r.phone);
      final phone = await tx.get(phoneRef);
      final owner = phone.data()?['uid'];
      if (phone.exists && owner != uid) throw const PhoneTakenException();

      final now = Timestamp.fromDate(_now());
      tx.set(phoneRef, {'uid': uid, 'email': r.email.trim().toLowerCase()});
      tx.set(_users.doc(uid), {
        'name': r.name.trim(),
        'company': r.company.trim(),
        'phone': r.phone,
        'email': r.email.trim().toLowerCase(),
        'role': 'shipper',
        Fields.activeRequestCount: 0,
        Fields.notificationsSeenAt: now,
        'bidAlerts': true,
        'statusAlerts': true,
        'createdAt': now,
      });
    }, timeout: writeTimeout),
  );

  @override
  Future<void> updateProfile(
    UserProfile profile, {
    required String previousPhone,
  }) => guarded(
    () => _db.runTransaction<void>((tx) async {
      final phoneChanged = profile.phone != previousPhone;
      final newPhoneRef = _phones.doc(profile.phone);
      if (phoneChanged) {
        final existing = await tx.get(newPhoneRef);
        if (existing.exists && existing.data()?['uid'] != profile.id) {
          throw const PhoneTakenException();
        }
        tx.delete(_phones.doc(previousPhone));
        tx.set(newPhoneRef, {'uid': profile.id, 'email': profile.email});
      }
      tx.update(_users.doc(profile.id), {
        'name': profile.name.trim(),
        'company': profile.company.trim(),
        'phone': profile.phone,
        'bidAlerts': profile.bidAlerts,
        'statusAlerts': profile.statusAlerts,
      });
    }, timeout: writeTimeout),
  );

  @override
  Future<String?> emailForPhone(String phone) => guarded(() async {
    final snap = await _phones.doc(phone).get();
    return snap.data()?['email'] as String?;
  });

  @override
  Future<bool> isPhoneRegistered(String phone) =>
      guarded(() async => (await _phones.doc(phone).get()).exists);

  @override
  Future<void> reconcileRequestCount(String uid) => guarded(() async {
    final snap = await _shipments.where(Fields.shipperId, isEqualTo: uid).get();
    final actual = snap.docs
        .map((d) => ShipmentStatus.tryParse(d.data()[Fields.status] as String?))
        .where((s) => s?.countsTowardRequestLimit ?? false)
        .length;
    final userRef = _users.doc(uid);
    final user = await userRef.get();
    if (user.exists &&
        readInt(user.data(), Fields.activeRequestCount) != actual) {
      await userRef.update({Fields.activeRequestCount: actual});
    }
  });

  /// Atomically replaces the shipper's shipments and bids with the sample
  /// data. The reference counter is never rewound, so references stay unique.
  @override
  Future<void> loadSampleData(String uid) => guarded(() async {
    final seed = DemoSeed.build(shipperId: uid, now: _now());
    final seededShipmentIds = seed.shipments.map((s) => s.id).toSet();
    final seededBidIds = seed.bids.map((b) => b.id).toSet();

    final oldShipments = await _shipments
        .where(Fields.shipperId, isEqualTo: uid)
        .get();
    final oldBids = await _bids.where(Fields.shipperId, isEqualTo: uid).get();
    final counters = await _counters.get();

    final batch = _db.batch();
    for (final doc in oldShipments.docs) {
      if (!seededShipmentIds.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final doc in oldBids.docs) {
      if (!seededBidIds.contains(doc.id)) batch.delete(doc.reference);
    }
    for (final s in seed.shipments) {
      batch.set(_shipments.doc(s.id), ShipmentMapper.toMap(s));
    }
    for (final b in seed.bids) {
      batch.set(_bids.doc(b.id), BidMapper.toMap(b));
    }
    batch.update(_users.doc(uid), {
      Fields.activeRequestCount: RequestLimit.countQualifying(seed.shipments),
      Fields.seedVersion: DemoSeed.version,
      Fields.seededAt: Timestamp.fromDate(_now()),
    });
    if (!counters.exists) {
      batch.set(_counters, {
        Fields.nextShipmentNumber: DemoSeed.firstNewReferenceNumber,
      });
    }
    await batch.commit();
  });

  /// Sample data older than this is refreshed on sign-in if untouched.
  static const sampleDataShelfLife = Duration(hours: 3);

  @override
  Future<bool> refreshStaleSampleData(String uid) => guarded(() async {
    final data = (await _users.doc(uid).get()).data();
    if (data?[Fields.seedVersion] == null) return false; // Never loaded.
    final seededAt = data?[Fields.seededAt];
    // Sample data from before load times were recorded counts as stale.
    if (seededAt is Timestamp &&
        _now().difference(seededAt.toDate()) < sampleDataShelfLife) {
      return false;
    }
    // Untouched = exactly the sample loads, each still in its sample status
    // (no bid accepted, nothing cancelled or delivered, nothing posted).
    final fresh = DemoSeed.build(shipperId: uid, now: _now());
    final initial = {for (final s in fresh.shipments) s.id: s.status.name};
    final current = await _shipments
        .where(Fields.shipperId, isEqualTo: uid)
        .get();
    final untouched =
        current.docs.length == initial.length &&
        current.docs.every((d) => initial[d.id] == d.data()[Fields.status]);
    if (!untouched) return false;
    await loadSampleData(uid);
    return true;
  });

  @override
  Future<void> markNotificationsSeen(String uid) => guarded(
    () => _users.doc(uid).update({
      Fields.notificationsSeenAt: Timestamp.fromDate(_now()),
    }),
  );

  @override
  Future<void> saveDraft(String uid, ShipmentDraft draft) =>
      guarded(() => _draftRef(uid).set(DraftMapper.toMap(draft)));

  @override
  Future<ShipmentDraft?> loadDraft(String uid) => guarded(() async {
    final snap = await _draftRef(uid).get();
    final data = snap.data();
    return data == null ? null : DraftMapper.fromMap(data);
  });

  @override
  Future<void> clearDraft(String uid) => guarded(() => _draftRef(uid).delete());

  @override
  Future<void> sendFeedback(
    String uid, {
    required String topic,
    required String message,
  }) => guarded(
    () => _db.collection(Col.feedback).add({
      'uid': uid,
      'topic': topic,
      'message': message.trim(),
      'createdAt': Timestamp.fromDate(_now()),
    }),
  );
}
