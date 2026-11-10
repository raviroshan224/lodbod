import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/widgets/feedback.dart';
import '../../../routing/routes.dart';
import '../../auth/presentation/session.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../domain/activity.dart';

/// Shows a toast when new bids or delivery updates arrive while the app is
/// open, according to the shipper's alert preferences. Everything is also
/// listed in Notifications.
class InAppAlerts extends ConsumerStatefulWidget {
  const InAppAlerts({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<InAppAlerts> createState() => _InAppAlertsState();
}

class _InAppAlertsState extends ConsumerState<InAppAlerts> {
  Set<String>? _known;

  @override
  void initState() {
    super.initState();
    _known = ref.read(activityFeedProvider).value?.map((a) => a.id).toSet();
  }

  void _onFeed(List<ActivityItem> feed) {
    final known = _known;
    _known = feed.map((a) => a.id).toSet();
    if (known == null) return; // First load: nothing is "new".

    final session = ref.read(sessionProvider);
    if (session is! SessionReady) return;
    // Only genuinely new events: loading sample data adds past activity too.
    final recent = DateTime.now().subtract(const Duration(minutes: 2));
    final fresh = feed
        .where((a) => !known.contains(a.id) && a.at.isAfter(recent))
        .toList();

    final bids = session.profile.bidAlerts
        ? fresh.where((a) => a.kind == ActivityKind.bid).toList()
        : const <ActivityItem>[];
    if (bids.isNotEmpty) {
      final shipmentId = bids.first.shipmentId;
      final count = bids.where((a) => a.shipmentId == shipmentId).length;
      final reference = bids.first.title.replaceFirst('New bid on ', '');
      showMessage(
        context,
        count > 1 ? '$count new bids on $reference' : bids.first.title,
        actionLabel: 'View',
        onAction: () => GoRouter.of(context).push(Routes.bids(shipmentId)),
      );
      return;
    }

    const deliveryKinds = {
      ActivityKind.scheduled,
      ActivityKind.pickedUp,
      ActivityKind.delivered,
    };
    final updates = session.profile.statusAlerts
        ? fresh.where((a) => deliveryKinds.contains(a.kind)).toList()
        : const <ActivityItem>[];
    if (updates.isNotEmpty) {
      final latest = updates.first;
      showMessage(
        context,
        latest.title,
        actionLabel: 'View',
        onAction: () =>
            GoRouter.of(context).push(Routes.shipment(latest.shipmentId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(activityFeedProvider, (_, next) {
      final feed = next.value;
      if (feed != null) _onFeed(feed);
    });
    return widget.child;
  }
}
