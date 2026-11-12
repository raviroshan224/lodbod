import 'dart:math' as math;

import '../../../core/l10n/strings.dart';
import '../../shipments/domain/shipment.dart';

class Checkpoint {
  const Checkpoint(this.name, this.fraction);
  final String name;

  /// Position along the route, 0 (pickup) to 1 (destination).
  final double fraction;
}

/// A position report from the truck, delivered live over Firestore. In this
/// build a simulated driver writes them (see `SimulatedDriver`); in
/// production the carrier's driver app would.
class LivePosition {
  const LivePosition({
    required this.progress,
    required this.speedKmh,
    required this.eta,
    required this.reportedAt,
    required this.tripStartedAt,
    this.speedFactor = 1,
  });

  /// Position along the route, 0 (pickup) to 1 (destination).
  final double progress;

  /// Speed when reported; 0 while stopped.
  final double speedKmh;

  /// Estimated arrival, from the distance still to go.
  final DateTime eta;
  final DateTime reportedAt;

  /// When the trip began. Ties the report to one trip, so a report left over
  /// from an earlier trip (or replaced sample data) is ignored.
  final DateTime tripStartedAt;

  /// 1 in real time. Above 1 the simulated truck is fast-forwarded (demo).
  final int speedFactor;

  /// Older reports mean nobody is reporting any more.
  static const freshFor = Duration(minutes: 2);

  bool belongsTo(Shipment s) =>
      s.status == ShipmentStatus.inTransit &&
      tripStartedAt.millisecondsSinceEpoch ==
          tripStartOf(s).millisecondsSinceEpoch;

  bool isFreshAt(DateTime now) => now.difference(reportedAt) < freshFor;
}

/// When the shipment went in transit, or its planned pickup.
DateTime tripStartOf(Shipment s) =>
    s.reachedAt(ShipmentStatus.inTransit) ?? s.pickupAt;

/// Where a shipment is along its route. Comes from live position reports
/// while they arrive, otherwise it's estimated from the schedule (pickup to
/// the carrier's ETA). The UI labels both as simulated.
class TrackingInfo {
  const TrackingInfo({
    required this.progress,
    required this.checkpoints,
    required this.distanceKm,
    required this.eta,
    this.isLate = false,
    this.live,
    this.arrived = false,
  });

  final double progress;
  final List<Checkpoint> checkpoints;
  final int distanceKm;
  final DateTime? eta;

  /// In transit past the estimated arrival. The UI then says "running late"
  /// with the date instead of showing an ETA time that has already passed.
  final bool isLate;

  /// The latest report while reports are arriving for this trip; null when
  /// the position is estimated from the schedule.
  final LivePosition? live;

  /// In transit and at the destination, waiting for delivery to be confirmed.
  final bool arrived;

  int get remainingKm => (distanceKm * (1 - progress)).round();

  /// Last checkpoint passed, or null if still at pickup.
  Checkpoint? get lastPassed {
    Checkpoint? last;
    for (final c in checkpoints) {
      if (c.fraction <= progress) last = c;
    }
    return last;
  }
}

const _knownRoutes = <String, (int, List<Checkpoint>)>{
  'kathmandu|pokhara': (
    200,
    [
      Checkpoint('Naubise', 0.15),
      Checkpoint('Mugling', 0.55),
      Checkpoint('Damauli', 0.75),
    ],
  ),
  'birgunj|kathmandu': (
    135,
    [
      Checkpoint('Pathlaiya', 0.2),
      Checkpoint('Hetauda', 0.42),
      Checkpoint('Thankot', 0.9),
    ],
  ),
  'butwal|narayanghat': (
    110,
    [Checkpoint('Daunne', 0.4), Checkpoint('Kawasoti', 0.7)],
  ),
  'kathmandu|biratnagar': (
    400,
    [
      Checkpoint('Sindhuli', 0.3),
      Checkpoint('Bardibas', 0.45),
      Checkpoint('Itahari', 0.9),
    ],
  ),
  'pokhara|butwal': (
    160,
    [Checkpoint('Syangja', 0.3), Checkpoint('Tansen', 0.62)],
  ),
};

/// Route length in km and its checkpoints, for known routes in either
/// direction; a generic route otherwise.
(int, List<Checkpoint>) routeOf(Shipment s) {
  final key = '${s.pickup.toLowerCase()}|${s.destination.toLowerCase()}';
  final reverseKey = '${s.destination.toLowerCase()}|${s.pickup.toLowerCase()}';
  return switch ((_knownRoutes[key], _knownRoutes[reverseKey])) {
    ((final int d, final List<Checkpoint> c), _) => (d, c),
    (null, (final int d, final List<Checkpoint> c)) => (
      d,
      [for (final p in c.reversed) Checkpoint(p.name, 1 - p.fraction)],
    ),
    _ => (150, [Checkpoint(l10n.trackEnRoute, 0.5)]),
  };
}

/// [live] is the latest position report, if any. It's used while fresh;
/// once reports stop, the schedule estimate takes over but never puts the
/// truck behind its last reported position.
TrackingInfo trackingFor(
  Shipment s, {
  required DateTime now,
  LivePosition? live,
}) {
  final (km, checkpoints) = routeOf(s);
  final report = live != null && live.belongsTo(s) ? live : null;
  final fresh = report != null && report.isFreshAt(now) ? report : null;

  final progress = switch (s.status) {
    ShipmentStatus.delivered => 1.0,
    ShipmentStatus.inTransit when fresh != null => fresh.progress,
    ShipmentStatus.inTransit => math.max(
      scheduledProgress(s, now),
      report?.progress ?? 0,
    ),
    _ => 0.0,
  };
  final arrived = s.status == ShipmentStatus.inTransit && progress >= 1;

  final eta = fresh?.eta ?? s.etaAt;
  return TrackingInfo(
    progress: progress,
    checkpoints: checkpoints,
    distanceKm: km,
    eta: eta,
    isLate:
        s.status == ShipmentStatus.inTransit &&
        !arrived &&
        eta != null &&
        now.isAfter(eta),
    live: fresh,
    arrived: arrived,
  );
}

/// Progress expected from the schedule alone: the share of time passed
/// between leaving and the carrier's ETA, kept short of either end.
double scheduledProgress(Shipment s, DateTime now) {
  final start = tripStartOf(s);
  final end = s.etaAt ?? start.add(const Duration(days: 1));
  final total = end.difference(start).inMinutes;
  if (total <= 0) return 0.9;
  final done = now.difference(start).inMinutes / total;
  return done.clamp(0.05, 0.95);
}
