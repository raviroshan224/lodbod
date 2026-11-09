import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:lodbod/data/models/user_profile.dart';
import 'package:lodbod/data/providers.dart';
import 'package:lodbod/features/auth/session.dart';

import 'fakes.dart';

/// Fixed "now" for deterministic date validation.
final testNow = DateTime(2026, 11, 7, 10);

const demoRegistration = Registration(
  name: 'Aarav Shrestha',
  phone: '9800000001',
  email: 'aarav@example.com',
  company: 'Himal Traders Pvt. Ltd.',
  password: 'Lodbod@123',
);

/// Overrides that swap Firebase for in-memory fakes.
List<Override> testOverrides(
  FakeFirebaseFirestore db,
  FakeAuthRepository auth,
) => [
  firestoreProvider.overrideWithValue(db),
  authRepositoryProvider.overrideWithValue(auth),
  clockProvider.overrideWithValue(() => testNow),
];

ProviderContainer makeContainer(
  FakeFirebaseFirestore db,
  FakeAuthRepository auth,
) => ProviderContainer(
  overrides: testOverrides(db, auth),
  retry: (_, _) => null,
);

/// Waits until the session reaches [SessionReady].
Future<SessionReady> waitForReady(ProviderContainer container) async {
  container.listen(sessionProvider, (_, _) {});
  for (var i = 0; i < 200; i++) {
    final s = container.read(sessionProvider);
    if (s is SessionReady) return s;
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  throw StateError(
    'Session never became ready: ${container.read(sessionProvider)}',
  );
}

/// A container with the demo shipper registered, signed in and (by default)
/// holding the sample data set.
Future<(ProviderContainer, String)> signedInContainer(
  FakeFirebaseFirestore db, {
  FakeAuthRepository? auth,
  bool withSamples = true,
}) async {
  final fakeAuth = auth ?? FakeAuthRepository();
  final container = makeContainer(db, fakeAuth);
  await container.read(authActionsProvider).register(demoRegistration);
  final ready = await waitForReady(container);
  if (withSamples) {
    await container
        .read(accountRepositoryProvider)
        .loadSampleData(ready.user.uid);
  }
  return (container, ready.user.uid);
}

String seedIdFor(String uid, int n) => 'seed_${uid}_$n';
