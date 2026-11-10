import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/shipment_draft.dart';
import '../../models/bid.dart';
import '../../models/shipment.dart';
import '../../models/user_profile.dart';

/// Firestore collection and field names in one place.
abstract final class Col {
  static const users = 'users';
  static const shipments = 'shipments';
  static const bids = 'bids';
  static const meta = 'meta';
  static const countersDoc = 'counters';
  static const phoneIndex = 'phoneIndex';
  static const drafts = 'drafts';
  static const currentDraft = 'current';
  static const feedback = 'feedback';
}

abstract final class Fields {
  static const shipperId = 'shipperId';
  static const shipmentId = 'shipmentId';
  static const status = 'status';
  static const activeRequestCount = 'activeRequestCount';
  static const nextShipmentNumber = 'nextShipmentNumber';
  static const seedVersion = 'seedVersion';
  static const seededAt = 'seededAt';
  static const notificationsSeenAt = 'notificationsSeenAt';
}

/// Converts between models and Firestore maps. Kept out of the models so
/// they stay backend-agnostic.
abstract final class FirestoreMappers {
  static UserProfile profileFromMap(String uid, Map<String, dynamic> m) =>
      UserProfile(
        id: uid,
        name: m['name'] as String? ?? '',
        company: m['company'] as String? ?? '',
        phone: m['phone'] as String? ?? '',
        email: m['email'] as String? ?? '',
        role: m['role'] as String? ?? '',
        notificationsSeenAt: (m[Fields.notificationsSeenAt] as Timestamp?)
            ?.toDate(),
        bidAlerts: m['bidAlerts'] as bool? ?? true,
        statusAlerts: m['statusAlerts'] as bool? ?? true,
      );

  static Map<String, dynamic> draftToMap(ShipmentDraft d) => {
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

  static ShipmentDraft draftFromMap(Map<String, dynamic> m) {
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

  static Map<String, dynamic> shipmentToMap(Shipment s) => {
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
  static Shipment shipmentFromMap(String id, Map<String, dynamic> m) {
    return Shipment(
      id: id,
      reference: _string(m, 'reference'),
      shipperId: _string(m, Fields.shipperId),
      pickup: _string(m, 'pickup'),
      destination: _string(m, 'destination'),
      cargoCategory: _enum(m, 'cargoCategory', CargoCategory.tryParse),
      cargoDescription: _string(m, 'cargoDescription'),
      weight: _num(m, 'weight').toDouble(),
      weightUnit: _enum(m, 'weightUnit', WeightUnit.tryParse),
      vehicleType: _enum(m, 'vehicleType', VehicleType.tryParse),
      pickupAt: _date(m, 'pickupAt'),
      status: _enum(m, Fields.status, ShipmentStatus.tryParse),
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
      createdAt: _date(m, 'createdAt'),
      updatedAt: _date(m, 'updatedAt'),
    );
  }

  static TimelineEntry _timelineFromMap(Map<String, dynamic> m) =>
      TimelineEntry(
        status: _enum(m, 'status', ShipmentStatus.tryParse),
        at: _date(m, 'at'),
        note: m['note'] as String? ?? '',
      );

  static Map<String, dynamic> bidToMap(Bid b) => {
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

  static Bid bidFromMap(String id, Map<String, dynamic> m) => Bid(
    id: id,
    shipmentId: _string(m, Fields.shipmentId),
    shipperId: _string(m, Fields.shipperId),
    carrierName: _string(m, 'carrierName'),
    carrierRating: _num(m, 'carrierRating').toDouble(),
    completedTrips: (m['completedTrips'] as num?)?.toInt() ?? 0,
    fare: _num(m, 'fare').toInt(),
    estimatedDeliveryDays: _num(m, 'estimatedDeliveryDays').toInt(),
    vehicleType: _enum(m, 'vehicleType', VehicleType.tryParse),
    status: _enum(m, Fields.status, BidStatus.tryParse),
    createdAt: _date(m, 'createdAt'),
    note: m['note'] as String? ?? '',
    carrierPhone: m['carrierPhone'] as String? ?? '',
    vehicleNumber: m['vehicleNumber'] as String? ?? '',
  );

  static String _string(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is String && v.isNotEmpty) return v;
    throw FormatException('Missing "$key"');
  }

  static num _num(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is num) return v;
    throw FormatException('Missing "$key"');
  }

  static DateTime _date(Map<String, dynamic> m, String key) {
    final v = m[key];
    if (v is Timestamp) return v.toDate();
    throw FormatException('Missing "$key"');
  }

  static T _enum<T>(
    Map<String, dynamic> m,
    String key,
    T? Function(String?) parse,
  ) {
    final v = parse(m[key] as String?);
    if (v != null) return v;
    throw FormatException('Invalid "$key"');
  }
}
