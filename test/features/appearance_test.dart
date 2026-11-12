import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/settings/app_settings.dart';
import 'package:lodbod/core/theme/app_colors.dart';
import 'package:lodbod/core/widgets/common.dart';
import 'package:material_ui/material_ui.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// Appearance is a static palette plus a forced rebuild, so these checks
/// guard the two ways that can go wrong: a widget keeping its old colours,
/// and a screen that only works on one background.
void main() {
  setUpAll(loadInterFont);
  tearDown(() => AppColors.brightness = Brightness.light);

  Color? wordmarkColour(WidgetTester tester) => tester
      .widget<Text>(
        find.descendant(
          of: find.byType(BrandWordmark),
          matching: find.byType(Text),
        ),
      )
      .style
      ?.color;

  testWidgets('switching appearance recolours widgets already on screen', (
    tester,
  ) async {
    final app = await pumpApp(tester, signedIn: false);
    await app.go('/login');
    final light = wordmarkColour(tester);

    await app.container
        .read(settingsProvider.notifier)
        .setAppearance(Appearance.dark);
    await app.settle();
    expect(AppColors.brightness, Brightness.dark);
    expect(wordmarkColour(tester), isNot(light));
    expect(wordmarkColour(tester), AppColors.textPrimary);

    await app.container
        .read(settingsProvider.notifier)
        .setAppearance(Appearance.light);
    await app.settle();
    expect(wordmarkColour(tester), light);
  });

  testWidgets('every main screen lays out in dark mode', (tester) async {
    final app = await pumpApp(tester);
    await app.container
        .read(settingsProvider.notifier)
        .setAppearance(Appearance.dark);
    await app.settle();
    final l1 = seedIdFor(app.uid, 1001);
    final l2 = seedIdFor(app.uid, 1002);
    for (final route in [
      '/home',
      '/shipments',
      '/shipments/$l2',
      '/shipments/$l2/bids',
      '/shipments/$l1/track',
      '/analytics',
      '/account',
      '/post-load',
    ]) {
      await app.go(route);
      expect(tester.takeException(), isNull, reason: route);
    }
  });

  test('"System" follows the platform; explicit choices override it', () {
    expect(Appearance.system.resolve(Brightness.dark), Brightness.dark);
    expect(Appearance.light.resolve(Brightness.dark), Brightness.light);
    expect(Appearance.dark.resolve(Brightness.light), Brightness.dark);
  });
}
