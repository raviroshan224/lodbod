import 'package:cloud_firestore/cloud_firestore.dart';

import '../../shipments/domain/cargo.dart';
import '../domain/shipment_draft.dart';

/// Converts the saved Post Load draft (`users/{uid}/drafts/current`) to and
/// from Firestore. Lenient on read: a draft is never rejected, only filled in.
abstract final class DraftMapper {
  static Map<String, dynamic> toMap(ShipmentDraft d) => {
    'pickup': d.pickup,
    'destination': d.destination,
    'pickupDate': d.pickupDate == null
        ? null
        : Timestamp.fromDate(d.pickupDate!),
    'pickupHour': d.pickupTime?.hour,
    'pickupMinute': d.pickupTime?.minute,
    'category': d.category?.name,
    'description': d.description,
    'weightText': d.weightText,
    'weightUnit': d.weightUnit.name,
    'vehicleType': d.vehicleType?.name,
    'fareText': d.fareText,
    'contactName': d.contactName,
    'contactPhone': d.contactPhone,
    'notes': d.notes,
    'savedAt': FieldValue.serverTimestamp(),
  };

  static ShipmentDraft fromMap(Map<String, dynamic> m) {
    final hour = (m['pickupHour'] as num?)?.toInt();
    final minute = (m['pickupMinute'] as num?)?.toInt();
    return ShipmentDraft(
      pickup: m['pickup'] as String? ?? '',
      destination: m['destination'] as String? ?? '',
      pickupDate: (m['pickupDate'] as Timestamp?)?.toDate(),
      pickupTime: hour == null || minute == null
          ? null
          : PickupTime(hour, minute),
      category: CargoCategory.tryParse(m['category'] as String?),
      description: m['description'] as String? ?? '',
      weightText: m['weightText'] as String? ?? '',
      weightUnit:
          WeightUnit.tryParse(m['weightUnit'] as String?) ?? WeightUnit.tonne,
      vehicleType: VehicleType.tryParse(m['vehicleType'] as String?),
      fareText: m['fareText'] as String? ?? '',
      contactName: m['contactName'] as String? ?? '',
      contactPhone: m['contactPhone'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
    );
  }
}
