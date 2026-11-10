import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_schema.dart';
import '../../shipments/domain/cargo.dart';
import '../domain/bid.dart';

/// Converts bids to and from Firestore maps. Kept out of the model so it
/// stays backend-agnostic.
abstract final class BidMapper {
  static Map<String, dynamic> toMap(Bid b) => {
    Fields.shipmentId: b.shipmentId,
    Fields.shipperId: b.shipperId,
    'carrierName': b.carrierName,
    'carrierRating': b.carrierRating,
    'completedTrips': b.completedTrips,
    'fare': b.fare,
    'estimatedDeliveryDays': b.estimatedDeliveryDays,
    'vehicleType': b.vehicleType.name,
    Fields.status: b.status.name,
    'createdAt': Timestamp.fromDate(b.createdAt),
    'note': b.note,
    'carrierPhone': b.carrierPhone,
    'vehicleNumber': b.vehicleNumber,
  };

  /// Throws [FormatException] if a required field is missing or invalid.
  static Bid fromMap(String id, Map<String, dynamic> m) => Bid(
    id: id,
    shipmentId: FirestoreRead.string(m, Fields.shipmentId),
    shipperId: FirestoreRead.string(m, Fields.shipperId),
    carrierName: FirestoreRead.string(m, 'carrierName'),
    carrierRating: FirestoreRead.number(m, 'carrierRating').toDouble(),
    completedTrips: (m['completedTrips'] as num?)?.toInt() ?? 0,
    fare: FirestoreRead.number(m, 'fare').toInt(),
    estimatedDeliveryDays: FirestoreRead.number(
      m,
      'estimatedDeliveryDays',
    ).toInt(),
    vehicleType: FirestoreRead.enumValue(
      m,
      'vehicleType',
      VehicleType.tryParse,
    ),
    status: FirestoreRead.enumValue(m, Fields.status, BidStatus.tryParse),
    createdAt: FirestoreRead.date(m, 'createdAt'),
    note: m['note'] as String? ?? '',
    carrierPhone: m['carrierPhone'] as String? ?? '',
    vehicleNumber: m['vehicleNumber'] as String? ?? '',
  );
}
