import '../data/models/shipment.dart';

/// Status groups used by the dashboard tiles and the list filter chips, so a
/// tile and the list it opens always count the same shipments.
enum ShipmentFilter {
  all('All'),
  awaitingBids('Awaiting bids'),
  active('Active'),
  completed('Completed'),
  closed('Cancelled / expired');

  const ShipmentFilter(this.label);
  final String label;

  bool matches(ShipmentStatus status) => switch (this) {
    all => true,
    awaitingBids => status == ShipmentStatus.awaitingBids,
    active => status.isActive,
    completed => status == ShipmentStatus.delivered,
    closed =>
      status == ShipmentStatus.cancelled || status == ShipmentStatus.expired,
  };
}

/// Search matches the reference, route and cargo. Every word in the query
/// must match somewhere, so "kathmandu pokhara" and "LOD-1001" both work.
bool matchesSearch(Shipment s, String query) {
  final tokens = query
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9-]+'))
      .where((t) => t.isNotEmpty);
  if (tokens.isEmpty) return true;
  final haystack = [
    s.reference,
    s.pickup,
    s.destination,
    s.cargoDescription,
    s.cargoCategory.label,
  ].join(' ').toLowerCase();
  return tokens.every(haystack.contains);
}

/// Newest first.
List<Shipment> sortByRecent(Iterable<Shipment> shipments) =>
    shipments.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

List<Shipment> applyShipmentQuery(
  List<Shipment> shipments, {
  String query = '',
  ShipmentFilter filter = ShipmentFilter.all,
}) {
  return shipments
      .where((s) => filter.matches(s.status) && matchesSearch(s, query))
      .toList();
}

/// Dashboard counts, computed from the same list the Shipments tab shows.
class ShipmentSummary {
  const ShipmentSummary({
    required this.total,
    required this.awaitingBids,
    required this.active,
    required this.completed,
    required this.closed,
  });

  factory ShipmentSummary.from(Iterable<Shipment> shipments) {
    var awaiting = 0, active = 0, completed = 0, closed = 0, total = 0;
    for (final s in shipments) {
      total++;
      if (ShipmentFilter.awaitingBids.matches(s.status)) awaiting++;
      if (ShipmentFilter.active.matches(s.status)) active++;
      if (ShipmentFilter.completed.matches(s.status)) completed++;
      if (ShipmentFilter.closed.matches(s.status)) closed++;
    }
    return ShipmentSummary(
      total: total,
      awaitingBids: awaiting,
      active: active,
      completed: completed,
      closed: closed,
    );
  }

  final int total;
  final int awaitingBids;
  final int active;
  final int completed;
  final int closed;

  int countFor(ShipmentFilter filter) => switch (filter) {
    ShipmentFilter.all => total,
    ShipmentFilter.awaitingBids => awaitingBids,
    ShipmentFilter.active => active,
    ShipmentFilter.completed => completed,
    ShipmentFilter.closed => closed,
  };
}

/// List orderings offered in the Shipments filter sheet.
enum ShipmentSort {
  newest('Newest first'),
  pickupSoonest('Pickup date'),
  status('Status');

  const ShipmentSort(this.label);
  final String label;

  List<Shipment> apply(List<Shipment> shipments) {
    final list = [...shipments];
    switch (this) {
      case newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case pickupSoonest:
        list.sort((a, b) => a.pickupAt.compareTo(b.pickupAt));
      case status:
        list.sort((a, b) {
          final byStatus = a.status.index.compareTo(b.status.index);
          return byStatus != 0 ? byStatus : b.createdAt.compareTo(a.createdAt);
        });
    }
    return list;
  }
}
