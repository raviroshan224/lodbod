import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/firebase/firebase_providers.dart';
import 'package:lodbod/features/shipments/presentation/shipments_providers.dart';
import 'package:lodbod/features/tracking/data/firestore_tracking_repository.dart';
import 'package:lodbod/features/tracking/domain/simulated_driver.dart';
import 'package:lodbod/features/tracking/domain/tracking.dart';
import 'package:material_ui/material_ui.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// The tracking screen follows position reports as they land in Firestore,
/// the way a second device would see them.
void main() {
  setUpAll(loadInterFont);

  Future<(AppHarness, String)> openTracking(WidgetTester tester) async {
    final app = await pumpApp(tester);
    final lod1001 = seedIdFor(app.uid, 1001); // In transit.
    await app.go('/shipments/$lod1001/track');
    return (app, lod1001);
  }

  Future<void> report(
    AppHarness app,
    String id, {
    required double progress,
    double speed = 42,
  }) async {
    final s = app.container.read(shipmentByIdProvider(id)).value!;
    final db = app.container.read(firestoreProvider) as FakeFirebaseFirestore;
    final now = DateTime.now();
    final p = LivePosition(
      progress: progress,
      speedKmh: speed,
      eta: now.add(const Duration(minutes: 45)),
      reportedAt: now,
      tripStartedAt: tripStartOf(s),
    );
    await app.tester.runAsync(
      () => db
          .collection(FirestoreTrackingRepository.collection)
          .doc(id)
          .set(FirestoreTrackingRepository.toMap(p, shipperId: s.shipperId)),
    );
    await app.settle();
  }

  testWidgets('moves with each report and says it is live', (tester) async {
    final (app, id) = await openTracking(tester);
    expect(find.text('Simulated tracking · sample route'), findsOneWidget);

    await report(app, id, progress: 0.8);
    expect(find.textContaining('Live · simulated driver'), findsOneWidget);
    expect(find.text('Damauli · 80%'), findsOneWidget);
    expect(find.textContaining('40 km remaining · 42 km/h'), findsOneWidget);

    await report(app, id, progress: 0.9, speed: 0);
    expect(find.text('Damauli · 90%'), findsOneWidget);
    expect(find.textContaining('Stopped'), findsOneWidget);

    await report(app, id, progress: 1, speed: 0);
    expect(find.text('Arrived'), findsWidgets);
    expect(find.textContaining('waiting for the carrier'), findsOneWidget);
    expect(find.textContaining('fast-forward'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fast-forward is stored for every device watching', (
    tester,
  ) async {
    final (app, id) = await openTracking(tester);
    await report(app, id, progress: 0.6);

    await tester.tap(find.byType(Switch));
    await app.settle();

    final db = app.container.read(firestoreProvider) as FakeFirebaseFirestore;
    final doc = await tester.runAsync(
      () => db.collection(FirestoreTrackingRepository.collection).doc(id).get(),
    );
    expect(doc!.data()!['speedFactor'], SimulatedDriver.fastForward);
    expect(
      find.textContaining('×${SimulatedDriver.fastForward}'),
      findsWidgets,
    );
  });
}
