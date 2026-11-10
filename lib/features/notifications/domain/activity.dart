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
        title: 'New bid on ${s.reference}',
        body:
            '${b.carrierName} offered ${Fmt.npr(b.fare)} · ${Fmt.days(b.estimatedDeliveryDays)} delivery',
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
          '${s.reference} is live',
          '${s.routeLabel} · carriers can now bid',
        ),
        ShipmentStatus.confirmed => (
          ActivityKind.confirmed,
          '${s.reference} confirmed',
          e.note.isNotEmpty ? e.note : 'A carrier has been booked',
        ),
        ShipmentStatus.scheduled => (
          ActivityKind.scheduled,
          'Pickup scheduled for ${s.reference}',
          '${s.carrierName ?? 'Carrier'} · ${Fmt.weekdayDayMonth(s.pickupAt)}, ${Fmt.time(s.pickupAt)}',
        ),
        ShipmentStatus.inTransit => (
          ActivityKind.pickedUp,
          '${s.reference} is on the way',
          e.note.isNotEmpty ? e.note : 'Picked up in ${s.pickup}',
        ),
        ShipmentStatus.delivered => (
          ActivityKind.delivered,
          '${s.reference} delivered',
          'Delivered in ${s.destination}',
        ),
        ShipmentStatus.cancelled => (
          ActivityKind.cancelled,
          '${s.reference} cancelled',
          s.routeLabel,
        ),
        ShipmentStatus.expired => (
          ActivityKind.expired,
          '${s.reference} expired',
          'No carrier was booked before pickup',
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
