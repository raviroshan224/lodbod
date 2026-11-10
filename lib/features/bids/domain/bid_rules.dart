import '../../shipments/domain/shipment.dart';
import 'bid.dart';

/// The status to show for a bid. Bids that arrived after another bid was
/// accepted (or after cancellation) may still be stored as pending; the
/// shipment is authoritative, so they are shown as not selected.
BidStatus effectiveBidStatus(Bid bid, Shipment shipment) {
  if (shipment.acceptedBidId != null) {
    return bid.id == shipment.acceptedBidId
        ? BidStatus.accepted
        : BidStatus.declined;
  }
  if (shipment.status != ShipmentStatus.awaitingBids) return BidStatus.declined;
  return bid.status;
}
