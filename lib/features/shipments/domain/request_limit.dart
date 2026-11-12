import '../../../core/l10n/strings.dart';
import 'shipment.dart';

/// The mobile three-request rule.
///
/// A request "qualifies" while it is Awaiting bids, Confirmed, Scheduled or
/// In transit (see [ShipmentStatus.countsTowardRequestLimit]). Delivered,
/// Cancelled and Expired requests free their slot.
///
/// This class is the single definition of the rule. The UI uses it to show
/// usage and warn early; the repository enforces it atomically inside the
/// create transaction; in production the same check belongs on the server
/// (see README → "Enforcing the limit in production").
abstract final class RequestLimit {
  static const int max = 3;

  /// Prescribed wording from the brief, shown whenever the limit blocks a
  /// request.
  static String get message => l10n.errRequestLimit;

  static int countQualifying(Iterable<Shipment> shipments) =>
      shipments.where((s) => s.status.countsTowardRequestLimit).length;

  static RequestLimitUsage usageOf(Iterable<Shipment> shipments) =>
      RequestLimitUsage(used: countQualifying(shipments));
}

class RequestLimitUsage {
  const RequestLimitUsage({required this.used, this.limit = RequestLimit.max});

  final int used;
  final int limit;

  bool get isAtLimit => used >= limit;
  int get remaining => (limit - used).clamp(0, limit);
  double get fraction => limit == 0 ? 1 : (used / limit).clamp(0, 1);
}
