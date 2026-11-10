import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// Renders every screen on small phones with enlarged text and fails on any
/// layout error (overflow, unbounded size, ...). Each screen is scrolled
/// through so content below the fold is laid out too.
void main() {
  const configs = [
    (name: '320×568, text ×1.3', size: Size(320, 568), textScale: 1.3),
    (name: '360×640, text ×1.6', size: Size(360, 640), textScale: 1.6),
  ];

  setUpAll(loadInterFont);

  Future<void> scrollThrough(WidgetTester tester) async {
    for (var pass = 0; pass < 6; pass++) {
      final scrollables = find.byType(Scrollable);
      if (scrollables.evaluate().isEmpty) return;
      await tester.drag(
        scrollables.first,
        const Offset(0, -400),
        warnIfMissed: false,
      );
      await tester.pump(const Duration(milliseconds: 120));
    }
  }

  Future<void> visitAll(AppHarness app, List<String> routes, String c) async {
    for (final route in routes) {
      await app.go(route);
      await scrollThrough(app.tester);
      final error = app.tester.takeException();
      expect(error, isNull, reason: 'Layout error on $route ($c): $error');
    }
  }

  for (final c in configs) {
    group(c.name, () {
      testWidgets('signed-out screens', (tester) async {
        final app = await pumpApp(
          tester,
          size: c.size,
          textScale: c.textScale,
          signedIn: false,
        );
        await visitAll(app, [
          '/login',
          '/register',
          '/forgot-password',
          '/legal/terms',
          '/legal/privacy',
        ], c.name);
      });

      testWidgets('signed-in screens with sample data', (tester) async {
        final app = await pumpApp(tester, size: c.size, textScale: c.textScale);
        final lod1001 = seedIdFor(app.uid, 1001);
        final lod1002 = seedIdFor(app.uid, 1002);
        final lod1003 = seedIdFor(app.uid, 1003);
        final lod1004 = seedIdFor(app.uid, 1004);
        await visitAll(app, [
          '/home',
          '/home/notifications',
          '/shipments',
          '/shipments/$lod1002',
          '/shipments/$lod1002/bids',
          '/shipments/$lod1002/bids/${lod1002}_a',
          '/shipments/$lod1001',
          '/shipments/$lod1001/track',
          '/shipments/$lod1003',
          '/shipments/$lod1004',
          '/shipments/$lod1004/track',
          '/analytics',
          '/account',
          '/account/profile',
          '/account/help',
          '/post-load',
          '/post-load/review',
          '/posted/$lod1002',
        ], c.name);
      });

      testWidgets('new account with no shipments', (tester) async {
        final app = await pumpApp(
          tester,
          size: c.size,
          textScale: c.textScale,
          withSamples: false,
        );
        await visitAll(app, [
          '/home',
          '/home/notifications',
          '/shipments',
          '/analytics',
          '/account',
        ], c.name);
      });
    });
  }
}
