import 'user_profile.dart';

/// Sign-in and account lifecycle. The Firebase implementation lives in the
/// feature's `data/`; a REST one would satisfy the same contract. Every
/// method throws `AppException` subclasses (never SDK errors).
abstract interface class AuthRepository {
  /// Emits the signed-in user (or null) now and on every change. Sessions
  /// persist across app restarts.
  Stream<AuthUser?> authStateChanges();

  /// [email] must already be resolved (see `AccountRepository.emailForPhone`).
  Future<void> signIn({required String email, required String password});

  /// Creates the auth account and signs it in.
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  });

  Future<void> sendPasswordReset(String email);
  Future<void> sendEmailVerification();

  /// Refreshes the cached user (e.g. after the email link was opened).
  Future<AuthUser?> reload();

  /// Removes a just-created auth account when profile setup fails.
  Future<void> deleteCurrentUser();

  Future<void> signOut();
}
