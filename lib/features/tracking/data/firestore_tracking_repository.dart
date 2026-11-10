import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_guard.dart';
import '../../shipments/domain/shipment.dart';
import '../domain/simulated_driver.dart';
import '../domain/tracking.dart';
import '../domain/tracking_repository.dart';

/// Live tracking: `tracking/{shipmentId}` holds the latest position report
/// for a shipment. Every device listening to it gets each report as soon as
/// it's written.
class FirestoreTrackingRepository implements TrackingRepository {
  FirestoreTrackingRepository(
    this._db, {
    DateTime Function()? clock,
    math.Random? random,
  }) : _now = clock ?? DateTime.now,
       _random = random ?? math.Random();

  static const collection = 'tracking';

  final FirebaseFirestore _db;
  final DateTime Function() _now;
  final math.Random _random;

  DocumentReference<Map<String, dynamic>> _doc(String shipmentId) =>
      _db.collection(collection).doc(shipmentId);

  @override
  Stream<LivePosition?> watchPosition(String shipmentId) =>
      _doc(shipmentId)
          .snapshots()
          .map((snap) => fromMap(snap.data()))
          .transform(mapStreamErrors());

  @override
  Future<void> reportSimulatedPosition(Shipment shipment, {int? speedFactor}) {
    final ref = _doc(shipment.id);
    return guarded(
      () => _db.runTransaction<void>((tx) async {
        final last = fromMap((await tx.get(ref)).data());
        final now = _now();
        final justReported =
            last != null &&
            last.belongsTo(shipment) &&
            now.difference(last.reportedAt) < SimulatedDriver.minGap;
        if (justReported && speedFactor == null) return;

        final next = SimulatedDriver.next(
          shipment,
          last: last,
          now: now,
          random: _random,
          speedFactor: speedFactor,
        );
        if (next == null) return;
        tx.set(ref, toMap(next, shipperId: shipment.shipperId));
      }, timeout: writeTimeout),
    );
  }

  /// Null for a missing or malformed document.
  static LivePosition? fromMap(Map<String, dynamic>? m) {
    if (m == null) return null;
    final progress = m['progress'];
    final speed = m['speedKmh'];
    final eta = m['etaAt'];
    final reportedAt = m['updatedAt'];
    final tripStartedAt = m['tripStartedAt'];
    if (progress is! num ||
        speed is! num ||
        eta is! Timestamp ||
        reportedAt is! Timestamp ||
        tripStartedAt is! Timestamp) {
      return null;
    }
    final factor = m['speedFactor'];
    return LivePosition(
      progress: progress.toDouble().clamp(0.0, 1.0),
      speedKmh: math.max(0, speed.toDouble()),
      eta: eta.toDate(),
      reportedAt: reportedAt.toDate(),
      tripStartedAt: tripStartedAt.toDate(),
      speedFactor: factor is int && factor >= 1 ? factor : 1,
    );
  }

  static Map<String, dynamic> toMap(
    LivePosition p, {
    required String shipperId,
  }) => {
    'shipperId': shipperId,
    'progress': p.progress,
    'speedKmh': p.speedKmh,
    'speedFactor': p.speedFactor,
    'etaAt': Timestamp.fromDate(p.eta),
    'updatedAt': Timestamp.fromDate(p.reportedAt),
    'tripStartedAt': Timestamp.fromDate(p.tripStartedAt),
    'source': 'simulated',
  };
}
