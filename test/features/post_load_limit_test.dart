import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/domain/request_limit.dart';
import 'package:lodbod/features/create_shipment/create_shipment_controller.dart';

import '../app_harness.dart';
import '../helpers.dart';

/// The request limit is checked when Post Load is opened, so nobody fills in
/// a load that can't be posted. (Submitting still checks it too: see
/// app_journey_test.)
void main() {
  setUpAll(loadInterFont);

  String pathOf(AppHarness app) =>
      app.router.routerDelegate.currentConfiguration.uri.path;

  testWidgets('at the limit, Post load explains the limit instead of opening '
      'the form', (tester) async {
    final app = await pumpApp(tester); // Sample data: 3 of 3 in use.
    await app.go('/home');

    await app.tapText('Post load'); // Tab bar action.
    expect(find.text('Request limit reached'), findsOneWidget);
    expect(find.text(RequestLimit.message), findsOneWidget);
    expect(find.textContaining('You can post a new load'), findsOneWidget);
    expect(find.textContaining('Your details are saved'), findsNothing);
    expect(find.text('Post a load'), findsNothing);
    expect(pathOf(app), '/home');

    await app.tapText('Got it');
    expect(find.text('Request limit reached'), findsNothing);

    await app.tapText('Post Load'); // The dashboard card's button.
    expect(find.text('Request limit reached'), findsOneWidget);
    expect(find.text('Post a load'), findsNothing);
    expect(pathOf(app), '/home');
    expect(tester.takeException(), isNull);
  });

  testWidgets('at the limit, post a similar load stops before the form', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final delivered = seedIdFor(app.uid, 1003);
    await app.go('/shipments/$delivered');

    await app.tapText('Post a similar load');
    expect(find.text('Request limit reached'), findsOneWidget);
    expect(find.text('Post a load'), findsNothing);
    expect(
      app.container.read(createShipmentProvider.notifier).hasUserInput,
      isFalse,
      reason: 'the form is not prefilled when it cannot be posted',
    );
  });

  testWidgets('below the limit, Post load opens the form', (tester) async {
    final app = await pumpApp(tester, withSamples: false);
    await app.go('/home');

    await app.tapText('Post load');
    expect(find.text('Post a load'), findsOneWidget);
    expect(find.text('Request limit reached'), findsNothing);
  });
}
