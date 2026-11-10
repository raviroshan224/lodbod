import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/bid_repository.dart';
import 'firestore_bid_repository.dart';

/// The feature's composition root: the only place that names the Firebase
/// implementation. Point it at another implementation to change backend.
final bidRepositoryProvider = Provider<BidRepository>(
  (ref) => FirestoreBidRepository(ref.watch(firestoreProvider)),
);
