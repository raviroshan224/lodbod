import '../data/models/shipment.dart';

class Checkpoint {
  const Checkpoint(this.name, this.fraction);
  final String name;

  /// Position along the route, 0 (pickup) to 1 (destination).
  final double fraction;
}

/// Simulated tracking derived from the shipment's schedule. There is no GPS
/// source in this build, so progress is interpolated between pickup and the
/// carrier's estimated delivery, and the UI labels it as simulated.
class TrackingInfo {
  const TrackingInfo({
    required this.progress,
    required this.checkpoints,
    required this.distanceKm,
    required this.eta,
  });

  final double progress;
  final List<Checkpoint> checkpoints;
  final int distanceKm;
  final DateTime? eta;

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

TrackingInfo trackingFor(Shipment s, {required DateTime now}) {
  final key = '${s.pickup.toLowerCase()}|${s.destination.toLowerCase()}';
  final reverseKey = '${s.destination.toLowerCase()}|${s.pickup.toLowerCase()}';
  final (km, checkpoints) = switch ((
    _knownRoutes[key],
    _knownRoutes[reverseKey],
  )) {
    ((final int d, final List<Checkpoint> c), _) => (d, c),
    (null, (final int d, final List<Checkpoint> c)) => (
      d,
      [for (final p in c.reversed) Checkpoint(p.name, 1 - p.fraction)],
    ),
    _ => (150, const [Checkpoint('En route', 0.5)]),
  };

  final progress = switch (s.status) {
    ShipmentStatus.delivered => 1.0,
    ShipmentStatus.inTransit => _transitProgress(s, now),
    _ => 0.0,
  };

  return TrackingInfo(
    progress: progress,
    checkpoints: checkpoints,
    distanceKm: km,
    eta: s.etaAt,
  );
}

double _transitProgress(Shipment s, DateTime now) {
  final start = s.reachedAt(ShipmentStatus.inTransit) ?? s.pickupAt;
  final end = s.etaAt ?? start.add(const Duration(days: 1));
  final total = end.difference(start).inMinutes;
  if (total <= 0) return 0.9;
  final done = now.difference(start).inMinutes / total;
  return done.clamp(0.05, 0.95);
}
