import 'package:firebase_auth/firebase_auth.dart';

import '../../models/user_profile.dart';
import '../repositories.dart';
import 'firestore_guard.dart';

/// Email + password accounts on Firebase Authentication. Sessions are
/// persisted by the SDK, so a signed-in shipper stays signed in across
/// restarts until they sign out.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  static AuthUser? _toAuthUser(User? user) => user == null
      ? null
      : AuthUser(
          uid: user.uid,
          email: user.email ?? '',
          emailVerified: user.emailVerified,
        );

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.userChanges().map(_toAuthUser).transform(mapStreamErrors());

  @override
  Future<void> signIn({required String email, required String password}) =>
      guarded(
        () => _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        ),
      );

  @override
  Future<AuthUser> createAccount({
    required String email,
    required String password,
  }) => guarded(() async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return _toAuthUser(credential.user)!;
  });

  @override
  Future<void> sendPasswordReset(String email) =>
      guarded(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> sendEmailVerification() => guarded(() async {
    await _auth.currentUser?.sendEmailVerification();
  });

  @override
  Future<AuthUser?> reload() => guarded(() async {
    await _auth.currentUser?.reload();
    return _toAuthUser(_auth.currentUser);
  });

  @override
  Future<void> deleteCurrentUser() => guarded(() async {
    await _auth.currentUser?.delete();
  });

  @override
  Future<void> signOut() => guarded(_auth.signOut);
}
