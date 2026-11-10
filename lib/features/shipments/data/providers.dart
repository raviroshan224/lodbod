import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/firebase/firebase_providers.dart';
import '../domain/shipment_repository.dart';
import 'firestore_shipment_repository.dart';

/// The feature's composition root: the only place that names the Firebase
/// implementation. Point it at another implementation to change backend.
final shipmentRepositoryProvider = Provider<ShipmentRepository>(
  (ref) => FirestoreShipmentRepository(ref.watch(firestoreProvider)),
);
