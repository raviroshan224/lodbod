import '../../../core/utils/formatters.dart';
import 'cargo.dart';
import 'shipment_status.dart';

export 'cargo.dart';
export 'shipment_status.dart';

/// One step in a shipment's history.
class TimelineEntry {
  const TimelineEntry({required this.status, required this.at, this.note = ''});

  final ShipmentStatus status;
  final DateTime at;

  /// Human-readable context, e.g. "Bid from Himalayan Cargo accepted".
  final String note;
}

/// A shipper's request to move cargo. Plain Dart: storage mapping lives in
/// the data layer, so this model is backend-agnostic.
class Shipment {
  const Shipment({
    required this.id,
    required this.reference,
    required this.shipperId,
    required this.pickup,
    required this.destination,
    required this.cargoCategory,
    required this.cargoDescription,
    required this.weight,
    required this.weightUnit,
    required this.vehicleType,
    required this.pickupAt,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.expectedFare,
    this.agreedFare,
    this.bidCount = 0,
    this.acceptedBidId,
    this.carrierName,
    this.carrierPhone,
    this.vehicleNumber,
    this.etaAt,
    this.contactName = '',
    this.contactPhone = '',
    this.notes = '',
    this.timeline = const [],
  });

  final String id;

  /// Human-facing unique reference, e.g. "LOD-1005".
  final String reference;
  final String shipperId;
  final String pickup;
  final String destination;
  final CargoCategory cargoCategory;
  final String cargoDescription;
  final double weight;
  final WeightUnit weightUnit;
  final VehicleType vehicleType;
  final DateTime pickupAt;
  final ShipmentStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Shipper's optional budget, in NPR.
  final int? expectedFare;

  /// Fare of the accepted bid, in NPR.
  final int? agreedFare;
  final int bidCount;
  final String? acceptedBidId;
  final String? carrierName;
  final String? carrierPhone;
  final String? vehicleNumber;

  /// Estimated delivery, from the accepted bid (pickup + carrier estimate).
  final DateTime? etaAt;
  final String contactName;
  final String contactPhone;
  final String notes;
  final List<TimelineEntry> timeline;

  String get routeLabel => '$pickup → $destination';
  String get weightLabel => '${Fmt.number(weight)} ${weightUnit.symbol}';
  double get weightInTonnes => weightUnit.toTonnes(weight);
  bool get hasAcceptedBid => acceptedBidId != null;

  /// Timestamp of the most recent timeline entry for [s], if any.
  DateTime? reachedAt(ShipmentStatus s) {
    DateTime? latest;
    for (final entry in timeline) {
      if (entry.status == s && (latest == null || entry.at.isAfter(latest))) {
        latest = entry.at;
      }
    }
    return latest;
  }
}

/// Validated input for creating a shipment. Produced by `ShipmentDraft`.
class NewShipment {
  const NewShipment({
    required this.pickup,
    required this.destination,
    required this.cargoCategory,
    required this.cargoDescription,
    required this.weight,
    required this.weightUnit,
    required this.vehicleType,
    required this.pickupAt,
    this.expectedFare,
    this.contactName = '',
    this.contactPhone = '',
    this.notes = '',
  });

  final String pickup;
  final String destination;
  final CargoCategory cargoCategory;
  final String cargoDescription;
  final double weight;
  final WeightUnit weightUnit;
  final VehicleType vehicleType;
  final DateTime pickupAt;
  final int? expectedFare;
  final String contactName;
  final String contactPhone;
  final String notes;
}
