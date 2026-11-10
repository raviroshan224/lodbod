import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/data/models/shipment.dart';
import 'package:lodbod/data/providers.dart';
import 'package:lodbod/domain/request_limit.dart';
import 'package:lodbod/domain/shipment_draft.dart';
import 'package:lodbod/features/bids/widgets/bid_card.dart';
import 'package:lodbod/features/create_shipment/create_shipment_controller.dart';
import 'package:material_ui/material_ui.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// Drives the real app (router, shell, screens, repositories over fakes) the
/// way a person would: tapping and typing, with no shortcuts into providers
/// except to set up a long form.
void main() {
  setUpAll(loadInterFont);

  testWidgets('sign out, then log back in with a phone number', (tester) async {
    final app = await pumpApp(tester);
    await app.go('/account');

    await tester.scrollUntilVisible(
      find.text('Sign out'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await app.tapText('Sign out'); // The account screen's button.
    expect(find.text('Sign out?'), findsOneWidget);

    // The sheet's backdrop covers the tab bar: tapping a tab underneath just
    // closes the sheet and doesn't switch tabs.
    await tester.tap(find.text('Shipments'), warnIfMissed: false);
    await app.settle();
    expect(find.text('Sign out?'), findsNothing);
    expect(app.router.routerDelegate.currentConfiguration.uri.path, '/account');

    await app.tapText('Sign out');
    expect(find.text('Sign out?'), findsOneWidget);
    await app.tapText('Sign out'); // The confirmation sheet's button.

    expect(find.text('Welcome back'), findsOneWidget);
    expect(app.auth.current, isNull);
    expect(tester.takeException(), isNull); // No error during teardown.

    await tester.enterText(find.byKey(const ValueKey('phone')), '9800000001');
    await tester.enterText(
      find.byKey(const ValueKey('password')),
      'Lodbod@123',
    );
    await app.tapText('Log in');
    await app.settle();

    expect(find.text('Aarav Shrestha'), findsOneWidget);
    expect(find.text('All requests in use'), findsOneWidget);
  });

  testWidgets('compare bids, accept one, and every view agrees', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final lod1002 = seedIdFor(app.uid, 1002);

    await app.go('/shipments/$lod1002/bids');
    expect(find.text('Himalayan Cargo'), findsOneWidget);
    expect(find.text('Swift Transport'), findsOneWidget);
    expect(find.textContaining('Best'), findsNothing);

    await app.tapText('Himalayan Cargo');
    await app.tapText('Accept for Rs. 32,000');
    expect(find.text('Book Himalayan Cargo?'), findsOneWidget);
    await app.tapText('Accept for Rs. 32,000');
    await app.settle();

    // Lands on the updated shipment with the carrier assigned.
    expect(find.text('Confirmed'), findsWidgets);
    expect(find.text('Himalayan Cargo'), findsWidgets);
    expect(find.text('Rs. 32,000'), findsWidgets);

    // The bid can't be accepted twice.
    await app.go('/shipments/$lod1002/bids/${lod1002}_a');
    expect(find.text('Accept for Rs. 32,000'), findsNothing);

    // Dashboard counts moved: no more awaiting bids, still 3 of 3 in use.
    await app.go('/home');
    expect(find.bySemanticsLabel(RegExp('^0 Awaiting bids')), findsOneWidget);
    expect(find.text('All requests in use'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'at the limit, posting shows the exact message and keeps the form',
    (tester) async {
      final app = await pumpApp(tester);
      app.container
          .read(createShipmentProvider.notifier)
          .edit(
            (d) => d.copyWith(
              pickup: 'Pokhara',
              destination: 'Butwal',
              pickupDate: DateTime.now().add(const Duration(days: 2)),
              pickupTime: const PickupTime(8, 0),
              category: CargoCategory.fmcg,
              description: 'Biscuit cartons',
              weightText: '6',
              vehicleType: VehicleType.closedTruck,
            ),
          );

      await app.go('/post-load/review');
      await app.tapText('Post load');
      await app.settle();

      expect(find.textContaining(RequestLimit.message), findsWidgets);
      final draft = app.container.read(createShipmentProvider).draft;
      expect(draft.pickup, 'Pokhara');
      expect(draft.description, 'Biscuit cartons');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a bid can be accepted straight from its card', (tester) async {
    final app = await pumpApp(tester);
    final lod1002 = seedIdFor(app.uid, 1002);
    await app.go('/shipments/$lod1002/bids');

    // Every open offer has the same actions; none is marked "best".
    expect(find.text('Accept'), findsWidgets);
    expect(find.textContaining('Best'), findsNothing);
    await app.tapText('Rating'); // Himalayan Cargo (4.6) comes first.
    final himalayanAccept = find.descendant(
      of: find.ancestor(
        of: find.text('Himalayan Cargo'),
        matching: find.byType(BidCard),
      ),
      matching: find.text('Accept'),
    );
    await tester.ensureVisible(himalayanAccept);
    await tester.tap(himalayanAccept);
    await app.settle();

    expect(find.text('Book Himalayan Cargo?'), findsOneWidget);
    await app.tapText('Accept for Rs. 32,000');
    await app.settle();

    expect(find.text('Confirmed'), findsWidgets);
    await app.go('/shipments/$lod1002/bids');
    expect(find.text('Accept'), findsNothing); // Booked: no more accepting.
    expect(find.text('Accepted'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('today hides times that have passed', (tester) async {
    final app = await pumpApp(tester, withSamples: false);
    await app.go('/post-load');

    // The test clock reads 10:00: Morning (08:00) has passed, Midday hasn't.
    await app.tapText('Today');
    expect(find.text('passed'), findsOneWidget);
    expect(find.text('12:00'), findsOneWidget);

    await app.tapText('Morning');
    final draft = app.container.read(createShipmentProvider).draft;
    expect(draft.pickupTime, isNull);

    await app.tapText('Midday');
    expect(
      app.container.read(createShipmentProvider).draft.pickupTime,
      const PickupTime(12, 0),
    );
  });

  testWidgets('a finished post never reappears when returning to Home', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final lod1002 = seedIdFor(app.uid, 1002);

    await app.go('/posted/$lod1002');
    expect(find.text('Load posted'), findsOneWidget);
    await app.tapText('View request & bids');
    expect(find.text('Load posted'), findsNothing);

    await tester.pageBack();
    await app.settle();
    await app.tapText('Home');
    expect(find.text('Load posted'), findsNothing);
    expect(find.text('Aarav Shrestha'), findsOneWidget);

    app.router.push('/home/notifications');
    await app.settle();
    await tester.pageBack();
    await app.settle();
    expect(find.text('Load posted'), findsNothing);
    expect(find.text('Aarav Shrestha'), findsOneWidget);
  });

  testWidgets('post a similar load asks before replacing an unfinished form', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final delivered = seedIdFor(app.uid, 1003);
    // The samples use all 3 requests, and at the limit Post Load stops before
    // the form (see post_load_limit_test). Free a slot first.
    await tester.runAsync(
      () => app.container
          .read(shipmentRepositoryProvider)
          .cancelShipment(seedIdFor(app.uid, 1002)),
    );
    await app.settle();
    app.container
        .read(createShipmentProvider.notifier)
        .edit((d) => d.copyWith(pickup: 'Dharan'));

    await app.go('/shipments/$delivered');
    await app.tapText('Post a similar load');
    expect(find.text('Replace your unfinished load?'), findsOneWidget);

    await app.tapText('Keep it');
    expect(app.container.read(createShipmentProvider).draft.pickup, 'Dharan');
    expect(find.text('Replace your unfinished load?'), findsNothing);
  });

  testWidgets('system bar icons stay dark on every kind of screen', (
    tester,
  ) async {
    // The app is light-only; without this a phone in dark mode shows white
    // status bar icons on white screens.
    final app = await pumpApp(tester);
    for (final route in ['/home', '/shipments', '/account/help']) {
      await app.go(route);
      expect(
        SystemChrome.latestStyle?.statusBarIconBrightness,
        Brightness.dark,
        reason: route,
      );
    }
  });
}
