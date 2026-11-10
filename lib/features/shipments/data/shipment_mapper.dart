import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/firebase/firestore_schema.dart';
import '../domain/shipment.dart';

/// Converts shipments (and their timelines) to and from Firestore maps.
/// Kept out of the model so it stays backend-agnostic.
abstract final class ShipmentMapper {
  static Map<String, dynamic> toMap(Shipment s) => {
    'reference': s.reference,
    Fields.shipperId: s.shipperId,
    'pickup': s.pickup,
    'destination': s.destination,
    'cargoCategory': s.cargoCategory.name,
    'cargoDescription': s.cargoDescription,
    'weight': s.weight,
    'weightUnit': s.weightUnit.name,
    'vehicleType': s.vehicleType.name,
    'pickupAt': Timestamp.fromDate(s.pickupAt),
    Fields.status: s.status.name,
    'expectedFare': s.expectedFare,
    'agreedFare': s.agreedFare,
    'bidCount': s.bidCount,
    'acceptedBidId': s.acceptedBidId,
    'carrierName': s.carrierName,
    'carrierPhone': s.carrierPhone,
    'vehicleNumber': s.vehicleNumber,
    'etaAt': s.etaAt == null ? null : Timestamp.fromDate(s.etaAt!),
    'contactName': s.contactName,
    'contactPhone': s.contactPhone,
    'notes': s.notes,
    'timeline': s.timeline.map(timelineToMap).toList(),
    'createdAt': Timestamp.fromDate(s.createdAt),
    'updatedAt': Timestamp.fromDate(s.updatedAt),
  };

  static Map<String, dynamic> timelineToMap(TimelineEntry e) => {
    'status': e.status.name,
    'at': Timestamp.fromDate(e.at),
    'note': e.note,
  };

  /// Throws [FormatException] if a required field is missing or invalid.
  static Shipment fromMap(String id, Map<String, dynamic> m) {
    return Shipment(
      id: id,
      reference: FirestoreRead.string(m, 'reference'),
      shipperId: FirestoreRead.string(m, Fields.shipperId),
      pickup: FirestoreRead.string(m, 'pickup'),
      destination: FirestoreRead.string(m, 'destination'),
      cargoCategory: FirestoreRead.enumValue(
        m,
        'cargoCategory',
        CargoCategory.tryParse,
      ),
      cargoDescription: FirestoreRead.string(m, 'cargoDescription'),
      weight: FirestoreRead.number(m, 'weight').toDouble(),
      weightUnit: FirestoreRead.enumValue(m, 'weightUnit', WeightUnit.tryParse),
      vehicleType: FirestoreRead.enumValue(
        m,
        'vehicleType',
        VehicleType.tryParse,
      ),
      pickupAt: FirestoreRead.date(m, 'pickupAt'),
      status: FirestoreRead.enumValue(
        m,
        Fields.status,
        ShipmentStatus.tryParse,
      ),
      expectedFare: (m['expectedFare'] as num?)?.toInt(),
      agreedFare: (m['agreedFare'] as num?)?.toInt(),
      bidCount: (m['bidCount'] as num?)?.toInt() ?? 0,
      acceptedBidId: m['acceptedBidId'] as String?,
      carrierName: m['carrierName'] as String?,
      carrierPhone: m['carrierPhone'] as String?,
      vehicleNumber: m['vehicleNumber'] as String?,
      etaAt: (m['etaAt'] as Timestamp?)?.toDate(),
      contactName: m['contactName'] as String? ?? '',
      contactPhone: m['contactPhone'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
      timeline: [
        for (final raw in (m['timeline'] as List? ?? const []))
          if (raw is Map) _timelineFromMap(Map<String, dynamic>.from(raw)),
      ],
      createdAt: FirestoreRead.date(m, 'createdAt'),
      updatedAt: FirestoreRead.date(m, 'updatedAt'),
    );
  }

  static TimelineEntry _timelineFromMap(Map<String, dynamic> m) =>
      TimelineEntry(
        status: FirestoreRead.enumValue(m, 'status', ShipmentStatus.tryParse),
        at: FirestoreRead.date(m, 'at'),
        note: m['note'] as String? ?? '',
      );
}
