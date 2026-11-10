import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'repositories/firebase/firebase_auth_repository.dart';
import 'repositories/firebase/firestore_account_repository.dart';
import 'repositories/firebase/firestore_bid_repository.dart';
import 'repositories/firebase/firestore_shipment_repository.dart';
import 'repositories/firebase/firestore_tracking_repository.dart';
import 'repositories/repositories.dart';

/// Composition root for data access. To move to a REST backend, change the
/// implementations returned here; screens and controllers only see the
/// interfaces. Tests override these providers with in-memory fakes.
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => FirebaseAuthRepository(FirebaseAuth.instance),
);

final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => FirestoreAccountRepository(ref.watch(firestoreProvider)),
);

final shipmentRepositoryProvider = Provider<ShipmentRepository>(
  (ref) => FirestoreShipmentRepository(ref.watch(firestoreProvider)),
);

final bidRepositoryProvider = Provider<BidRepository>(
  (ref) => FirestoreBidRepository(ref.watch(firestoreProvider)),
);

final trackingRepositoryProvider = Provider<TrackingRepository>(
  (ref) => FirestoreTrackingRepository(ref.watch(firestoreProvider)),
);
