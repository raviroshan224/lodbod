import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/features/notifications/domain/activity.dart';
import 'package:lodbod/features/shipments/data/demo_seed.dart';
import 'package:lodbod/features/shipments/domain/shipment.dart';
import 'package:lodbod/features/tracking/domain/tracking.dart';

void main() {
  final now = DateTime(2026, 11, 7, 14);
  final seed = DemoSeed.build(shipperId: 'u1', now: now);
  Shipment ref(String r) => seed.shipments.firstWhere((s) => s.reference == r);

  group('activity feed', () {
    final feed = buildActivityFeed(seed.shipments, seed.bids);

    test('is newest first and covers bids and every status change', () {
      for (var i = 1; i < feed.length; i++) {
        expect(feed[i - 1].at.isBefore(feed[i].at), isFalse);
      }
      final timelineEntries = seed.shipments.fold(
        0,
        (n, s) => n + s.timeline.length,
      );
      expect(feed.length, timelineEntries + seed.bids.length);
    });

    test('bid items link to the bid and name the carrier and fare', () {
      final himalayan = feed.firstWhere(
        (a) => a.body.startsWith('Himalayan Cargo'),
      );
      expect(himalayan.kind, ActivityKind.bid);
      expect(himalayan.title, 'New bid on LOD-1002');
      expect(himalayan.body, contains('Rs. 32,000'));
      expect(himalayan.bidId, isNotNull);
    });
  });

  group('simulated tracking', () {
    test('in-transit progress sits between pickup and arrival', () {
      final t = trackingFor(ref('LOD-1001'), now: now);
      expect(t.progress, greaterThan(0.05));
      expect(t.progress, lessThan(0.95));
      expect(t.distanceKm, 200);
      expect(t.remainingKm, lessThan(200));
    });

    test('delivered is complete and scheduled has not started', () {
      expect(trackingFor(ref('LOD-1003'), now: now).progress, 1);
      expect(trackingFor(ref('LOD-1001'), now: now).isLate, isFalse);
      expect(trackingFor(ref('LOD-1004'), now: now).progress, 0);
    });

    test('known routes work in either direction', () {
      final s = ref('LOD-1002'); // Birgunj → Kathmandu (known)
      expect(trackingFor(s, now: now).checkpoints.first.name, 'Pathlaiya');
      final reversed = Shipment(
        id: 'r',
        reference: 'LOD-9',
        shipperId: 'u1',
        pickup: 'Pokhara',
        destination: 'Kathmandu',
        cargoCategory: CargoCategory.other,
        cargoDescription: 'x',
        weight: 1,
        weightUnit: WeightUnit.tonne,
        vehicleType: VehicleType.openTruck,
        pickupAt: now,
        status: ShipmentStatus.scheduled,
        createdAt: now,
        updatedAt: now,
      );
      final cps = trackingFor(reversed, now: now).checkpoints;
      expect(cps.first.name, 'Damauli');
      expect(cps.first.fraction, closeTo(0.25, 1e-9));
    });
  });

  test('simulated bids land after posting, a few seconds apart', () {
    final posted = ref('LOD-1004');
    var n = 0;
    final arrivedAt = posted.createdAt.add(const Duration(seconds: 20));
    final bids = DemoSeed.simulatedBidsFor(
      posted,
      now: arrivedAt,
      newId: () => 'b${n++}',
    );
    expect(bids, hasLength(3));
    final times = bids.map((b) => b.createdAt).toSet();
    expect(times, hasLength(3));
    for (final t in times) {
      expect(t.isBefore(posted.createdAt), isFalse);
      expect(t.isAfter(arrivedAt), isFalse);
    }
  });

  test('a load still in transit after its ETA is reported as running late', () {
    final lod1001 = ref('LOD-1001');
    final afterEta = lod1001.etaAt!.add(const Duration(days: 2));
    final t = trackingFor(lod1001, now: afterEta);
    expect(t.isLate, isTrue);
    expect(t.progress, lessThan(1)); // Not shown as arrived.
  });
}
