// Renders the README / technical-note screenshots from the real app on a
// 412×915 frame (Pixel 7 logical size) at 2x, into docs/screenshots. Skipped
// in a normal test run; generate with:
//   flutter test test/docs_screenshots_test.dart --dart-define=SCREENSHOTS=true
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/settings/app_settings.dart';
import 'package:lodbod/core/theme/app_colors.dart';
import 'package:lodbod/core/theme/app_theme.dart';
import 'package:lodbod/core/widgets/dock_nav_bar.dart';
import 'package:lodbod/features/auth/presentation/splash_screen.dart';
import 'package:lodbod/features/create_shipment/domain/shipment_draft.dart';
import 'package:lodbod/features/create_shipment/presentation/create_shipment_controller.dart';
import 'package:lodbod/features/shipments/domain/cargo.dart';
import 'package:material_ui/material_ui.dart';

import 'app_harness.dart';
import 'helpers.dart';

const out = 'docs/screenshots';
const _enabled = bool.fromEnvironment('SCREENSHOTS');

Future<void> loadDevanagari() async {
  for (final path in [
    '/System/Library/Fonts/Supplemental/DevanagariMT.ttc',
    '/System/Library/Fonts/Supplemental/Kohinoor.ttc',
  ]) {
    final f = File(path);
    if (!f.existsSync()) continue;
    try {
      await (FontLoader('Inter')
            ..addFont(Future.value(ByteData.view(f.readAsBytesSync().buffer))))
          .load();
      return;
    } catch (_) {}
  }
}

void main() {
  setUpAll(() async {
    await loadInterFont();
    await loadDevanagari();
    await loadIconFont();
  });
  tearDown(() {
    AppColors.brightness = Brightness.light;
    AppLanguage.current = AppLanguage.english;
  });

  Future<void> shot(AppHarness app, String name) =>
      app.capture('$out/$name.png');

  Future<void> fillRoute(AppHarness app) async {
    app.container
        .read(createShipmentProvider.notifier)
        .edit(
          (d) => d.copyWith(
            pickup: 'Kathmandu',
            destination: 'Birgunj',
            pickupDate: testNow.add(const Duration(days: 1)),
            pickupTime: const PickupTime(9, 0),
          ),
        );
    await app.settle();
  }

  Future<void> fillCargo(AppHarness app) async {
    app.container
        .read(createShipmentProvider.notifier)
        .edit(
          (d) => d.copyWith(
            category: CargoCategory.cement,
            description: '240 cement bags',
            weightText: '12',
          ),
        );
    await app.settle();
  }

  Future<void> fillVehicle(AppHarness app) async {
    app.container
        .read(createShipmentProvider.notifier)
        .edit(
          (d) => d.copyWith(
            vehicleType: VehicleType.openTruck,
            fareText: '30000',
            contactName: 'Ram Shrestha',
            contactPhone: '9841000001',
          ),
        );
    await app.settle();
  }

  testWidgets('01 splash', skip: !_enabled, (tester) async {
    final app = await pumpApp(tester);
    await tester.pumpWidget(
      RepaintBoundary(
        key: appBoundaryKey,
        child: UncontrolledProviderScope(
          container: app.container,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            home: const SplashScreen(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 300));
    await shot(app, '01-splash');
  });

  testWidgets('02-04 auth', skip: !_enabled, (tester) async {
    final app = await pumpApp(tester, signedIn: false);
    await app.go('/login');
    await shot(app, '02-login');
    await app.go('/register');
    await shot(app, '03-register');
    await app.go('/forgot-password');
    await shot(app, '04-forgot-password');
  });

  testWidgets('05 welcome, 15-18 posting flow', skip: !_enabled, (
    tester,
  ) async {
    final app = await pumpApp(tester, withSamples: false);
    await app.go('/home');
    await shot(app, '05-welcome');
    await app.go('/post-load');
    await fillRoute(app);
    await shot(app, '15-post-route');
    await tester.tap(find.textContaining('Continue to').first);
    await app.settle();
    await fillCargo(app);
    await shot(app, '16-post-cargo');
    await tester.tap(find.textContaining('Continue to').first);
    await app.settle();
    await fillVehicle(app);
    await shot(app, '17-post-vehicle');
    await app.go('/post-load/review');
    await shot(app, '18-review');
  });

  testWidgets('06-14, 19-24 signed in with samples', skip: !_enabled, (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final l1 = seedIdFor(app.uid, 1001);
    final l2 = seedIdFor(app.uid, 1002);
    final l4 = seedIdFor(app.uid, 1004);

    await app.go('/home');
    await shot(app, '06-home');
    await app.go('/home/notifications');
    await shot(app, '07-notifications');
    await app.go('/shipments');
    await shot(app, '08-shipments');
    await app.go('/shipments/$l2');
    await shot(app, '09-details');
    await app.go('/shipments/$l2/bids');
    await shot(app, '10-bids');
    await app.go('/shipments/$l2/bids/${l2}_a');
    await shot(app, '11-offer');
    await tester.tap(find.textContaining('Accept for').first);
    await app.settle();
    await shot(app, '12-accept-sheet');
    tester.state<NavigatorState>(find.byType(Navigator).first).pop();
    await app.settle();
    await app.go('/shipments/$l4');
    await shot(app, '13-booked');
    await app.go('/shipments/$l1/track');
    await shot(app, '14-tracking');

    await app.go('/home');
    await tester.tap(find.byKey(DockNavBar.actionKey));
    await app.settle();
    await shot(app, '19-limit');
    await app.tapText('Got it');
    await app.go('/posted/$l2');
    await shot(app, '20-posted');
    await app.go('/analytics');
    await shot(app, '21-analytics');
    await app.go('/account');
    await shot(app, '22-account');
    await app.go('/account/help');
    await shot(app, '23-help');
    await app.go('/account/profile');
    await shot(app, '24-edit-profile');
  });

  testWidgets('25-28 dark mode and Nepali', skip: !_enabled, (tester) async {
    final app = await pumpApp(tester);
    final settings = app.container.read(settingsProvider.notifier);
    await settings.setAppearance(Appearance.dark);
    await app.settle();
    await app.go('/account');
    await shot(app, '25-preferences-dark');
    await app.go('/home');
    await shot(app, '26-home-dark');

    await settings.setAppearance(Appearance.light);
    await settings.setLanguage(AppLanguage.nepali);
    await app.settle();
    await app.go('/home');
    await shot(app, '27-home-nepali');
    await app.go('/shipments/${seedIdFor(app.uid, 1002)}');
    await shot(app, '28-details-nepali');
    expect(tester.takeException(), isNull);
  });
}
