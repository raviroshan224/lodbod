import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/data/models/bid.dart';
import 'package:lodbod/data/models/shipment.dart';
import 'package:lodbod/data/seed/demo_seed.dart';
import 'package:lodbod/domain/bid_rules.dart';
import 'package:lodbod/domain/request_limit.dart';
import 'package:lodbod/domain/shipment_query.dart';

void main() {
  final now = DateTime(2026, 11, 7, 10);
  final seed = DemoSeed.build(shipperId: 'u1', now: now);
  final sample = seed.shipments;

  Shipment withStatus(ShipmentStatus status) => Shipment(
    id: status.name,
    reference: 'LOD-${status.index}',
    shipperId: 'u1',
    pickup: 'A',
    destination: 'B',
    cargoCategory: CargoCategory.other,
    cargoDescription: 'x',
    weight: 1,
    weightUnit: WeightUnit.tonne,
    vehicleType: VehicleType.openTruck,
    pickupAt: now,
    status: status,
    createdAt: now,
    updatedAt: now,
  );

  group('RequestLimit', () {
    test('counts only Awaiting bids, Confirmed, Scheduled and In transit', () {
      final qualifying = ShipmentStatus.values.where(
        (s) => s.countsTowardRequestLimit,
      );
      expect(qualifying, [
        ShipmentStatus.awaitingBids,
        ShipmentStatus.confirmed,
        ShipmentStatus.scheduled,
        ShipmentStatus.inTransit,
      ]);
      expect(
        RequestLimit.countQualifying(ShipmentStatus.values.map(withStatus)),
        4,
      );
    });

    test('Delivered, Cancelled and Expired do not count', () {
      final closed = [
        ShipmentStatus.delivered,
        ShipmentStatus.cancelled,
        ShipmentStatus.expired,
      ].map(withStatus);
      expect(RequestLimit.countQualifying(closed), 0);
    });

    test('the brief sample data starts at the limit (3 of 3)', () {
      final usage = RequestLimit.usageOf(sample);
      expect(usage.used, 3);
      expect(usage.isAtLimit, isTrue);
      expect(usage.remaining, 0);
    });

    test('uses the prescribed message verbatim', () {
      expect(
        RequestLimit.message,
        'You have reached the mobile request limit of 3. Please use the LODBOD '
        'web platform to create additional requests.',
      );
    });
  });

  group('search and filters', () {
    List<String> refs(List<Shipment> list) =>
        list.map((s) => s.reference).toList();

    test('search matches reference, partial reference and route words', () {
      expect(refs(applyShipmentQuery(sample, query: 'LOD-1003')), ['LOD-1003']);
      expect(refs(applyShipmentQuery(sample, query: '1002')), ['LOD-1002']);
      expect(refs(applyShipmentQuery(sample, query: 'kathmandu pokhara')), [
        'LOD-1001',
      ]);
      expect(refs(applyShipmentQuery(sample, query: 'Birgunj → Kathmandu')), [
        'LOD-1002',
      ]);
      expect(
        refs(applyShipmentQuery(sample, query: 'kathmandu')),
        unorderedEquals(['LOD-1001', 'LOD-1002', 'LOD-1004']),
      );
    });

    test('search is case-insensitive and also matches cargo', () {
      expect(refs(applyShipmentQuery(sample, query: 'RICE')), ['LOD-1003']);
    });

    test('no match returns an empty list', () {
      expect(applyShipmentQuery(sample, query: 'Dhangadhi'), isEmpty);
    });

    test('references match with or without the hyphen', () {
      expect(refs(applyShipmentQuery(sample, query: 'lod1001')), ['LOD-1001']);
      expect(refs(applyShipmentQuery(sample, query: 'LOD 1004')), ['LOD-1004']);
    });

    test('hyphenated routes match their parts', () {
      expect(refs(applyShipmentQuery(sample, query: 'kathmandu-pokhara')), [
        'LOD-1001',
      ]);
    });

    test('text in other scripts is searched, not ignored', () {
      // Previously stripped to an empty query, which showed every shipment.
      expect(applyShipmentQuery(sample, query: 'काठमाडौं'), isEmpty);
    });

    test('status filter and search combine', () {
      expect(
        refs(
          applyShipmentQuery(
            sample,
            query: 'kathmandu',
            filter: ShipmentFilter.active,
          ),
        ),
        unorderedEquals(['LOD-1001', 'LOD-1004']),
      );
      expect(
        refs(applyShipmentQuery(sample, filter: ShipmentFilter.awaitingBids)),
        ['LOD-1002'],
      );
    });

    test('dashboard counts match the brief sample data', () {
      final summary = ShipmentSummary.from(sample);
      expect(summary.active, 2); // In transit + Scheduled
      expect(summary.awaitingBids, 1);
      expect(summary.completed, 1);
      expect(summary.total, 4);
    });

    test('every dashboard count equals what its filtered list shows', () {
      final mixed = [...sample, ...ShipmentStatus.values.map(withStatus)];
      final summary = ShipmentSummary.from(mixed);
      for (final f in ShipmentFilter.values) {
        expect(
          applyShipmentQuery(mixed, filter: f).length,
          summary.countFor(f),
          reason: f.name,
        );
      }
    });
  });

  group('effectiveBidStatus', () {
    final s1002 = sample.firstWhere((s) => s.reference == 'LOD-1002');
    final bids = seed.bids.where((b) => b.shipmentId == s1002.id).toList();

    test('pending bids stay pending while the shipment awaits bids', () {
      expect(bids.map((b) => effectiveBidStatus(b, s1002)).toSet(), {
        BidStatus.pending,
      });
    });

    test('once a bid is accepted, every other bid shows as not selected', () {
      final accepted = Shipment(
        id: s1002.id,
        reference: s1002.reference,
        shipperId: s1002.shipperId,
        pickup: s1002.pickup,
        destination: s1002.destination,
        cargoCategory: s1002.cargoCategory,
        cargoDescription: s1002.cargoDescription,
        weight: s1002.weight,
        weightUnit: s1002.weightUnit,
        vehicleType: s1002.vehicleType,
        pickupAt: s1002.pickupAt,
        status: ShipmentStatus.confirmed,
        acceptedBidId: bids.first.id,
        createdAt: s1002.createdAt,
        updatedAt: s1002.updatedAt,
      );
      expect(effectiveBidStatus(bids.first, accepted), BidStatus.accepted);
      for (final b in bids.skip(1)) {
        expect(effectiveBidStatus(b, accepted), BidStatus.declined);
      }
    });
  });

  test('LOD-1002 has at least two comparable bids from the brief', () {
    final bids = seed.bids
        .where((b) => b.shipmentId == 'seed_u1_1002')
        .toList();
    expect(bids.length, greaterThanOrEqualTo(2));
    final himalayan = bids.firstWhere(
      (b) => b.carrierName == 'Himalayan Cargo',
    );
    expect(
      (
        himalayan.fare,
        himalayan.carrierRating,
        himalayan.estimatedDeliveryDays,
      ),
      (32000, 4.6, 2),
    );
    final swift = bids.firstWhere((b) => b.carrierName == 'Swift Transport');
    expect(
      (swift.fare, swift.carrierRating, swift.estimatedDeliveryDays),
      (29500, 4.1, 3),
    );
  });
}
