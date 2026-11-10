import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/errors/app_exception.dart';
import 'package:lodbod/features/account/data/providers.dart';
import 'package:lodbod/features/auth/domain/user_profile.dart';
import 'package:lodbod/features/auth/presentation/session.dart';
import 'package:lodbod/features/create_shipment/domain/shipment_draft.dart';
import 'package:lodbod/features/create_shipment/presentation/create_shipment_controller.dart';
import 'package:lodbod/features/shipments/domain/shipment.dart';
import 'package:lodbod/features/shipments/presentation/shipments_providers.dart';
import 'package:lodbod/routing/app_router.dart';
import 'package:lodbod/routing/routes.dart';

import '../fakes.dart';
import '../helpers.dart';

void main() {
  late FakeFirebaseFirestore db;
  late FakeAuthRepository auth;

  setUp(() {
    db = FakeFirebaseFirestore();
    auth = FakeAuthRepository();
  });

  group('registration', () {
    test(
      'creates the account, shipper profile and phone sign-in index',
      () async {
        final (container, uid) = await signedInContainer(
          db,
          auth: auth,
          withSamples: false,
        );
        addTearDown(container.dispose);

        final session = container.read(sessionProvider) as SessionReady;
        expect(session.profile.name, 'Aarav Shrestha');
        expect(session.profile.role, 'shipper');
        expect(
          (await db.collection('phoneIndex').doc('9800000001').get()).data(),
          {'uid': uid, 'email': 'aarav@example.com'},
        );
        expect(auth.verificationEmailsSent, 1);
      },
    );

    test(
      'a phone number already in use is rejected and no account is left behind',
      () async {
        final (first, _) = await signedInContainer(
          db,
          auth: auth,
          withSamples: false,
        );
        await first.read(authActionsProvider).signOut();
        first.dispose();

        final container = makeContainer(db, auth);
        addTearDown(container.dispose);
        await expectLater(
          container
              .read(authActionsProvider)
              .register(
                const Registration(
                  name: 'Sita',
                  phone: '9800000001',
                  email: 'sita@example.com',
                  company: '',
                  password: 'Sita@1234',
                ),
              ),
          throwsA(isA<PhoneTakenException>()),
        );
        expect(auth.accounts.containsKey('sita@example.com'), isFalse);
      },
    );

    test('an email already in use is rejected', () async {
      final (first, _) = await signedInContainer(
        db,
        auth: auth,
        withSamples: false,
      );
      await first.read(authActionsProvider).signOut();
      first.dispose();

      final container = makeContainer(db, auth);
      addTearDown(container.dispose);
      await expectLater(
        container
            .read(authActionsProvider)
            .register(
              const Registration(
                name: 'Other',
                phone: '9811111111',
                email: 'aarav@example.com',
                company: '',
                password: 'Other@1234',
              ),
            ),
        throwsA(isA<EmailTakenException>()),
      );
    });
  });

  group('sign in', () {
    late AuthActions actions;

    setUp(() async {
      final (first, _) = await signedInContainer(
        db,
        auth: auth,
        withSamples: false,
      );
      await first.read(authActionsProvider).signOut();
      first.dispose();
      final container = makeContainer(db, auth);
      addTearDown(container.dispose);
      actions = container.read(authActionsProvider);
    });

    test('with a phone number resolves the account email', () async {
      await actions.signIn(
        identifier: '+977 98-0000-0001',
        password: 'Lodbod@123',
      );
      expect(auth.current?.email, 'aarav@example.com');
    });

    test(
      'with an unknown phone number gives the generic credentials error',
      () async {
        await expectLater(
          actions.signIn(identifier: '9811111111', password: 'Lodbod@123'),
          throwsA(isA<InvalidCredentialsException>()),
        );
      },
    );

    test('password reset never reveals whether an account exists', () async {
      await actions.sendPasswordReset('9800000001');
      await actions.sendPasswordReset('nobody@example.com');
      await actions.sendPasswordReset('9811111111');
      expect(auth.resetEmailsSent, ['aarav@example.com']);
    });
  });

  group('profile', () {
    test('changing the phone number moves the sign-in index; a taken number is refused', () async {
      final (container, uid) = await signedInContainer(
        db,
        auth: auth,
        withSamples: false,
      );
      addTearDown(container.dispose);
      await db.collection('phoneIndex').doc('9822222222').set({
        'uid': 'someone-else',
        'email': 'x@example.com',
      });
      final accounts = container.read(accountRepositoryProvider);
      final profile = container.read(currentUserProvider);

      await accounts.updateProfile(
        profile.copyWith(phone: '9844444444'),
        previousPhone: profile.phone,
      );
      expect(
        (await db.collection('phoneIndex').doc('9800000001').get()).exists,
        isFalse,
      );
      expect(
        (await db.collection('phoneIndex').doc('9844444444').get())
            .data()?['uid'],
        uid,
      );

      await expectLater(
        accounts.updateProfile(
          profile.copyWith(phone: '9822222222'),
          previousPhone: '9844444444',
        ),
        throwsA(isA<PhoneTakenException>()),
      );
    });

    test('opening notifications marks activity as read', () async {
      final (container, uid) = await signedInContainer(db, auth: auth);
      addTearDown(container.dispose);
      container.listen(unreadActivityCountProvider, (_, _) {});
      await container.read(shipmentsProvider.future);
      await container.read(shipperBidsProvider.future);

      await container
          .read(accountRepositoryProvider)
          .markNotificationsSeen(uid);
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(container.read(unreadActivityCountProvider), 0);
    });
  });

  group('saved drafts', () {
    test(
      'a saved draft is restored into an empty form, then cleared on reset',
      () async {
        final (container, uid) = await signedInContainer(
          db,
          auth: auth,
          withSamples: false,
        );
        addTearDown(container.dispose);
        final controller = container.read(createShipmentProvider.notifier);
        controller.edit(
          (d) => d.copyWith(
            pickup: 'Pokhara',
            destination: 'Butwal',
            category: CargoCategory.fmcg,
            pickupTime: const PickupTime(8, 0),
            weightText: '6',
          ),
        );
        await controller.saveDraft();

        // A fresh form (e.g. another device) picks the draft up.
        controller.reset();
        await Future<void>.delayed(const Duration(milliseconds: 10));
        expect(
          await controller.restoreSavedDraft(),
          isFalse,
          reason: 'reset also clears the saved copy',
        );

        controller.edit((d) => d.copyWith(pickup: 'Pokhara', weightText: '6'));
        await controller.saveDraft();
        final fresh = makeContainer(db, auth);
        addTearDown(fresh.dispose);
        await waitForReady(fresh);
        expect(
          await fresh.read(createShipmentProvider.notifier).restoreSavedDraft(),
          isTrue,
        );
        expect(fresh.read(createShipmentProvider).draft.pickup, 'Pokhara');
        expect(fresh.read(createShipmentProvider).draft.weightText, '6');
      },
    );
  });

  group('routing rules', () {
    const user = AuthUser(uid: 'u1', email: 'a@example.com');
    const verified = AuthUser(
      uid: 'u1',
      email: 'a@example.com',
      emailVerified: true,
    );
    const profile = UserProfile(
      id: 'u1',
      name: 'A',
      company: '',
      phone: '9800000001',
      email: 'a@example.com',
    );

    test('signed-out users only reach the auth screens', () {
      expect(redirectFor(const SessionSignedOut(), Routes.home), Routes.login);
      expect(redirectFor(const SessionSignedOut(), Routes.register), isNull);
      expect(redirectFor(const SessionSignedOut(), Routes.terms), isNull);
    });

    test('signed-in shippers skip the auth screens', () {
      expect(
        redirectFor(const SessionReady(verified, profile), Routes.login),
        Routes.home,
      );
      expect(
        redirectFor(
          const SessionReady(verified, profile),
          Routes.shipment('x'),
        ),
        isNull,
      );
    });

    test('a fresh registration continues to email verification', () {
      expect(
        redirectFor(const SessionReady(user, profile), Routes.register),
        Routes.verifyEmail,
      );
      expect(
        redirectFor(const SessionNeedsProfile(user), Routes.register),
        isNull,
      );
      expect(
        redirectFor(const SessionNeedsProfile(user), Routes.home),
        Routes.completeProfile,
      );
    });

    test('non-shipper accounts are sent back to login', () {
      expect(redirectFor(const SessionWrongRole(), Routes.home), Routes.login);
    });

    test('a profile that fails to load is explained on the splash screen', () {
      const failed = SessionProfileError(PermissionException());
      expect(redirectFor(failed, Routes.home), Routes.splash);
      expect(redirectFor(failed, Routes.splash), isNull);
    });
  });

  group('session edge cases', () {
    test('a profile load error ends loading instead of hanging', () async {
      final container = ProviderContainer(
        overrides: [
          ...testOverrides(db, auth),
          profileProvider.overrideWith(
            (ref) => Stream.error(const PermissionException()),
          ),
        ],
        retry: (_, _) => null,
      );
      addTearDown(container.dispose);
      container.listen(sessionProvider, (_, _) {});
      await auth.createAccount(email: 'a@example.com', password: 'Lodbod@123');

      Session session = const SessionLoading();
      for (var i = 0; i < 100 && session is! SessionProfileError; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 5));
        session = container.read(sessionProvider);
      }
      expect(session, isA<SessionProfileError>());
      expect(
        (session as SessionProfileError).error,
        isA<PermissionException>(),
      );
    });

    test(
      'signing out while screens still watch the user does not throw',
      () async {
        final (container, uid) = await signedInContainer(db, auth: auth);
        addTearDown(container.dispose);
        final errors = <Object>[];
        container.listen(
          currentUserProvider,
          (_, _) {},
          onError: (e, _) => errors.add(e),
        );

        await container.read(authActionsProvider).signOut();
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(container.read(sessionProvider), isA<SessionSignedOut>());
        expect(container.read(currentUserProvider).id, uid);
        expect(errors, isEmpty);
      },
    );
  });
}
