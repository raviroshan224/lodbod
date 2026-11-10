import 'dart:math' as math;

import '../data/models/shipment.dart';
import 'tracking.dart';

/// Stands in for a driver app, which this build doesn't have: produces the
/// truck's next position report. Pure, so it can be tested; the tracking
/// repository stores each report in Firestore, where every device watching
/// the shipment receives it.
abstract final class SimulatedDriver {
  /// How often the truck reports while someone is watching it.
  static const reportInterval = Duration(seconds: 5);

  /// A report this recent is left alone, so several devices watching the
  /// same truck don't each move it.
  static const minGap = Duration(seconds: 3);

  /// Demo fast-forward: a minute of driving every second.
  static const fastForward = 60;

  /// Typical average on Nepal's highways. Used for the ETA.
  static const averageKmh = 38.0;

  /// The report after [last] at [now], or null if [s] isn't in transit.
  /// [speedFactor] switches fast-forward on (above 1) or off (1); otherwise
  /// the last report's setting carries on.
  static LivePosition? next(
    Shipment s, {
    LivePosition? last,
    required DateTime now,
    required math.Random random,
    int? speedFactor,
  }) {
    if (s.status != ShipmentStatus.inTransit) return null;
    final (km, _) = routeOf(s);
    final previous = last != null && last.belongsTo(s) ? last : null;
    final factor = speedFactor ?? previous?.speedFactor ?? 1;

    double progress;
    double speed;
    if (previous == null || !previous.isFreshAt(now)) {
      // First report, or nobody was watching for a while: the truck kept to
      // its schedule meanwhile (and never goes backwards).
      progress = math.max(scheduledProgress(s, now), previous?.progress ?? 0);
      speed = averageKmh;
    } else {
      // Drive on at the reported speed for the time since that report.
      final elapsedMs = math.max(
        0,
        now.difference(previous.reportedAt).inMilliseconds,
      );
      final hours = elapsedMs / Duration.millisecondsPerHour;
      progress =
          previous.progress +
          previous.speedKmh * previous.speedFactor * hours / km;
      speed = _nextSpeed(previous.speedKmh, random);
    }
    progress = progress.clamp(0.0, 1.0);
    if (progress >= 1) speed = 0;

    final hoursLeft = km * (1 - progress) / (averageKmh * factor);
    return LivePosition(
      progress: progress,
      speedKmh: speed,
      eta: now.add(Duration(seconds: (hoursLeft * 3600).round())),
      reportedAt: now,
      tripStartedAt: tripStartOf(s),
      speedFactor: factor,
    );
  }

  /// Wanders around the average, with the odd short stop (traffic, a police
  /// checkpoint).
  static double _nextSpeed(double current, math.Random random) {
    if (random.nextDouble() < 0.06) return 0;
    final from = current == 0 ? averageKmh : current;
    return (from + (random.nextDouble() * 2 - 1) * 6).clamp(24.0, 55.0);
  }
}
