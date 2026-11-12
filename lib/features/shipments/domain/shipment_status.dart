import '../../../core/l10n/strings.dart';

/// Lifecycle of a shipment request.
///
/// ```
/// awaitingBids ──accept bid──▶ confirmed ──▶ scheduled ──▶ inTransit ──▶ delivered
///      │                           │             │
///      ├──────────── cancel ───────┴─────────────┘──▶ cancelled
///      └── pickup passes with no accepted bid ──────▶ expired (server job)
/// ```
enum ShipmentStatus {
  awaitingBids,
  confirmed,
  scheduled,
  inTransit,
  delivered,
  cancelled,
  expired;

  String get label => switch (this) {
    awaitingBids => l10n.statusAwaitingBids,
    confirmed => l10n.statusConfirmed,
    scheduled => l10n.statusScheduled,
    inTransit => l10n.statusInTransit,
    delivered => l10n.statusDelivered,
    cancelled => l10n.statusCancelled,
    expired => l10n.statusExpired,
  };

  /// Statuses that occupy one of the shipper's three mobile request slots.
  bool get countsTowardRequestLimit => switch (this) {
    awaitingBids || confirmed || scheduled || inTransit => true,
    delivered || cancelled || expired => false,
  };

  bool get isTerminal => !countsTowardRequestLimit;

  /// A carrier has been assigned and the job is under way or about to be.
  bool get isActive =>
      this == confirmed || this == scheduled || this == inTransit;

  /// The shipper may cancel before pickup.
  bool get canCancel =>
      this == awaitingBids || this == confirmed || this == scheduled;

  /// The status a carrier-side update moves this shipment to. Carrier
  /// updates are simulated in this prototype.
  ShipmentStatus? get nextCarrierStatus => switch (this) {
    confirmed => scheduled,
    scheduled => inTransit,
    inTransit => delivered,
    _ => null,
  };

  /// Happy-path order used to draw the timeline.
  static const lifecycle = [
    awaitingBids,
    confirmed,
    scheduled,
    inTransit,
    delivered,
  ];

  static ShipmentStatus? tryParse(String? value) {
    for (final status in values) {
      if (status.name == value) return status;
    }
    return null;
  }
}
