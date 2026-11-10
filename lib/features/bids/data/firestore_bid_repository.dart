import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/errors/app_exception.dart';
import '../../models/bid.dart';
import '../../models/shipment.dart';
import '../../seed/demo_seed.dart';
import '../repositories.dart';
import 'firestore_guard.dart';
import 'firestore_mappers.dart';

/// Firestore-backed bids. `bids/{id}` documents link to their shipment via
/// `shipmentId` (and to the shipper via `shipperId`, for security rules and
/// cleanup).
class FirestoreBidRepository implements BidRepository {
  FirestoreBidRepository(this._db, {DateTime Function()? clock})
    : _now = clock ?? DateTime.now;

  final FirebaseFirestore _db;
  final DateTime Function() _now;

  CollectionReference<Map<String, dynamic>> get _bids =>
      _db.collection(Col.bids);
  CollectionReference<Map<String, dynamic>> get _shipments =>
      _db.collection(Col.shipments);

  @override
  Stream<List<Bid>> watchBids({
    required String shipmentId,
    required String shipperId,
  }) {
    return _bids
        .where(Fields.shipmentId, isEqualTo: shipmentId)
        .where(Fields.shipperId, isEqualTo: shipperId)
        .snapshots()
        .map((snap) {
          final bids = parseDocs(
            snap.docs.map((d) => (id: d.id, data: d.data())),
            FirestoreMappers.bidFromMap,
          );
          return bids..sort((a, b) => a.createdAt.compareTo(b.createdAt));
        })
        .transform(mapStreamErrors());
  }

  @override
  Stream<List<Bid>> watchBidsForShipper(String shipperId) {
    return _bids
        .where(Fields.shipperId, isEqualTo: shipperId)
        .snapshots()
        .map(
          (snap) => parseDocs(
            snap.docs.map((d) => (id: d.id, data: d.data())),
            FirestoreMappers.bidFromMap,
          ),
        )
        .transform(mapStreamErrors());
  }

  @override
  Future<void> acceptBid({required String shipmentId, required String bidId}) {
    final shipmentRef = _shipments.doc(shipmentId);
    final bidRef = _bids.doc(bidId);

    return guarded(() async {
      // Transactions can't run queries, so look up the sibling bids first and
      // then read each one inside the transaction. The owner filter keeps the
      // query within the per-user security rules.
      final shipperId =
          (await shipmentRef.get()).data()?[Fields.shipperId] as String?;
      if (shipperId == null) {
        throw const NotFoundException('This shipment no longer exists.');
      }
      final siblings = await _bids
          .where(Fields.shipmentId, isEqualTo: shipmentId)
          .where(Fields.shipperId, isEqualTo: shipperId)
          .get();

      await _db.runTransaction<void>((tx) async {
        final shipmentSnap = await tx.get(shipmentRef);
        final bidSnap = await tx.get(bidRef);
        final siblingSnaps = [
          for (final doc in siblings.docs)
            if (doc.id != bidId) await tx.get(doc.reference),
        ];

        final shipment = shipmentSnap.data();
        final bid = bidSnap.data();
        if (shipment == null) {
          throw const NotFoundException('This shipment no longer exists.');
        }
        if (bid == null || bid[Fields.shipmentId] != shipmentId) {
          throw const NotFoundException('This bid is no longer available.');
        }

        final acceptedBidId = shipment['acceptedBidId'] as String?;
        if (acceptedBidId == bidId) return; // Retry of a committed accept.
        if (acceptedBidId != null) throw const BidAlreadyAcceptedException();

        final status = ShipmentStatus.tryParse(
          shipment[Fields.status] as String?,
        );
        if (status != ShipmentStatus.awaitingBids) {
          throw InvalidStateException(
            'This shipment is no longer accepting bids '
            '(${status?.label.toLowerCase() ?? 'unknown status'}).',
          );
        }
        if (bid[Fields.status] != BidStatus.pending.name) {
          throw const InvalidStateException('This bid is no longer available.');
        }
        final now = _now();
        if (!(shipment['pickupAt'] as Timestamp).toDate().isAfter(now)) {
          throw const InvalidStateException(
            'The pickup time for this request has passed. '
            'Post it again with a new date.',
          );
        }

        final carrier = bid['carrierName'] as String;
        final fare = (bid['fare'] as num).toInt();

        tx.update(shipmentRef, {
          Fields.status: ShipmentStatus.confirmed.name,
          'acceptedBidId': bidId,
          'carrierName': carrier,
          'carrierPhone': bid['carrierPhone'] as String? ?? '',
          // The booked vehicle is the one the carrier offered.
          'vehicleType': bid['vehicleType'],
          'vehicleNumber': bid['vehicleNumber'] as String? ?? '',
          'etaAt': Timestamp.fromDate(
            (shipment['pickupAt'] as Timestamp).toDate().add(
              Duration(days: (bid['estimatedDeliveryDays'] as num).toInt()),
            ),
          ),
          'agreedFare': fare,
          'updatedAt': Timestamp.fromDate(now),
          'timeline': appendTimeline(
            shipment,
            FirestoreMappers.timelineToMap(
              TimelineEntry(
                status: ShipmentStatus.confirmed,
                at: now,
                note: 'Bid from $carrier accepted',
              ),
            ),
          ),
        });
        tx.update(bidRef, {Fields.status: BidStatus.accepted.name});
        for (final sibling in siblingSnaps) {
          if (sibling.data()?[Fields.status] == BidStatus.pending.name) {
            tx.update(sibling.reference, {
              Fields.status: BidStatus.declined.name,
            });
          }
        }
      }, timeout: writeTimeout);
    });
  }

  @override
  Future<int> simulateIncomingBids(String shipmentId) {
    final shipmentRef = _shipments.doc(shipmentId);
    return guarded(
      () => _db.runTransaction<int>((tx) async {
        final snap = await tx.get(shipmentRef);
        final data = snap.data();
        if (data == null) {
          throw const NotFoundException('This shipment no longer exists.');
        }
        final shipment = FirestoreMappers.shipmentFromMap(snap.id, data);
        if (shipment.status != ShipmentStatus.awaitingBids) {
          throw const InvalidStateException(
            'Only shipments awaiting bids can receive bids.',
          );
        }
        if (shipment.bidCount > 0) {
          throw const InvalidStateException('This shipment already has bids.');
        }

        final bids = DemoSeed.simulatedBidsFor(
          shipment,
          now: _now(),
          newId: () => _bids.doc().id,
        );
        for (final bid in bids) {
          tx.set(_bids.doc(bid.id), FirestoreMappers.bidToMap(bid));
        }
        tx.update(shipmentRef, {
          'bidCount': bids.length,
          'updatedAt': Timestamp.fromDate(_now()),
        });
        return bids.length;
      }, timeout: writeTimeout),
    );
  }
}
