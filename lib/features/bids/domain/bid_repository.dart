import 'bid.dart';

/// Carrier bids on shipments. Every method throws `AppException` subclasses
/// (never SDK errors).
abstract interface class BidRepository {
  /// Bids on one shipment, oldest first, updated live.
  Stream<List<Bid>> watchBids({
    required String shipmentId,
    required String shipperId,
  });

  /// Every bid on the shipper's shipments (for the activity feed).
  Stream<List<Bid>> watchBidsForShipper(String shipperId);

  /// Accepts [bidId], declines the other bids and confirms the shipment in a
  /// single transaction. Idempotent for the same bid.
  Future<void> acceptBid({required String shipmentId, required String bidId});

  /// Adds simulated carrier bids to a shipment with no bids yet.
  Future<int> simulateIncomingBids(String shipmentId);
}
