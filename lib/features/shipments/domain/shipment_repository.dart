import 'shipment.dart';

/// Shipment requests and their lifecycle. Every method throws `AppException`
/// subclasses (never SDK errors).
abstract interface class ShipmentRepository {
  /// All of the shipper's shipments, newest first, updated live.
  Stream<List<Shipment>> watchShipments(String shipperId);

  /// A fresh id for one submission attempt. Reusing it on retry makes
  /// [createShipment] idempotent.
  String newRequestId();

  /// Creates a shipment in Awaiting bids. Atomically enforces the request
  /// limit and allocates the next unique reference.
  Future<Shipment> createShipment({
    required String shipperId,
    required String requestId,
    required NewShipment input,
  });

  Future<void> cancelShipment(String shipmentId);

  /// Moves requests still awaiting bids after their pickup time to Expired,
  /// freeing their request slots. Returns how many expired. A server job in
  /// production; here it runs on the client at sign-in.
  Future<int> expireOverdueRequests(String shipperId);

  /// Moves the shipment one step along the carrier lifecycle (simulated
  /// carrier update in this build).
  Future<void> applyCarrierUpdate({
    required String shipmentId,
    required ShipmentStatus from,
  });
}
