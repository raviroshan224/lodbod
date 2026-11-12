import 'package:firebase_core/firebase_core.dart';

import '../errors/app_exception.dart';
import '../l10n/strings.dart';

/// Translates Firebase SDK errors into the domain's [AppException]s, so no
/// Firebase type ever reaches a screen. Anything else goes through
/// [mapError].
AppException mapFirebaseError(Object error) {
  if (error is! FirebaseException) return mapError(error);
  if (error.plugin == 'firebase_auth') return _mapAuthError(error.code);
  return switch (error.code) {
    'unavailable' ||
    'deadline-exceeded' ||
    'aborted' => const NetworkException(),
    'permission-denied' || 'unauthenticated' => const PermissionException(),
    'not-found' => NotFoundException(l10n.errRecordGone),
    _ => const UnexpectedException(),
  };
}

AppException _mapAuthError(String code) => switch (code) {
  'invalid-credential' ||
  'wrong-password' ||
  'user-not-found' ||
  'invalid-email' ||
  'INVALID_LOGIN_CREDENTIALS' => const InvalidCredentialsException(),
  'email-already-in-use' => const EmailTakenException(),
  'weak-password' => const WeakPasswordException(),
  'too-many-requests' => const TooManyAttemptsException(),
  'user-disabled' => const AccountDisabledException(),
  'operation-not-allowed' ||
  'configuration-not-found' => const AuthNotConfiguredException(),
  'network-request-failed' => const NetworkException(),
  _ => const UnexpectedException(),
};
