import 'dart:math' as math;

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/data/repositories/firebase/firestore_tracking_repository.dart';
import 'package:lodbod/data/seed/demo_seed.dart';
import 'package:lodbod/domain/simulated_driver.dart';
import 'package:lodbod/domain/tracking.dart';

void main() {
  final start = DateTime(2026, 11, 7, 9);
  final lod1001 = DemoSeed.build(
    shipperId: 'u1',
    now: start,
  ).shipments.firstWhere((s) => s.reference == 'LOD-1001');

  late FakeFirebaseFirestore db;
  late DateTime now;
  late FirestoreTrackingRepository repo;

  setUp(() {
    db = FakeFirebaseFirestore();
    now = start;
    repo = FirestoreTrackingRepository(
      db,
      clock: () => now,
      random: math.Random(1),
    );
  });

  Future<LivePosition?> stored() => repo.watchPosition(lod1001.id).first;

  /// Reports at [at]. The fake's transactions start their writes without
  /// awaiting them (real Firestore commits first), so let them land.
  Future<void> reportAt(DateTime at, {int? speedFactor}) async {
    now = at;
    await repo.reportSimulatedPosition(lod1001, speedFactor: speedFactor);
    await pumpEventQueue();
  }

  test('reports are stored with their owner and streamed back', () async {
    expect(await stored(), isNull);
    await reportAt(start);

    final doc = await db.collection('tracking').doc(lod1001.id).get();
    expect(doc.data()!['shipperId'], 'u1');
    expect(doc.data()!['source'], 'simulated');
    final p = (await stored())!;
    expect(p.progress, scheduledProgress(lod1001, start));
    expect(p.reportedAt, start);
    expect(p.belongsTo(lod1001), isTrue);
  });

  test('a second device reporting moments later does not move the truck '
      'again', () async {
    await reportAt(start);
    final first = (await stored())!;

    // Another device's tick a second later.
    await reportAt(start.add(const Duration(seconds: 1)));
    expect((await stored())!.reportedAt, first.reportedAt);

    await reportAt(start.add(SimulatedDriver.reportInterval));
    final second = (await stored())!;
    expect(second.reportedAt, now);
    expect(second.progress, greaterThan(first.progress));
  });

  test('fast-forward applies straight away and sticks', () async {
    await reportAt(start);
    await reportAt(start.add(const Duration(seconds: 1)), speedFactor: 60);
    expect((await stored())!.speedFactor, 60);

    await reportAt(start.add(const Duration(seconds: 10)));
    expect((await stored())!.speedFactor, 60);
  });

  test('a malformed document reads as no report', () async {
    await db.collection('tracking').doc(lod1001.id).set({'progress': 'x'});
    expect(await stored(), isNull);
  });
}
