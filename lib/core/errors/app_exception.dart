import 'dart:async';

/// Every failure the UI can show. Repositories translate SDK errors into one
/// of these (see `core/firebase/firebase_errors.dart`), so screens never
/// depend on Firebase types and could keep working unchanged on top of a
/// REST backend.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// Message that is safe to show to the user as-is.
  final String message;

  /// Whether retrying the same action could succeed.
  bool get isRetryable => false;

  @override
  String toString() => '$runtimeType: $message';
}

/// The shipper already has the maximum number of qualifying requests (see
/// `RequestLimit` in the shipments feature).
class RequestLimitReachedException extends AppException {
  const RequestLimitReachedException() : super(prescribedMessage);

  /// Prescribed wording from the brief. Do not paraphrase.
  static const prescribedMessage =
      'You have reached the mobile request limit of 3. Please use the LODBOD '
      'web platform to create additional requests.';
}

/// Another bid was accepted first (second tap, second device, or a retry
/// after a lost response that targeted a different bid).
class BidAlreadyAcceptedException extends AppException {
  const BidAlreadyAcceptedException()
    : super('A bid has already been accepted for this shipment.');
}

/// The action does not apply to the shipment's current status, e.g. the
/// shipment was cancelled on another device.
class InvalidStateException extends AppException {
  const InvalidStateException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException()
    : super('Incorrect phone/email or password. Please try again.');
}

class EmailTakenException extends AppException {
  const EmailTakenException()
    : super(
        'An account already exists with this email. Try logging in instead.',
      );
}

class PhoneTakenException extends AppException {
  const PhoneTakenException()
    : super('This phone number is already linked to another account.');
}

class WeakPasswordException extends AppException {
  const WeakPasswordException()
    : super('Choose a stronger password: at least 8 characters with a number.');
}

class TooManyAttemptsException extends AppException {
  const TooManyAttemptsException()
    : super('Too many attempts. Please wait a few minutes and try again.');
}

class AccountDisabledException extends AppException {
  const AccountDisabledException()
    : super('This account has been disabled. Contact LODBOD support.');
}

/// Email/password sign-in is not enabled for the Firebase project.
class AuthNotConfiguredException extends AppException {
  const AuthNotConfiguredException()
    : super("Sign-in isn't available right now. Please try again later.");
}

class NetworkException extends AppException {
  const NetworkException()
    : super(
        "Couldn't reach LODBOD. Check your connection and try again. "
        "Retrying is safe and won't create duplicates.",
      );

  @override
  bool get isRetryable => true;
}

class PermissionException extends AppException {
  const PermissionException()
    : super("You don't have access to this. Try signing out and in again.");
}

class UnexpectedException extends AppException {
  const UnexpectedException()
    : super('Something went wrong. Please try again.');

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
