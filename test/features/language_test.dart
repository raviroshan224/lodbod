import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/l10n/strings.dart';
import 'package:lodbod/core/settings/app_settings.dart';
import 'package:lodbod/features/shipments/domain/request_limit.dart';
import 'package:lodbod/features/shipments/domain/shipment_status.dart';

import '../app_harness.dart';

/// Language is a static setting plus a forced rebuild (like appearance), so
/// these checks cover a screen already on display switching over, and the
/// context-free strings that domain code reads.
void main() {
  setUpAll(loadInterFont);
  tearDown(() => AppLanguage.current = AppLanguage.english);

  testWidgets('switching to Nepali relabels the screen on display', (
    tester,
  ) async {
    final app = await pumpApp(tester, signedIn: false);
    await app.go('/login');
    expect(find.text('Welcome back'), findsOneWidget);

    await app.container
        .read(settingsProvider.notifier)
        .setLanguage(AppLanguage.nepali);
    await app.settle();
    expect(AppLanguage.current, AppLanguage.nepali);
    expect(find.text('फेरि स्वागत छ'), findsOneWidget);
    expect(find.text('Welcome back'), findsNothing);
    expect(find.text('लगइन'), findsOneWidget);

    await app.container
        .read(settingsProvider.notifier)
        .setLanguage(AppLanguage.english);
    await app.settle();
    expect(find.text('Welcome back'), findsOneWidget);
    expect(find.text('फेरि स्वागत छ'), findsNothing);
  });

  testWidgets('the signed-in tabs lay out in Nepali', (tester) async {
    final app = await pumpApp(tester);
    await app.container
        .read(settingsProvider.notifier)
        .setLanguage(AppLanguage.nepali);
    await app.settle();
    for (final route in ['/home', '/shipments', '/analytics', '/account']) {
      await app.go(route);
      expect(tester.takeException(), isNull, reason: route);
    }
    expect(find.text('गृह'), findsOneWidget); // Tab label.
  });

  test('domain labels and messages follow the current language', () {
    expect(ShipmentStatus.inTransit.label, 'In transit');
    expect(RequestLimit.message, startsWith('You have reached'));
    AppLanguage.current = AppLanguage.nepali;
    expect(ShipmentStatus.inTransit.label, 'बाटोमा');
    expect(RequestLimit.message, isNot(startsWith('You have reached')));
    expect(l10n.fmtDays(1), '१ दिन');
  });

  test('every English message has a Nepali translation', () {
    final en = lookupAppLocalizations(AppLanguage.english.locale);
    final ne = lookupAppLocalizations(AppLanguage.nepali.locale);
    // A handful of spot checks; gen-l10n fails the build on missing keys.
    expect(ne.navShipments, isNot(en.navShipments));
    expect(ne.errRequestLimit, isNot(en.errRequestLimit));
    expect(ne.cargoCement, isNot(en.cargoCement));
  });
}
