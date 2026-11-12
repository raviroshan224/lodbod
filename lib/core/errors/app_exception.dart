import 'dart:async';

import '../l10n/strings.dart';

/// Every failure the UI can show. Repositories translate SDK errors into one
/// of these (see `core/firebase/firebase_errors.dart`), so screens never
/// depend on Firebase types and could keep working unchanged on top of a
/// REST backend.
sealed class AppException implements Exception {
  const AppException();

  /// Message that is safe to show to the user as-is, in the current
  /// language.
  String get message;

  /// Whether retrying the same action could succeed.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType: $message';
}

/// The shipper already has the maximum number of qualifying requests (see
/// `RequestLimit` in the shipments feature).
class RequestLimitReachedException extends AppException {
  const RequestLimitReachedException();

  /// Prescribed wording from the brief (English). Do not paraphrase.
  static const prescribedMessage =
      'You have reached the mobile request limit of 3. Please use the LODBOD '
      'web platform to create additional requests.';

  @override
  String get message => l10n.errRequestLimit;
}

/// Another bid was accepted first (second tap, second device, or a retry
/// after a lost response that targeted a different bid).
class BidAlreadyAcceptedException extends AppException {
  const BidAlreadyAcceptedException();
  @override
  String get message => l10n.errBidAlreadyAccepted;
}

/// The action does not apply to the shipment's current status, e.g. the
/// shipment was cancelled on another device.
class InvalidStateException extends AppException {
  const InvalidStateException(this.message);
  @override
  final String message;
}

class NotFoundException extends AppException {
  const NotFoundException(this.message);
  @override
  final String message;
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException();
  @override
  String get message => l10n.errInvalidCredentials;
}

class EmailTakenException extends AppException {
  const EmailTakenException();
  @override
  String get message => l10n.errEmailTaken;
}

class PhoneTakenException extends AppException {
  const PhoneTakenException();
  @override
  String get message => l10n.errPhoneTaken;
}

class WeakPasswordException extends AppException {
  const WeakPasswordException();
  @override
  String get message => l10n.errWeakPassword;
}

class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException();
  @override
  String get message => l10n.errTooManyAttempts;
}

class AccountDisabledException extends AppException {
  const AccountDisabledException();
  @override
  String get message => l10n.errAccountDisabled;
}

/// Email/password sign-in is not enabled for the Firebase project.
class AuthNotConfiguredException extends AppException {
  const AuthNotConfiguredException();
  @override
  String get message => l10n.errSignInUnavailable;
}

class NetworkException extends AppException {
  const NetworkException();
  @override
  String get message => l10n.errOffline;
  @override
  bool get isRetryable => true;
}

class PermissionException extends AppException {
  const PermissionException();
  @override
  String get message => l10n.errNoAccess;
  @override
  bool get isRetryable => true;
}

class UnexpectedException extends AppException {
  const UnexpectedException();
  @override
  String get message => l10n.errUnknown;
  @override
  bool get isRetryable => true;
}

/// Maps any thrown object to an [AppException]. Raw error details are not
/// surfaced to users and no request payloads (which may contain contact
/// details or passwords) are logged.
AppException mapError(Object error) => switch (error) {
  AppException() => error,
  TimeoutException() => const NetworkException(),
  _ => const UnexpectedException(),
};
