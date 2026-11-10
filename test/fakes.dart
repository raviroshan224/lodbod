import 'dart:async';

import 'package:lodbod/core/errors/app_exception.dart';
import 'package:lodbod/features/auth/domain/auth_repository.dart';
import 'package:lodbod/features/auth/domain/user_profile.dart';

/// In-memory stand-in for Firebase Authentication.
class FakeAuthRepository implements AuthRepository {
  final _changes = StreamController<AuthUser?>.broadcast();
  final accounts = <String, ({String uid, String password, bool verified})>{};
  final resetEmailsSent = <String>[];
  int verificationEmailsSent = 0;
  AuthUser? _current;
  var _nextUid = 1;

  AuthUser? get current => _current;

  void _emit(AuthUser? user) {
    _current = user;
    _changes.add(user);
  }

  @override
  Stream<AuthUser?> authStateChanges() async* {
    yield _current;
    yield* _changes.stream;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    final account = accounts[email.toLowerCase()];
    if (account == null || account.password != password) {
      throw const InvalidCredentialsException();
    }
    _emit(
      AuthUser(
        uid: account.uid,
        email: email.toLowerCase(),
        emailVerified: account.verified,
      ),
    );
  }

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) async {
    final key = email.trim().toLowerCase();
    if (accounts.containsKey(key)) throw const EmailTakenException();
    final uid = 'uid-${_nextUid++}';
    accounts[key] = (uid: uid, password: password, verified: false);
    final user = AuthUser(uid: uid, email: key);
    _emit(user);
    return user;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    if (!accounts.containsKey(email)) throw const InvalidCredentialsException();
    resetEmailsSent.add(email);
  }

  @override
  Future<void> sendEmailVerification() async => verificationEmailsSent++;

  @override
  Future<AuthUser?> reload() async => _current;

  @override
  Future<void> deleteCurrentUser() async {
    final user = _current;
    if (user == null) return;
    accounts.remove(user.email);
    _emit(null);
  }

  @override
  Future<void> signOut() async => _emit(null);
}
