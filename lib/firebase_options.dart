// Generated from android/app/google-services.json (Firebase project
// `lodbod-ravi`). Regenerate with `flutterfire configure` if the
// Firebase project changes.
//
// Firebase client keys identify the project; they are not secrets. Access is
// controlled by Firestore security rules (see firestore.rules).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return android;
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return ios;
    }
    throw UnsupportedError(
      'LODBOD Shipper is configured for Android and iOS only. Run '
      '`flutterfire configure` to add other platforms.',
    );
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWdlZ9diH1o1qFJrBX_EJaFBsUX9r8Os4',
    appId: '1:38894148510:android:ab96ed83ab752c4146d48f',
    messagingSenderId: '38894148510',
    projectId: 'lodbod-ravi',
    storageBucket: 'lodbod-ravi.firebasestorage.app',
  );

  /// Development stopgap for the iOS simulator: no iOS app is registered in
  /// `lodbod-ravi` yet, so [FirebaseOptions.appId] is a placeholder and
  /// [FirebaseOptions.apiKey] is the Android client key. Replace both with the
  /// values from the project's `GoogleService-Info.plist` before shipping iOS.
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAWdlZ9diH1o1qFJrBX_EJaFBsUX9r8Os4',
    appId: '1:38894148510:ios:0000000000000000000000',
    messagingSenderId: '38894148510',
    projectId: 'lodbod-ravi',
    storageBucket: 'lodbod-ravi.firebasestorage.app',
    iosBundleId: 'com.example.lodbod',
  );
}
