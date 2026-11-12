import '../../../core/l10n/strings.dart';
import '../../../core/utils/formatters.dart';
import '../../bids/domain/bid.dart';
import '../../shipments/domain/shipment.dart';

enum ActivityKind {
  posted,
  bid,
  confirmed,
  scheduled,
  pickedUp,
  delivered,
  cancelled,
  expired,
}

/// One entry in the notifications feed. Derived from shipment timelines and
/// bids, so the feed can never disagree with the shipments themselves.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.kind,
    required this.at,
    required this.title,
    required this.body,
    required this.shipmentId,
    this.bidId,
  });

  final String id;
  final ActivityKind kind;
  final DateTime at;
  final String title;
  final String body;
  final String shipmentId;
  final String? bidId;
}

List<ActivityItem> buildActivityFeed(List<Shipment> shipments, List<Bid> bids) {
  final byId = {for (final s in shipments) s.id: s};
  final items = <ActivityItem>[];

  for (final b in bids) {
    final s = byId[b.shipmentId];
    if (s == null) continue;
    items.add(
      ActivityItem(
        id: 'bid:${b.id}',
        kind: ActivityKind.bid,
        at: b.createdAt,
        title: l10n.notifNewBid(s.reference),
        body: l10n.notifNewBidBody(
          b.carrierName,
          Fmt.npr(b.fare),
          Fmt.days(b.estimatedDeliveryDays),
        ),
        shipmentId: s.id,
        bidId: b.id,
      ),
    );
  }

  for (final s in shipments) {
    for (var i = 0; i < s.timeline.length; i++) {
      final e = s.timeline[i];
      final (kind, title, body) = switch (e.status) {
        ShipmentStatus.awaitingBids => (
          ActivityKind.posted,
          l10n.notifLive(s.reference),
          l10n.notifLiveBody(s.routeLabel),
        ),
        ShipmentStatus.confirmed => (
          ActivityKind.confirmed,
          l10n.notifConfirmed(s.reference),
          e.note.isNotEmpty ? e.note : l10n.notifConfirmedBody,
        ),
        ShipmentStatus.scheduled => (
          ActivityKind.scheduled,
          l10n.notifScheduled(s.reference),
          l10n.notifScheduledBody(
            s.carrierName ?? l10n.theCarrier,
            '${Fmt.weekdayDayMonth(s.pickupAt)}, ${Fmt.time(s.pickupAt)}',
          ),
        ),
        ShipmentStatus.inTransit => (
          ActivityKind.pickedUp,
          l10n.notifOnTheWay(s.reference),
          e.note.isNotEmpty ? e.note : l10n.notifPickedUpIn(s.pickup),
        ),
        ShipmentStatus.delivered => (
          ActivityKind.delivered,
          l10n.notifDelivered(s.reference),
          l10n.notifDeliveredIn(s.destination),
        ),
        ShipmentStatus.cancelled => (
          ActivityKind.cancelled,
          l10n.notifCancelled(s.reference),
          s.routeLabel,
        ),
        ShipmentStatus.expired => (
          ActivityKind.expired,
          l10n.notifExpired(s.reference),
          l10n.notifExpiredBody,
        ),
      };
      items.add(
        ActivityItem(
          id: 'tl:${s.id}:$i',
          kind: kind,
          at: e.at,
          title: title,
          body: body,
          shipmentId: s.id,
        ),
      );
    }
  }

  items.sort((a, b) => b.at.compareTo(a.at));
  return items;
}
