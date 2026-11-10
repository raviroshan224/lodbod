import '../../shipments/domain/shipment.dart';
import 'tracking.dart';

/// Live position of shipments in transit. Every method throws `AppException`
/// subclasses (never SDK errors).
abstract interface class TrackingRepository {
  /// The latest position report for a shipment, updated live on every
  /// device; null until the first report.
  Stream<LivePosition?> watchPosition(String shipmentId);

  /// Reports where an in-transit [shipment] is now, from the simulated
  /// driver (in production the carrier's driver app reports). Skipped when
  /// another device reported moments ago. [speedFactor] turns fast-forward
  /// on (above 1) or off (1).
  Future<void> reportSimulatedPosition(Shipment shipment, {int? speedFactor});
}
