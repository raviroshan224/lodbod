import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/account_repository.dart';
import 'firestore_account_repository.dart';

/// Composition root for this feature; see `shipments/data/providers.dart`.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => FirestoreAccountRepository(ref.watch(firestoreProvider)),
);
