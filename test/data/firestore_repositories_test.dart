import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/errors/app_exception.dart';
import 'package:lodbod/data/models/bid.dart';
import 'package:lodbod/data/models/shipment.dart';
import 'package:lodbod/data/repositories/firebase/firestore_account_repository.dart';
import 'package:lodbod/data/repositories/firebase/firestore_bid_repository.dart';
import 'package:lodbod/data/repositories/firebase/firestore_shipment_repository.dart';
import 'package:lodbod/data/models/user_profile.dart';

void main() {
  final now = DateTime(2026, 11, 7, 10);
  const uid = 'uid-demo';
  const registration = Registration(
    name: 'Aarav Shrestha',
    phone: '9800000001',
    email: 'aarav@example.com',
    company: 'Himal Traders Pvt. Ltd.',
    password: '',
  );
  const lod1001 = 'seed_${uid}_1001';
  const lod1002 = 'seed_${uid}_1002';
  const lod1004 = 'seed_${uid}_1004';

  late FakeFirebaseFirestore db;
  late FirestoreShipmentRepository shipments;
  late FirestoreBidRepository bids;
  late FirestoreAccountRepository account;

  NewShipment input({String from = 'Pokhara', String to = 'Butwal'}) =>
      NewShipment(
        pickup: from,
        destination: to,
        cargoCategory: CargoCategory.fmcg,
        cargoDescription: 'Biscuits',
        weight: 6,
        weightUnit: WeightUnit.tonne,
        vehicleType: VehicleType.closedTruck,
        pickupAt: now.add(const Duration(days: 1)),
        expectedFare: 20000,
      );

  Future<int> activeCount() async =>
      (await db.collection('users').doc(uid).get())
              .data()!['activeRequestCount']
          as int;

  Future<int> shipmentDocCount() async =>
      (await db.collection('shipments').get()).docs.length;

  setUp(() async {
    db = FakeFirebaseFirestore();
    shipments = FirestoreShipmentRepository(db, clock: () => now);
    bids = FirestoreBidRepository(db, clock: () => now);
    account = FirestoreAccountRepository(db, clock: () => now);
    await account.createProfile(uid, registration);
    await account.loadSampleData(uid);
  });

  group('seeding', () {
    test(
      'creates the four sample shipments, their bids and a matching counter',
      () async {
        final list = await shipments.watchShipments(uid).first;
        expect(
          list.map((s) => s.reference),
          unorderedEquals(['LOD-1001', 'LOD-1002', 'LOD-1003', 'LOD-1004']),
        );
        expect(
          (await bids.watchBids(shipmentId: lod1002, shipperId: uid).first)
              .length,
          3,
        );
        // In transit + Awaiting bids + Scheduled = 3 qualifying.
        expect(await activeCount(), 3);
      },
    );

    test('reset restores sample data and removes created shipments', () async {
      await shipments.cancelShipment(lod1002);
      await shipments.createShipment(
        shipperId: uid,
        requestId: 'r1',
        input: input(),
      );
      await account.loadSampleData(uid);

      final list = await shipments.watchShipments(uid).first;
      expect(list.length, 4);
      expect(
        list.firstWhere((s) => s.id == lod1002).status,
        ShipmentStatus.awaitingBids,
      );
      expect(await activeCount(), 3);
    });
  });

  group('three-request limit', () {
    test('rejects a fourth qualifying request and writes nothing', () async {
      final before = await shipmentDocCount();
      await expectLater(
        shipments.createShipment(
          shipperId: uid,
          requestId: 'r1',
          input: input(),
        ),
        throwsA(isA<RequestLimitReachedException>()),
      );
      expect(await shipmentDocCount(), before);
      expect(await activeCount(), 3);
    });

    test(
      'a cancelled request frees a slot; the next create fills it',
      () async {
        await shipments.cancelShipment(lod1002);
        expect(await activeCount(), 2);

        final created = await shipments.createShipment(
          shipperId: uid,
          requestId: 'r1',
          input: input(),
        );
        expect(created.reference, 'LOD-1005');
        expect(created.status, ShipmentStatus.awaitingBids);
        expect(await activeCount(), 3);

        await expectLater(
          shipments.createShipment(
            shipperId: uid,
            requestId: 'r2',
            input: input(),
          ),
          throwsA(isA<RequestLimitReachedException>()),
        );
      },
    );

    test('a delivered request frees a slot', () async {
      await shipments.applyCarrierUpdate(
        shipmentId: lod1001,
        from: ShipmentStatus.inTransit,
      );
      expect(await activeCount(), 2);
    });

    test(
      'accepting a bid does not change the count (both statuses qualify)',
      () async {
        await bids.acceptBid(shipmentId: lod1002, bidId: 'seed_${uid}_1002_a');
        expect(await activeCount(), 3);
      },
    );
  });

  group('createShipment', () {
    setUp(() => shipments.cancelShipment(lod1002));

    test('references are unique and sequential', () async {
      await shipments.applyCarrierUpdate(
        shipmentId: lod1001,
        from: ShipmentStatus.inTransit,
      );
      final a = await shipments.createShipment(
        shipperId: uid,
        requestId: 'r1',
        input: input(),
      );
      final b = await shipments.createShipment(
        shipperId: uid,
        requestId: 'r2',
        input: input(),
      );
      expect([a.reference, b.reference], ['LOD-1005', 'LOD-1006']);
    });

    test(
      'retrying with the same request id does not create a duplicate',
      () async {
        final first = await shipments.createShipment(
          shipperId: uid,
          requestId: 'r1',
          input: input(),
        );
        final retry = await shipments.createShipment(
          shipperId: uid,
          requestId: 'r1',
          input: input(),
        );
        expect(retry.reference, first.reference);
        expect(await activeCount(), 3);
        final list = await shipments.watchShipments(uid).first;
        expect(list.where((s) => s.reference == 'LOD-1005').length, 1);
      },
    );

    test(
      'new shipment appears first in the live list with its timeline',
      () async {
        await shipments.createShipment(
          shipperId: uid,
          requestId: 'r1',
          input: input(),
        );
        final list = await shipments.watchShipments(uid).first;
        expect(list.first.reference, 'LOD-1005');
        expect(list.first.timeline.single.status, ShipmentStatus.awaitingBids);
      },
    );
  });

  group('acceptBid', () {
    final himalayan = 'seed_${uid}_1002_a';
    final swift = 'seed_${uid}_1002_b';

    test('confirms the shipment and updates every bid consistently', () async {
      await bids.acceptBid(shipmentId: lod1002, bidId: himalayan);

      final s = (await shipments.watchShipments(uid).first).firstWhere(
        (s) => s.id == lod1002,
      );
      expect(s.status, ShipmentStatus.confirmed);
      expect(s.acceptedBidId, himalayan);
      expect(s.carrierName, 'Himalayan Cargo');
      expect(s.agreedFare, 32000);
      // The load is booked on the vehicle the carrier offered.
      expect(s.vehicleType, VehicleType.closedTruck);
      expect(s.vehicleNumber, isNotEmpty);
      expect(s.timeline.last.status, ShipmentStatus.confirmed);

      final all = await bids
          .watchBids(shipmentId: lod1002, shipperId: uid)
          .first;
      expect(
        all.where((b) => b.status == BidStatus.accepted).single.id,
        himalayan,
      );
      expect(all.where((b) => b.status == BidStatus.declined).length, 2);
    });

    test('accepting a second, different bid is rejected', () async {
      await bids.acceptBid(shipmentId: lod1002, bidId: himalayan);
      await expectLater(
        bids.acceptBid(shipmentId: lod1002, bidId: swift),
        throwsA(isA<BidAlreadyAcceptedException>()),
      );
      final s = (await shipments.watchShipments(uid).first).firstWhere(
        (s) => s.id == lod1002,
      );
      expect(s.acceptedBidId, himalayan);
    });

    test('retrying the same accept is a no-op, not an error', () async {
      await bids.acceptBid(shipmentId: lod1002, bidId: himalayan);
      await bids.acceptBid(shipmentId: lod1002, bidId: himalayan);
      final s = (await shipments.watchShipments(uid).first).firstWhere(
        (s) => s.id == lod1002,
      );
      expect(
        s.timeline.where((e) => e.status == ShipmentStatus.confirmed).length,
        1,
      );
    });

    test('bids on a cancelled shipment cannot be accepted', () async {
      await shipments.cancelShipment(lod1002);
      await expectLater(
        bids.acceptBid(shipmentId: lod1002, bidId: himalayan),
        throwsA(isA<InvalidStateException>()),
      );
      final all = await bids
          .watchBids(shipmentId: lod1002, shipperId: uid)
          .first;
      expect(all.every((b) => b.status == BidStatus.declined), isTrue);
    });
  });

  group('status changes', () {
    test(
      'carrier updates follow the lifecycle and reject stale transitions',
      () async {
        await shipments.applyCarrierUpdate(
          shipmentId: lod1004,
          from: ShipmentStatus.scheduled,
        );
        var s = (await shipments.watchShipments(uid).first).firstWhere(
          (s) => s.id == lod1004,
        );
        expect(s.status, ShipmentStatus.inTransit);

        // Same update again (e.g. a retry) is harmless.
        await shipments.applyCarrierUpdate(
          shipmentId: lod1004,
          from: ShipmentStatus.scheduled,
        );

        await expectLater(
          shipments.applyCarrierUpdate(
            shipmentId: lod1004,
            from: ShipmentStatus.confirmed,
          ),
          throwsA(isA<InvalidStateException>()),
        );
        s = (await shipments.watchShipments(uid).first).firstWhere(
          (s) => s.id == lod1004,
        );
        expect(s.status, ShipmentStatus.inTransit);
      },
    );

    test('in-transit shipments cannot be cancelled', () async {
      await expectLater(
        shipments.cancelShipment(lod1001),
        throwsA(isA<InvalidStateException>()),
      );
    });

    test('simulated bids arrive only for a shipment with no bids', () async {
      await shipments.cancelShipment(lod1002);
      final created = await shipments.createShipment(
        shipperId: uid,
        requestId: 'r1',
        input: input(),
      );
      expect(await bids.simulateIncomingBids(created.id), 3);
      final arrived = await bids
          .watchBids(shipmentId: created.id, shipperId: uid)
          .first;
      expect(arrived.length, 3);
      expect(
        arrived.every((b) => !b.createdAt.isBefore(created.createdAt)),
        isTrue,
      );
      await expectLater(
        bids.simulateIncomingBids(created.id),
        throwsA(isA<InvalidStateException>()),
      );
    });
  });
}
