import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/tracking_repository.dart';
import 'firestore_tracking_repository.dart';

/// The feature's composition root: the only place that names the Firebase
/// implementation. Point it at another implementation to change backend.
final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => FirestoreTrackingRepository(ref.watch(firestoreProvider)),
);
