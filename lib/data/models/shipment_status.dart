/// Lifecycle of a shipment request.
///
/// ```
/// awaitingBids ──accept bid──▶ confirmed ──▶ scheduled ──▶ inTransit ──▶ delivered
///      │                           │             │
///      ├──────────── cancel ───────┴─────────────┘──▶ cancelled
///      └── pickup passes with no accepted bid ──────▶ expired (server job)
/// ```
enum ShipmentStatus {
  awaitingBids('Awaiting bids'),
  confirmed('Confirmed'),
  scheduled('Scheduled'),
  inTransit('In transit'),
  delivered('Delivered'),
  cancelled('Cancelled'),
  expired('Expired');

  const ShipmentStatus(this.label);

  final String label;

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
