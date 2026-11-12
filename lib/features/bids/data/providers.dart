import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/bid_repository.dart';
import 'firestore_bid_repository.dart';

/// Composition root for this feature; see `shipments/data/providers.dart`.
final bidRepositoryProvider = Provider<BidRepository>(
  (ref) => FirestoreBidRepository(ref.watch(firestoreProvider)),
);
