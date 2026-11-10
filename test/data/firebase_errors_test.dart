import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/errors/app_exception.dart';
import 'package:lodbod/core/firebase/firebase_errors.dart';

void main() {
  FirebaseException firestore(String code) =>
      FirebaseException(plugin: 'cloud_firestore', code: code);
  FirebaseException auth(String code) =>
      FirebaseException(plugin: 'firebase_auth', code: code);

  test('Firestore failures become messages a shipper can act on', () {
    expect(mapFirebaseError(firestore('unavailable')), isA<NetworkException>());
    expect(
      mapFirebaseError(firestore('permission-denied')),
      isA<PermissionException>(),
    );
    expect(mapFirebaseError(firestore('not-found')), isA<NotFoundException>());
    expect(mapFirebaseError(firestore('internal')), isA<UnexpectedException>());
  });

  test('sign-in failures never reveal whether an account exists', () {
    for (final code in ['user-not-found', 'wrong-password', 'invalid-email']) {
      expect(
        mapFirebaseError(auth(code)),
        isA<InvalidCredentialsException>(),
        reason: code,
      );
    }
    expect(
      mapFirebaseError(auth('email-already-in-use')),
      isA<EmailTakenException>(),
    );
    expect(
      mapFirebaseError(auth('network-request-failed')),
      isA<NetworkException>(),
    );
  });

  test('non-Firebase errors fall back to the domain mapping', () {
    const limit = RequestLimitReachedException();
    expect(mapFirebaseError(limit), same(limit));
    expect(mapFirebaseError(TimeoutException('slow')), isA<NetworkException>());
    expect(mapFirebaseError(StateError('x')), isA<UnexpectedException>());
  });
}
