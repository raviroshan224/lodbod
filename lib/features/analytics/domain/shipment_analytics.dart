import '../../shipments/domain/shipment.dart';

class RouteStat {
  const RouteStat(this.route, this.count);
  final String route;
  final int count;
}

/// Lightweight shipper analytics derived from the shipment list. Nothing is
/// stored separately, so these numbers can never disagree with the list.
class ShipmentAnalytics {
  const ShipmentAnalytics({
    required this.total,
    required this.byStatus,
    required this.committedSpend,
    required this.bookedCount,
    required this.deliveredTonnes,
    required this.totalBids,
    required this.biddedRequests,
    required this.topRoutes,
  });

  factory ShipmentAnalytics.from(List<Shipment> shipments) {
    final byStatus = {for (final s in ShipmentStatus.values) s: 0};
    var spend = 0, booked = 0, totalBids = 0, bidded = 0;
    var tonnes = 0.0;
    final routes = <String, int>{};

    for (final s in shipments) {
      byStatus[s.status] = byStatus[s.status]! + 1;
      final fare = s.agreedFare;
      if (fare != null &&
          (s.status.isActive || s.status == ShipmentStatus.delivered)) {
        spend += fare;
        booked++;
      }
      if (s.status == ShipmentStatus.delivered) tonnes += s.weightInTonnes;
      if (s.bidCount > 0) {
        totalBids += s.bidCount;
        bidded++;
      }
      routes.update(s.routeLabel, (c) => c + 1, ifAbsent: () => 1);
    }

    final top = routes.entries.map((e) => RouteStat(e.key, e.value)).toList()
      ..sort((a, b) {
        final byCount = b.count.compareTo(a.count);
        return byCount != 0 ? byCount : a.route.compareTo(b.route);
      });

    return ShipmentAnalytics(
      total: shipments.length,
      byStatus: byStatus,
      committedSpend: spend,
      bookedCount: booked,
      deliveredTonnes: tonnes,
      totalBids: totalBids,
      biddedRequests: bidded,
      topRoutes: top.take(3).toList(),
    );
  }

  final int total;
  final Map<ShipmentStatus, int> byStatus;

  /// Sum of agreed fares for booked (active or delivered) shipments.
  final int committedSpend;
  final int bookedCount;
  final double deliveredTonnes;
  final int totalBids;
  final int biddedRequests;
  final List<RouteStat> topRoutes;

  int? get averageFare =>
      bookedCount == 0 ? null : (committedSpend / bookedCount).round();
  double? get averageBids =>
      biddedRequests == 0 ? null : totalBids / biddedRequests;
}
