import '../models/bid.dart';
import '../models/shipment.dart';

class SeedData {
  const SeedData(this.shipments, this.bids);
  final List<Shipment> shipments;
  final List<Bid> bids;
}

/// Fictional sample records from the assignment brief (LOD-1001…1004 and
/// the LOD-1002 bids). Dates are generated relative to [now] so the data
/// stays coherent whenever it is seeded: the scheduled pickup is always in
/// the future, the delivered job always in the past.
abstract final class DemoSeed {
  /// Bump to force existing installs to re-seed on next sign-in.
  static const version = 1;

  /// New shipments created in the app start at LOD-1005.
  static const firstNewReferenceNumber = 1005;

  static SeedData build({required String shipperId, required DateTime now}) {
    DateTime day(int offset, int hour) =>
        DateTime(now.year, now.month, now.day + offset, hour);
    String sid(int n) => 'seed_${shipperId}_$n';
    String bid(int n, String suffix) => 'seed_${shipperId}_${n}_$suffix';

    Bid makeBid(
      int n,
      String suffix, {
      required String carrier,
      required double rating,
      required int trips,
      required int fare,
      required int days,
      required VehicleType vehicle,
      required BidStatus status,
      required DateTime at,
      String note = '',
      String phone = '',
      String plate = '',
    }) => Bid(
      id: bid(n, suffix),
      shipmentId: sid(n),
      shipperId: shipperId,
      carrierName: carrier,
      carrierRating: rating,
      completedTrips: trips,
      fare: fare,
      estimatedDeliveryDays: days,
      vehicleType: vehicle,
      status: status,
      createdAt: at,
      note: note,
      carrierPhone: phone,
      vehicleNumber: plate,
    );

    // LOD-1001 · Kathmandu → Pokhara · In transit · Rs. 18,000
    // Picked up a few hours ago and still on the road whenever it's seeded.
    final p1001 = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
    ).subtract(const Duration(hours: 5));
    final s1001 = Shipment(
      id: sid(1001),
      reference: 'LOD-1001',
      shipperId: shipperId,
      pickup: 'Kathmandu',
      destination: 'Pokhara',
      cargoCategory: CargoCategory.steel,
      cargoDescription: 'Steel pipes',
      weight: 10,
      weightUnit: WeightUnit.tonne,
      vehicleType: VehicleType.openTruck,
      pickupAt: p1001,
      status: ShipmentStatus.inTransit,
      agreedFare: 18000,
      bidCount: 2,
      acceptedBidId: bid(1001, 'a'),
      carrierName: 'Sagarmatha Freight',
      carrierPhone: '9801000011',
      vehicleNumber: 'Ba 2 Kha 4821',
      etaAt: p1001.add(const Duration(hours: 9)),
      contactName: 'Ram Shrestha',
      contactPhone: '9841000001',
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: p1001.add(const Duration(hours: 2)),
      timeline: [
        TimelineEntry(
          status: ShipmentStatus.awaitingBids,
          at: now.subtract(const Duration(days: 4)),
          note: 'Request posted from the mobile app',
        ),
        TimelineEntry(
          status: ShipmentStatus.confirmed,
          at: now.subtract(const Duration(days: 3)),
          note: 'Bid from Sagarmatha Freight accepted',
        ),
        TimelineEntry(
          status: ShipmentStatus.scheduled,
          at: now.subtract(const Duration(days: 2)),
          note: 'Carrier scheduled the pickup',
        ),
        TimelineEntry(
          status: ShipmentStatus.inTransit,
          at: p1001.add(const Duration(minutes: 30)),
          note: 'Picked up in Kathmandu. Sample update: passed Mugling',
        ),
      ],
    );

    // LOD-1002 · Birgunj → Kathmandu · Awaiting bids · 3 bids
    final s1002 = Shipment(
      id: sid(1002),
      reference: 'LOD-1002',
      shipperId: shipperId,
      pickup: 'Birgunj',
      destination: 'Kathmandu',
      cargoCategory: CargoCategory.cement,
      cargoDescription: 'Cement',
      weight: 12,
      weightUnit: WeightUnit.tonne,
      vehicleType: VehicleType.openTruck,
      pickupAt: day(2, 9),
      status: ShipmentStatus.awaitingBids,
      bidCount: 3,
      contactName: 'Sita Thapa',
      contactPhone: '9845000002',
      notes: 'Bagged cement, 240 bags. Keep dry.',
      createdAt: now.subtract(const Duration(hours: 3)),
      updatedAt: now.subtract(const Duration(minutes: 12)),
      timeline: [
        TimelineEntry(
          status: ShipmentStatus.awaitingBids,
          at: now.subtract(const Duration(hours: 3)),
          note: 'Request posted from the mobile app',
        ),
      ],
    );

    // LOD-1003 · Butwal → Narayanghat · Delivered · Rs. 12,500
    final p1003 = day(-6, 8);
    final s1003 = Shipment(
      id: sid(1003),
      reference: 'LOD-1003',
      shipperId: shipperId,
      pickup: 'Butwal',
      destination: 'Narayanghat',
      cargoCategory: CargoCategory.foodGrains,
      cargoDescription: 'Rice sacks',
      weight: 8,
      weightUnit: WeightUnit.tonne,
      vehicleType: VehicleType.openTruck,
      pickupAt: p1003,
      status: ShipmentStatus.delivered,
      agreedFare: 12500,
      bidCount: 2,
      acceptedBidId: bid(1003, 'a'),
      carrierName: 'Lumbini Movers',
      carrierPhone: '9801000033',
      vehicleNumber: 'Lu 3 Kha 552',
      etaAt: p1003.add(const Duration(hours: 9)),
      contactName: 'Gopal KC',
      contactPhone: '9847000003',
      createdAt: now.subtract(const Duration(days: 9)),
      updatedAt: p1003.add(const Duration(hours: 9)),
      timeline: [
        TimelineEntry(
          status: ShipmentStatus.awaitingBids,
          at: now.subtract(const Duration(days: 9)),
          note: 'Request posted from the mobile app',
        ),
        TimelineEntry(
          status: ShipmentStatus.confirmed,
          at: now.subtract(const Duration(days: 8)),
          note: 'Bid from Lumbini Movers accepted',
        ),
        TimelineEntry(
          status: ShipmentStatus.scheduled,
          at: now.subtract(const Duration(days: 7)),
          note: 'Carrier scheduled the pickup',
        ),
        TimelineEntry(
          status: ShipmentStatus.inTransit,
          at: p1003.add(const Duration(minutes: 20)),
          note: 'Picked up in Butwal',
        ),
        TimelineEntry(
          status: ShipmentStatus.delivered,
          at: p1003.add(const Duration(hours: 9)),
          note: 'Delivered in Narayanghat',
        ),
      ],
    );

    // LOD-1004 · Kathmandu → Biratnagar · Scheduled · Rs. 24,000
    final s1004 = Shipment(
      id: sid(1004),
      reference: 'LOD-1004',
      shipperId: shipperId,
      pickup: 'Kathmandu',
      destination: 'Biratnagar',
      cargoCategory: CargoCategory.furniture,
      cargoDescription: 'Furniture',
      weight: 4,
      weightUnit: WeightUnit.tonne,
      vehicleType: VehicleType.closedTruck,
      pickupAt: day(3, 7),
      status: ShipmentStatus.scheduled,
      agreedFare: 24000,
      bidCount: 2,
      acceptedBidId: bid(1004, 'a'),
      carrierName: 'Koshi Express Logistics',
      carrierPhone: '9801000044',
      vehicleNumber: 'Ko 1 Kha 7781',
      etaAt: day(5, 18),
      contactName: 'Ram Shrestha',
      contactPhone: '9841000001',
      notes: 'Fragile: wooden wardrobes and tables. Blanket wrap needed.',
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 20)),
      timeline: [
        TimelineEntry(
          status: ShipmentStatus.awaitingBids,
          at: now.subtract(const Duration(days: 2)),
          note: 'Request posted from the mobile app',
        ),
        TimelineEntry(
          status: ShipmentStatus.confirmed,
          at: now.subtract(const Duration(days: 1)),
          note: 'Bid from Koshi Express Logistics accepted',
        ),
        TimelineEntry(
          status: ShipmentStatus.scheduled,
          at: now.subtract(const Duration(hours: 20)),
          note: 'Carrier scheduled the pickup',
        ),
      ],
    );

    final bids = [
      makeBid(
        1001,
        'a',
        carrier: 'Sagarmatha Freight',
        phone: '9801000011',
        plate: 'Ba 2 Kha 4821',
        rating: 4.5,
        trips: 120,
        fare: 18000,
        days: 1,
        vehicle: VehicleType.openTruck,
        status: BidStatus.accepted,
        at: now.subtract(const Duration(days: 3, hours: 6)),
      ),
      makeBid(
        1001,
        'b',
        carrier: 'Trishuli Transport',
        phone: '9801000012',
        plate: 'Ba 3 Kha 1190',
        rating: 4.0,
        trips: 38,
        fare: 19500,
        days: 2,
        vehicle: VehicleType.openTruck,
        status: BidStatus.declined,
        at: now.subtract(const Duration(days: 3, hours: 4)),
      ),
      // The three LOD-1002 bids from the brief (third added to match "3 bids").
      makeBid(
        1002,
        'a',
        carrier: 'Himalayan Cargo',
        phone: '9801000021',
        plate: 'Na 4 Kha 1123',
        rating: 4.6,
        trips: 128,
        fare: 32000,
        days: 2,
        vehicle: VehicleType.closedTruck,
        status: BidStatus.pending,
        at: now.subtract(const Duration(hours: 2, minutes: 40)),
        note: 'Covered truck with tarpaulin. Loading labour included.',
      ),
      makeBid(
        1002,
        'b',
        carrier: 'Swift Transport',
        phone: '9801000022',
        plate: 'Ja 1 Kha 6605',
        rating: 4.1,
        trips: 54,
        fare: 29500,
        days: 3,
        vehicle: VehicleType.openTruck,
        status: BidStatus.pending,
        at: now.subtract(const Duration(hours: 1, minutes: 30)),
        note: 'Can arrive for loading early morning.',
      ),
      makeBid(
        1002,
        'c',
        carrier: 'Everest Freight Lines',
        phone: '9801000023',
        plate: 'Ba 5 Kha 3307',
        rating: 4.4,
        trips: 87,
        fare: 30800,
        days: 2,
        vehicle: VehicleType.openTruck,
        status: BidStatus.pending,
        at: now.subtract(const Duration(minutes: 12)),
        note: 'Driver runs Birgunj–Kathmandu weekly.',
      ),
      makeBid(
        1003,
        'a',
        carrier: 'Lumbini Movers',
        phone: '9801000033',
        plate: 'Lu 3 Kha 552',
        rating: 4.3,
        trips: 75,
        fare: 12500,
        days: 1,
        vehicle: VehicleType.openTruck,
        status: BidStatus.accepted,
        at: now.subtract(const Duration(days: 8, hours: 5)),
      ),
      makeBid(
        1003,
        'b',
        carrier: 'Butwal Roadways',
        phone: '9801000034',
        plate: 'Lu 2 Kha 9013',
        rating: 3.9,
        trips: 22,
        fare: 13200,
        days: 1,
        vehicle: VehicleType.openTruck,
        status: BidStatus.declined,
        at: now.subtract(const Duration(days: 8, hours: 3)),
      ),
      makeBid(
        1004,
        'a',
        carrier: 'Koshi Express Logistics',
        phone: '9801000044',
        plate: 'Ko 1 Kha 7781',
        rating: 4.7,
        trips: 164,
        fare: 24000,
        days: 2,
        vehicle: VehicleType.closedTruck,
        status: BidStatus.accepted,
        at: now.subtract(const Duration(days: 1, hours: 6)),
      ),
      makeBid(
        1004,
        'b',
        carrier: 'Mechi Carriers',
        phone: '9801000045',
        plate: 'Me 1 Kha 2246',
        rating: 4.2,
        trips: 61,
        fare: 25500,
        days: 3,
        vehicle: VehicleType.closedTruck,
        status: BidStatus.declined,
        at: now.subtract(const Duration(days: 1, hours: 3)),
      ),
    ];

    return SeedData([s1001, s1002, s1003, s1004], bids);
  }

  /// Simulated carrier bids for a newly posted load, priced around the
  /// shipper's expected fare (or a rough weight-based estimate).
  static List<Bid> simulatedBidsFor(
    Shipment shipment, {
    required DateTime now,
    required String Function() newId,
  }) {
    final base =
        shipment.expectedFare ??
        _roundTo500(9000 + 1800 * shipment.weightInTonnes);
    const offers = [
      (
        carrier: 'Annapurna Carriers',
        rating: 4.5,
        trips: 96,
        factor: 1.06,
        days: 2,
        minutes: 9,
        note: 'Experienced crew for this route.',
        phone: '9801000051',
        plate: 'Ga 1 Kha 4410',
      ),
      (
        carrier: 'Terai Roadlines',
        rating: 4.2,
        trips: 41,
        factor: 0.97,
        days: 3,
        minutes: 5,
        note: 'Flexible on pickup time.',
        phone: '9801000052',
        plate: 'Lu 1 Kha 8821',
      ),
      (
        carrier: 'Gandaki Transport Co.',
        rating: 4.7,
        trips: 152,
        factor: 1.01,
        days: 2,
        minutes: 1,
        note: 'Vehicle available from the requested pickup date.',
        phone: '9801000053',
        plate: 'Ga 2 Kha 3075',
      ),
    ];
    // Arrive a few seconds apart, as if carriers just responded, but never
    // before the load was posted.
    final window = now.difference(shipment.createdAt);
    DateTime arrival(int minutes) {
      final ideal = Duration(seconds: minutes * 4);
      final cap = window * (minutes / 10);
      return now.subtract(ideal < cap || window.isNegative ? ideal : cap);
    }

    return [
      for (final o in offers)
        Bid(
          id: newId(),
          shipmentId: shipment.id,
          shipperId: shipment.shipperId,
          carrierName: o.carrier,
          carrierRating: o.rating,
          completedTrips: o.trips,
          fare: _roundTo500(base * o.factor),
          estimatedDeliveryDays: o.days,
          vehicleType: shipment.vehicleType,
          status: BidStatus.pending,
          createdAt: arrival(o.minutes),
          note: o.note,
          carrierPhone: o.phone,
          vehicleNumber: o.plate,
        ),
    ];
  }

  static int _roundTo500(num value) =>
      ((value / 500).round() * 500).clamp(500, 1 << 31);
}
