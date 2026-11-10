import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/utils/validators.dart';
import '../../account/data/providers.dart';
import '../data/providers.dart';
import '../domain/user_profile.dart';

/// Where the user is in the sign-in lifecycle. Drives routing.
sealed class Session {
  const Session();
}

/// Restoring a persisted session or loading the profile.
class SessionLoading extends Session {
  const SessionLoading();
}

class SessionSignedOut extends Session {
  const SessionSignedOut();
}

/// Signed in, but the profile document doesn't exist yet (registration in
/// progress, or interrupted).
class SessionNeedsProfile extends Session {
  const SessionNeedsProfile(this.user);
  final AuthUser user;
}

/// Signed in, but the profile couldn't be loaded (no connection, missing
/// permissions). Shown on the splash screen with retry and sign-out.
class SessionProfileError extends Session {
  const SessionProfileError(this.error);
  final AppException error;
}

/// Signed in as a non-shipper account.
class SessionWrongRole extends Session {
  const SessionWrongRole();
}

class SessionReady extends Session {
  const SessionReady(this.user, this.profile);
  final AuthUser user;
  final UserProfile profile;
}

final authUserProvider = StreamProvider<AuthUser?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges(),
);

/// Uid of the signed-in user, stable across email-verification refreshes.
final currentUidProvider = Provider<String?>(
  (ref) => ref.watch(authUserProvider.select((a) => a.value?.uid)),
);

final profileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream.value(null);
  return ref.watch(accountRepositoryProvider).watchProfile(uid);
});

final sessionProvider = Provider<Session>((ref) {
  final auth = ref.watch(authUserProvider);
  if (!auth.hasValue) {
    // An auth stream error means we can't restore a session: start signed out.
    return auth.hasError ? const SessionSignedOut() : const SessionLoading();
  }
  final user = auth.value;
  if (user == null) return const SessionSignedOut();

  final profile = ref.watch(profileProvider);
  if (!profile.hasValue) {
    return profile.hasError
        ? SessionProfileError(mapError(profile.error!))
        : const SessionLoading();
  }
  final p = profile.value;
  if (p == null) return SessionNeedsProfile(user);
  if (!p.isShipper) return const SessionWrongRole();
  return SessionReady(user, p);
});

/// The signed-in shipper's profile. Only read below the auth gate.
final currentUserProvider = NotifierProvider<CurrentUser, UserProfile>(
  CurrentUser.new,
);

class CurrentUser extends Notifier<UserProfile> {
  @override
  UserProfile build() {
    final session = ref.watch(sessionProvider);
    if (session is SessionReady) return session.profile;
    // On sign-out, screens below the auth gate rebuild once more before the
    // router removes them. Keep the last profile for that frame instead of
    // failing; nothing can act on it because those screens are leaving.
    final last = stateOrNull;
    if (last != null) return last;
    throw StateError('No signed-in shipper');
  }
}

/// Injectable clock so time-based validation is testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// One-off message for the login screen (e.g. why the user was signed out).
final authNoticeProvider = NotifierProvider<AuthNotice, String?>(
  AuthNotice.new,
);

class AuthNotice extends Notifier<String?> {
  @override
  String? build() => null;
  void show(String message) => state = message;
  void clear() => state = null;
}

/// Account actions: sign in/up, password reset, profile completion.
/// Every method throws an [AppException] on failure.
class AuthActions {
  AuthActions(this._ref);
  final Ref _ref;

  /// [identifier] is an email address or a Nepali mobile number.
  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    final email = await _resolveEmail(identifier);
    if (email == null) throw const InvalidCredentialsException();
    await _ref
        .read(authRepositoryProvider)
        .signIn(email: email, password: password);
  }

  /// Creates the auth account and the shipper profile. If the profile can't
  /// be created, the auth account is removed so the email can be reused.
  Future<void> register(Registration r) async {
    final accounts = _ref.read(accountRepositoryProvider);
    final auth = _ref.read(authRepositoryProvider);
    if (await accounts.isPhoneRegistered(r.phone)) {
      throw const PhoneTakenException();
    }

    final user = await auth.createAccount(email: r.email, password: r.password);
    try {
      await accounts.createProfile(user.uid, r);
    } catch (e) {
      try {
        await auth.deleteCurrentUser();
      } catch (_) {
        // Leave the account; the user will be asked to complete the profile.
      }
      rethrow;
    }
    unawaited(auth.sendEmailVerification().catchError((_) {}));
  }

  /// For an auth account whose profile is missing (interrupted sign-up).
  Future<void> completeProfile(
    AuthUser user, {
    required String name,
    required String phone,
    required String company,
  }) {
    return _ref
        .read(accountRepositoryProvider)
        .createProfile(
          user.uid,
          Registration(
            name: name,
            phone: phone,
            email: user.email,
            company: company,
            password: '',
          ),
        );
  }

  /// Sends a reset link. Succeeds silently for unknown accounts so the
  /// screen can't be used to discover who has an account.
  Future<void> sendPasswordReset(String identifier) async {
    final email = await _resolveEmail(identifier);
    if (email == null) return;
    try {
      await _ref.read(authRepositoryProvider).sendPasswordReset(email);
    } on InvalidCredentialsException {
      return; // Unknown email: same response as success.
    }
  }

  Future<void> signOut() => _ref.read(authRepositoryProvider).signOut();

  Future<String?> _resolveEmail(String identifier) async {
    final id = identifier.trim();
    if (id.contains('@')) return id.toLowerCase();
    return _ref
        .read(accountRepositoryProvider)
        .emailForPhone(Validators.normalizePhone(id));
  }
}

final authActionsProvider = Provider<AuthActions>(AuthActions.new);
