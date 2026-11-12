import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/widgets/dock_nav_bar.dart';
import 'package:lodbod/features/create_shipment/domain/shipment_draft.dart';
import 'package:lodbod/features/create_shipment/presentation/create_shipment_controller.dart';
import 'package:lodbod/features/shipments/domain/cargo.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// Renders the main screens to PNGs for design review. Skipped unless an
/// output folder is given:
///   flutter test test/gallery --dart-define=GALLERY_DIR=/tmp/gallery
const _out = String.fromEnvironment('GALLERY_DIR');

void main() {
  setUpAll(() async {
    await loadInterFont();
    await loadIconFont();
  });

  testWidgets('signed out', skip: _out.isEmpty, (tester) async {
    final app = await pumpApp(tester, signedIn: false);
    for (final (name, route) in [
      ('a1-login', '/login'),
      ('a2-register', '/register'),
      ('a3-forgot', '/forgot-password'),
    ]) {
      await app.go(route);
      await app.capture('$_out/$name.png');
    }
  });

  testWidgets('signed in', skip: _out.isEmpty, (tester) async {
    final app = await pumpApp(tester);
    final lod1001 = seedIdFor(app.uid, 1001);
    final lod1002 = seedIdFor(app.uid, 1002);
    for (final (name, route) in [
      ('b1-home', '/home'),
      ('b2-shipments', '/shipments'),
      ('b3-details-1002', '/shipments/$lod1002'),
      ('b4-bids', '/shipments/$lod1002/bids'),
      ('b5-offer', '/shipments/$lod1002/bids/${lod1002}_a'),
      ('b6-details-1001', '/shipments/$lod1001'),
      ('b7-tracking', '/shipments/$lod1001/track'),
      ('b8-analytics', '/analytics'),
      ('b9-account', '/account'),
      ('c1-notifications', '/home/notifications'),
      ('c2-post-route', '/post-load'),
    ]) {
      await app.go(route);
      await app.capture('$_out/$name.png');
    }
    await app.tapText('Tomorrow');
    await app.tapText('Kathmandu');
    await app.capture('$_out/c3-post-route-filled.png');

    for (final (name, route) in [
      ('c4-help', '/account/help'),
      ('c5-profile', '/account/profile'),
      ('c6-posted', '/posted/$lod1002'),
      ('c7-review', '/post-load/review'),
    ]) {
      await app.go(route);
      await app.capture('$_out/$name.png');
    }
    await app.go('/shipments/$lod1002/bids');
    await app.tapText('Rating');
    await app.tapText('Accept');
    await app.capture('$_out/c8-accept-sheet.png');

    // The other Post Load steps, with the form filled in.
    final form = app.container.read(createShipmentProvider.notifier);
    await app.go('/post-load');
    await app.tapText('Tomorrow');
    form
      ..edit(
        (d) => d.copyWith(
          pickup: 'Pokhara',
          destination: 'Butwal',
          pickupTime: const PickupTime(8, 0),
          category: CargoCategory.fmcg,
          description: 'Biscuit cartons',
          weightText: '6',
        ),
      )
      ..goTo(DraftStep.cargo);
    await app.settle();
    await app.capture('$_out/c9-post-cargo.png');
    form.goTo(DraftStep.vehicle);
    await app.settle();
    await app.capture('$_out/c10-post-vehicle.png');

    // Post load at the limit: the prescribed message.
    await app.go('/home');
    await tester.tap(find.byKey(DockNavBar.actionKey));
    await app.settle();
    await app.capture('$_out/c11-limit.png');
    await app.tapText('Got it');

    // Accept an offer, then the booked shipment.
    await app.go('/shipments/$lod1002/bids');
    await app.tapText('Himalayan Cargo');
    await app.tapText('Accept for Rs. 32,000');
    await app.tapText('Accept for Rs. 32,000');
    await app.go('/shipments/$lod1002');
    await app.capture('$_out/c12-booked.png');
  });

  testWidgets('new account', skip: _out.isEmpty, (tester) async {
    final app = await pumpApp(tester, withSamples: false);
    await app.go('/home');
    await app.capture('$_out/d1-welcome.png');
  });
}
