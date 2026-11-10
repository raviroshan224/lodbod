import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../../domain/request_limit.dart';
import '../../../domain/shipment_query.dart';
import '../../models/bid.dart';
import '../../models/shipment.dart';
import '../../seed/demo_seed.dart';
import '../repositories.dart';
import 'firestore_guard.dart';
import 'firestore_mappers.dart';

/// Firestore-backed shipments.
///
/// Data layout:
/// - `shipments/{id}`: one document per request, `shipperId` links it to
///   its shipper.
/// - `users/{shipperId}.activeRequestCount`: number of qualifying requests,
///   kept in step with status changes inside the same transactions. It lets
///   the create transaction enforce the limit atomically (Firestore
///   transactions can read documents but not run queries).
/// - `meta/counters.nextShipmentNumber`: source of unique `LOD-####`
///   references.
class FirestoreShipmentRepository implements ShipmentRepository {
  FirestoreShipmentRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final FirebaseFirestore _db;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _shipments =>
      _db.collection(Col.shipments);
  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(Col.users);
  CollectionReference<Map<String, dynamic>> get _bids =>
      _db.collection(Col.bids);
  DocumentReference<Map<String, dynamic>> get _counters =>
      _db.collection(Col.meta).doc(Col.countersDoc);

  @override
  Stream<List<Shipment>> watchShipments(String shipperId) {
    return _shipments
        .where(Fields.shipperId, isEqualTo: shipperId)
        .snapshots()
        .map(
          (snap) => sortByRecent(
            parseDocs(
              snap.docs.map((d) => (id: d.id, data: d.data())),
              FirestoreMappers.shipmentFromMap,
            ),
          ),
        )
        .transform(mapStreamErrors());
  }

  @override
  String newRequestId() => _shipments.doc().id;

  @override
  Future<Shipment> createShipment({
    required String shipperId,
    required String requestId,
    required NewShipment input,
  }) {
    final shipmentRef = _shipments.doc(requestId);
    final userRef = _users.doc(shipperId);

    return guarded(
      () => _db.runTransaction<Shipment>((tx) async {
        // All reads first, as Firestore transactions require.
        final existing = await tx.get(shipmentRef);
        if (existing.exists) {
          // A retry of a submission that already committed (e.g. the
          // response was lost). Return it instead of creating a duplicate.
          return FirestoreMappers.shipmentFromMap(
            existing.id,
            existing.data()!,
          );
        }
        final user = await tx.get(userRef);
        if (!user.exists) {
          throw const NotFoundException(
            'Your account is not set up yet. Sign out and sign in again.',
          );
        }
        final counters = await tx.get(_counters);

        final activeCount = readInt(user.data(), Fields.activeRequestCount);
        if (activeCount >= RequestLimit.max) {
          throw const RequestLimitReachedException();
        }

        final storedNext = readInt(counters.data(), Fields.nextShipmentNumber);
        final number = math.max(storedNext, DemoSeed.firstNewReferenceNumber);
        final now = _now();
        final shipment = Shipment(
          id: requestId,
          reference: 'LOD-$number',
          shipperId: shipperId,
          pickup: input.pickup,
          destination: input.destination,
          cargoCategory: input.cargoCategory,
          cargoDescription: input.cargoDescription,
          weight: input.weight,
          weightUnit: input.weightUnit,
          vehicleType: input.vehicleType,
          pickupAt: input.pickupAt,
          expectedFare: input.expectedFare,
          contactName: input.contactName,
          contactPhone: input.contactPhone,
          notes: input.notes,
          status: ShipmentStatus.awaitingBids,
          createdAt: now,
          updatedAt: now,
          timeline: [
            TimelineEntry(
              status: ShipmentStatus.awaitingBids,
              at: now,
              note: 'Request posted from the mobile app',
            ),
          ],
        );

        tx.set(shipmentRef, FirestoreMappers.shipmentToMap(shipment));
        tx.update(userRef, {Fields.activeRequestCount: activeCount + 1});
        tx.set(_counters, {
          Fields.nextShipmentNumber: number + 1,
        }, SetOptions(merge: true));
        return shipment;
      }, timeout: writeTimeout),
    );
  }

  @override
  Future<void> cancelShipment(String shipmentId) => _closeRequest(
    shipmentId,
    to: ShipmentStatus.cancelled,
    note: 'Cancelled by shipper',
    allowedFrom: (status) => status.canCancel,
  );

  @override
  Future<int> expireOverdueRequests(String shipperId) => guarded(() async {
    final now = _now();
    final open = await _shipments
        .where(Fields.shipperId, isEqualTo: shipperId)
        .where(Fields.status, isEqualTo: ShipmentStatus.awaitingBids.name)
        .get();
    var expired = 0;
    for (final doc in open.docs) {
      final pickup = doc.data()['pickupAt'];
      if (pickup is! Timestamp || pickup.toDate().isAfter(now)) continue;
      try {
        await _closeRequest(
          doc.id,
          to: ShipmentStatus.expired,
          note: 'Expired: the pickup time passed without a booking',
          allowedFrom: (status) => status == ShipmentStatus.awaitingBids,
        );
        expired++;
      } on InvalidStateException {
        // Booked or cancelled in the meantime (e.g. on another device).
      }
    }
    return expired;
  });

  /// Ends a request: sets its final status, frees its request slot and
  /// declines any open bids, all in one transaction.
  Future<void> _closeRequest(
    String shipmentId, {
    required ShipmentStatus to,
    required String note,
    required bool Function(ShipmentStatus status) allowedFrom,
  }) {
    final shipmentRef = _shipments.doc(shipmentId);
    return guarded(() async {
      final bidRefs = await _bidRefsFor(shipmentId);
      await _db.runTransaction<void>((tx) async {
        final snap = await tx.get(shipmentRef);
        final data = snap.data();
        if (data == null) {
          throw const NotFoundException('This shipment no longer exists.');
        }
        final status = ShipmentStatus.tryParse(data[Fields.status] as String?);
        if (status == to) return; // Already done.
        if (status == null || !allowedFrom(status)) {
          throw InvalidStateException(
            "This shipment can't be ${to.label.toLowerCase()} because it is "
            '${status?.label.toLowerCase() ?? 'in an unknown state'}.',
          );
        }
        final userRef = _users.doc(data[Fields.shipperId] as String);
        final user = await tx.get(userRef);
        final bids = [for (final r in bidRefs) await tx.get(r)];

        final now = _now();
        tx.update(shipmentRef, {
          Fields.status: to.name,
          'updatedAt': Timestamp.fromDate(now),
          'timeline': appendTimeline(
            data,
            FirestoreMappers.timelineToMap(
              TimelineEntry(status: to, at: now, note: note),
            ),
          ),
        });
        if (user.exists) {
          final count = readInt(user.data(), Fields.activeRequestCount);
          tx.update(userRef, {
            Fields.activeRequestCount: math.max(0, count - 1),
          });
        }
        for (final bid in bids) {
          if (bid.data()?[Fields.status] == BidStatus.pending.name) {
            tx.update(bid.reference, {Fields.status: BidStatus.declined.name});
          }
        }
      }, timeout: writeTimeout);
    });
  }

  @override
  Future<void> applyCarrierUpdate({
    required String shipmentId,
    required ShipmentStatus from,
  }) {
    final next = from.nextCarrierStatus;
    if (next == null) {
      return Future.error(
        InvalidStateException('No carrier update applies to "${from.label}".'),
      );
    }
    final shipmentRef = _shipments.doc(shipmentId);

    return guarded(
      () => _db.runTransaction<void>((tx) async {
        final snap = await tx.get(shipmentRef);
        final data = snap.data();
        if (data == null) {
          throw const NotFoundException('This shipment no longer exists.');
        }
        final current = ShipmentStatus.tryParse(data[Fields.status] as String?);
        if (current == next) return; // Retry of an update that committed.
        if (current != from) {
          throw const InvalidStateException(
            'This shipment was updated elsewhere. Review its latest status.',
          );
        }
        final userRef = _users.doc(data[Fields.shipperId] as String);
        final user = next.isTerminal ? await tx.get(userRef) : null;

        final now = _now();
        tx.update(shipmentRef, {
          Fields.status: next.name,
          'updatedAt': Timestamp.fromDate(now),
          'timeline': appendTimeline(
            data,
            FirestoreMappers.timelineToMap(
              TimelineEntry(status: next, at: now, note: _carrierNote(next)),
            ),
          ),
        });
        if (user != null && user.exists) {
          final count = readInt(user.data(), Fields.activeRequestCount);
          tx.update(userRef, {
            Fields.activeRequestCount: math.max(0, count - 1),
          });
        }
      }, timeout: writeTimeout),
    );
  }

  /// Bids on a shipment, filtered by owner too so the query satisfies the
  /// per-user security rules.
  Future<List<DocumentReference<Map<String, dynamic>>>> _bidRefsFor(
    String shipmentId,
  ) async {
    final shipment = await _shipments.doc(shipmentId).get();
    final shipperId = shipment.data()?[Fields.shipperId] as String?;
    if (shipperId == null) return const [];
    final snap = await _bids
        .where(Fields.shipmentId, isEqualTo: shipmentId)
        .where(Fields.shipperId, isEqualTo: shipperId)
        .get();
    return snap.docs.map((d) => d.reference).toList();
  }

  static String _carrierNote(ShipmentStatus next) => switch (next) {
    ShipmentStatus.scheduled => 'Carrier scheduled the pickup (simulated)',
    ShipmentStatus.inTransit => 'Cargo picked up (simulated)',
    ShipmentStatus.delivered => 'Delivered at destination (simulated)',
    _ => '',
  };
}
