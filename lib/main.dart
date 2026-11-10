import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

/// Local development only: `flutter run --dart-define=USE_FIREBASE_EMULATORS=true`
/// with `firebase emulators:start --only auth,firestore`.
const _useEmulators = bool.fromEnvironment('USE_FIREBASE_EMULATORS');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(AppTheme.systemBars);
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    if (_useEmulators) {
      // 10.0.2.2 is the host machine as seen from the Android emulator; the
      // iOS simulator shares the host's network.
      final host = defaultTargetPlatform == TargetPlatform.android
          ? '10.0.2.2'
          : '127.0.0.1';
      FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
      await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    }
  } catch (error) {
    debugPrint('Firebase initialisation failed: $error');
    runApp(const StartupErrorApp());
    return;
  }
  runApp(const ProviderScope(child: LodbodApp()));
}
