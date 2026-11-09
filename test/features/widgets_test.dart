import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/theme/app_theme.dart';
import 'package:lodbod/features/auth/login_screen.dart';
import 'package:lodbod/features/auth/session.dart';
import 'package:lodbod/features/shipments/shipments_providers.dart';
import 'package:lodbod/features/shipments/shipments_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../fakes.dart';
import '../helpers.dart';

void main() {
  group('LoginScreen', () {
    late ProviderContainer container;
    late FakeAuthRepository auth;

    Future<void> pumpLogin(WidgetTester tester) async {
      final db = FakeFirebaseFirestore();
      auth = FakeAuthRepository();
      await tester.runAsync(() async {
        // An existing account, signed out.
        final (c, _) = await signedInContainer(
          db,
          auth: auth,
          withSamples: false,
        );
        await c.read(authActionsProvider).signOut();
        c.dispose();
      });
      container = makeContainer(db, auth);
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const LoginScreen(),
          ),
        ),
      );
    }

    Finder field(String key) => find.byKey(ValueKey(key));

    Future<void> tapLogIn(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Log in'));
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'empty submit shows required-field errors and does not sign in',
      (tester) async {
        await pumpLogin(tester);
        await tapLogIn(tester);

        expect(find.text('Phone number is required'), findsOneWidget);
        expect(find.text('Password is required'), findsOneWidget);
        expect(auth.current, isNull);
      },
    );

    testWidgets('an invalid phone number gets a specific message', (
      tester,
    ) async {
      await pumpLogin(tester);
      await tester.enterText(field('phone'), '12345');
      await tester.enterText(field('password'), 'whatever1');
      await tapLogIn(tester);

      expect(find.textContaining('10-digit mobile number'), findsOneWidget);
    });

    testWidgets('email mode validates the email format', (tester) async {
      await pumpLogin(tester);
      await tester.tap(find.text('Email'));
      await tester.pump();
      await tester.enterText(field('email'), 'aarav@');
      await tester.enterText(field('password'), 'Lodbod@123');
      await tapLogIn(tester);

      expect(find.textContaining('Enter a valid email'), findsOneWidget);
    });

    testWidgets(
      'wrong password shows feedback; correct phone + password signs in',
      (tester) async {
        await pumpLogin(tester);
        await tester.enterText(field('phone'), '9800000001');
        await tester.enterText(field('password'), 'wrong-password');
        await tapLogIn(tester);

        expect(
          find.textContaining('Incorrect phone/email or password'),
          findsOneWidget,
        );
        expect(auth.current, isNull);

        await tester.enterText(field('password'), 'Lodbod@123');
        await tapLogIn(tester);

        expect(auth.current?.email, 'aarav@example.com');
      },
    );

    testWidgets('signs in with email too', (tester) async {
      await pumpLogin(tester);
      await tester.tap(find.text('Email'));
      await tester.pump();
      await tester.enterText(field('email'), 'Aarav@Example.com');
      await tester.enterText(field('password'), 'Lodbod@123');
      await tapLogIn(tester);

      expect(auth.current?.email, 'aarav@example.com');
    });

    testWidgets('password visibility can be toggled', (tester) async {
      await pumpLogin(tester);
      EditableText password() => tester.widget<EditableText>(
        find.descendant(
          of: field('password'),
          matching: find.byType(EditableText),
        ),
      );

      expect(password().obscureText, isTrue);
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(password().obscureText, isFalse);
    });
  });

  group('ShipmentsScreen', () {
    late ProviderContainer container;

    Future<void> pumpList(WidgetTester tester) async {
      await tester.runAsync(() async {
        (container, _) = await signedInContainer(FakeFirebaseFirestore());
      });
      addTearDown(container.dispose);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: AppTheme.light(),
            home: const ShipmentsScreen(),
          ),
        ),
      );
      // The fake Firestore stream was created in the real zone above, so let
      // real time pass for its first snapshot before settling.
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('lists all shipments, then filters by status', (tester) async {
      await pumpList(tester);
      expect(find.textContaining('4 shipments'), findsOneWidget);

      await tester.tap(find.text('Awaiting bids  1'));
      await tester.pumpAndSettle();
      expect(find.text('LOD-1002'), findsOneWidget);
      expect(find.text('LOD-1001'), findsNothing);
      expect(find.textContaining('1 shipment'), findsOneWidget);
    });

    testWidgets('search narrows results and an empty result can be cleared', (
      tester,
    ) async {
      await pumpList(tester);

      await tester.enterText(find.byType(TextField), 'pokhara');
      await tester.pumpAndSettle();
      expect(find.text('LOD-1001'), findsOneWidget);
      expect(find.textContaining('1 shipment'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'dhangadhi');
      await tester.pumpAndSettle();
      expect(find.text('No matching shipments'), findsOneWidget);

      await tester.tap(find.text('Clear search and filters'));
      await tester.pumpAndSettle();
      expect(find.textContaining('4 shipments'), findsOneWidget);
      expect(container.read(shipmentListQueryProvider).isFiltered, isFalse);
    });
  });
}
