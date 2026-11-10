import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/data/seed/demo_seed.dart';
import 'package:lodbod/domain/simulated_driver.dart';
import 'package:lodbod/domain/tracking.dart';

void main() {
  final now = DateTime(2026, 11, 7, 14);
  final seed = DemoSeed.build(shipperId: 'u1', now: now);
  final lod1001 = seed.shipments.firstWhere((s) => s.reference == 'LOD-1001');
  final delivered = seed.shipments.firstWhere((s) => s.reference == 'LOD-1003');
  const km = 200; // Kathmandu → Pokhara.

  LivePosition report({
    required double progress,
    double speed = 40,
    Duration ago = const Duration(minutes: 1),
    int factor = 1,
    DateTime? tripStart,
  }) => LivePosition(
    progress: progress,
    speedKmh: speed,
    eta: now.add(const Duration(hours: 2)),
    reportedAt: now.subtract(ago),
    tripStartedAt: tripStart ?? tripStartOf(lod1001),
    speedFactor: factor,
  );

  LivePosition next(LivePosition? last, {int? speedFactor}) =>
      SimulatedDriver.next(
        lod1001,
        last: last,
        now: now,
        random: math.Random(7),
        speedFactor: speedFactor,
      )!;

  group('SimulatedDriver', () {
    test('the first report starts where the schedule says', () {
      final first = next(null);
      expect(first.progress, scheduledProgress(lod1001, now));
      expect(first.speedKmh, SimulatedDriver.averageKmh);
      expect(first.tripStartedAt, tripStartOf(lod1001));
      expect(first.reportedAt, now);
      expect(first.eta.isAfter(now), isTrue);
    });

    test('drives on at the reported speed for the time since', () {
      final moved = next(report(progress: 0.5, speed: 40));
      expect(moved.progress, closeTo(0.5 + 40 / 60 / km, 1e-9));
    });

    test('a stopped truck stays put', () {
      expect(next(report(progress: 0.5, speed: 0)).progress, 0.5);
    });

    test('fast-forward covers more ground and brings the ETA closer', () {
      final fast = next(report(progress: 0.5, factor: 60));
      expect(fast.progress, closeTo(0.5 + 40 / km, 1e-9)); // 40 km in 1 min.
      expect(fast.speedFactor, 60);
      final remainingHours = km * (1 - fast.progress) / (38.0 * 60);
      expect(
        fast.eta.difference(now).inSeconds,
        closeTo(remainingHours * 3600, 1),
      );
    });

    test('switching fast-forward applies from the next report', () {
      expect(next(report(progress: 0.5), speedFactor: 60).speedFactor, 60);
      expect(
        next(report(progress: 0.5, factor: 60), speedFactor: 1).speedFactor,
        1,
      );
    });

    test('stops at the destination', () {
      final there = next(report(progress: 0.99, speed: 50, factor: 60));
      expect(there.progress, 1);
      expect(there.speedKmh, 0);
      expect(there.eta, now);
    });

    test('a report from an earlier trip is ignored', () {
      final old = report(
        progress: 0.9,
        tripStart: tripStartOf(lod1001).subtract(const Duration(days: 3)),
      );
      expect(next(old).progress, scheduledProgress(lod1001, now));
    });

    test('after a gap the truck catches up to schedule, never backwards', () {
      final stale = const Duration(minutes: 10);
      final behind = next(report(progress: 0.1, ago: stale));
      expect(behind.progress, scheduledProgress(lod1001, now));
      final ahead = next(report(progress: 0.97, ago: stale));
      expect(ahead.progress, 0.97);
    });

    test('nothing to report unless in transit', () {
      expect(
        SimulatedDriver.next(delivered, now: now, random: math.Random(1)),
        isNull,
      );
    });

    test('speed stays in a believable range', () {
      var last = report(progress: 0.2, ago: const Duration(seconds: 5));
      final random = math.Random(3);
      for (var i = 0; i < 200; i++) {
        final r = SimulatedDriver.next(
          lod1001,
          last: last,
          now: last.reportedAt.add(SimulatedDriver.reportInterval),
          random: random,
        )!;
        expect(
          r.speedKmh == 0 || (r.speedKmh >= 24 && r.speedKmh <= 55),
          isTrue,
        );
        last = r;
      }
    });
  });

  group('trackingFor with live reports', () {
    test('a fresh report sets position and ETA', () {
      final r = report(progress: 0.8, ago: const Duration(seconds: 4));
      final t = trackingFor(lod1001, now: now, live: r);
      expect(t.live, same(r));
      expect(t.progress, 0.8);
      expect(t.eta, r.eta);
      expect(t.lastPassed?.name, 'Damauli');
    });

    test('a stale report falls back to the schedule, never behind it', () {
      final stale = const Duration(minutes: 5);
      final behind = trackingFor(
        lod1001,
        now: now,
        live: report(progress: 0.1, ago: stale),
      );
      expect(behind.live, isNull);
      expect(behind.progress, scheduledProgress(lod1001, now));
      expect(behind.eta, lod1001.etaAt);
      final ahead = trackingFor(
        lod1001,
        now: now,
        live: report(progress: 0.97, ago: stale),
      );
      expect(ahead.progress, 0.97);
    });

    test('at the destination it has arrived and is not late', () {
      final t = trackingFor(
        lod1001,
        now: now.add(const Duration(days: 2)),
        live: report(progress: 1, speed: 0, ago: const Duration(days: -2)),
      );
      expect(t.arrived, isTrue);
      expect(t.isLate, isFalse);
    });

    test('reports are ignored once the shipment is delivered', () {
      final t = trackingFor(
        delivered,
        now: now,
        live: report(progress: 0.3, ago: Duration.zero),
      );
      expect(t.progress, 1);
      expect(t.live, isNull);
    });
  });
}
