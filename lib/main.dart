import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'firebase_options.dart';

/// Local development only: `flutter run --dart-define=USE_FIREBASE_EMULATORS=true`
/// with `firebase emulators:start --only auth,firestore`.
const _useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (_useEmulators) {
      // 10.0.2.2 is the host machine as seen from the Android emulator.
      FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
      await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    }
  } catch (error) {
    debugPrint('Firebase initialisation failed: $error');
    runApp(const StartupErrorApp());
    return;
  }
  runApp(const ProviderScope(child: LodbodApp()));
}
