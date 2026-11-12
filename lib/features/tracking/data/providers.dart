import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/tracking_repository.dart';
import 'firestore_tracking_repository.dart';

/// Composition root for this feature; see `shipments/data/providers.dart`.
final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => FirestoreTrackingRepository(ref.watch(firestoreProvider)),
);
