import 'cargo.dart';

enum BidStatus {
  pending('Open'),
  accepted('Accepted'),
  declined('Not selected');

  const BidStatus(this.label);
  final String label;

  static BidStatus? tryParse(String? value) =>
      values.where((v) => v.name == value).firstOrNull;
}

/// A carrier's offer on a shipment. All carriers, ratings and fares in this
/// prototype are fictional fixtures.
class Bid {
  const Bid({
    required this.id,
    required this.shipmentId,
    required this.shipperId,
    required this.carrierName,
    required this.carrierRating,
    required this.completedTrips,
    required this.fare,
    required this.estimatedDeliveryDays,
    required this.vehicleType,
    required this.status,
    required this.createdAt,
    this.note = '',
    this.carrierPhone = '',
    this.vehicleNumber = '',
  });

  final String id;
  final String shipmentId;
  final String shipperId;
  final String carrierName;

  /// Out of 5.
  final double carrierRating;
  final int completedTrips;

  /// Offered fare in NPR.
  final int fare;
  final int estimatedDeliveryDays;
  final VehicleType vehicleType;
  final BidStatus status;
  final DateTime createdAt;
  final String note;

  /// Dispatcher contact and plate number, shared once a bid is accepted.
  final String carrierPhone;
  final String vehicleNumber;

  DateTime estimatedDeliveryFrom(DateTime pickupAt) =>
      pickupAt.add(Duration(days: estimatedDeliveryDays));
}
