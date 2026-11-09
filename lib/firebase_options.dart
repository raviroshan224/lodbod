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
    throw UnsupportedError(
      'LODBOD Shipper is configured for Android only. Run '
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
}
