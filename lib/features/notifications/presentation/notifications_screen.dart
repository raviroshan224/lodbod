import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../account/data/providers.dart';
import '../../auth/presentation/session.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../domain/activity.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  /// Unread cut-off captured on open, so items stay highlighted while the
  /// screen is visible even though they're marked read in the background.
  DateTime? _seenBefore;

  @override
  void initState() {
    super.initState();
    final session = ref.read(sessionProvider);
    if (session is SessionReady) {
      _seenBefore = session.profile.notificationsSeenAt;
      ref
          .read(accountRepositoryProvider)
          .markNotificationsSeen(session.profile.id)
          .ignore();
    }
  }

  void _open(ActivityItem a) {
    if (a.bidId != null) {
      context.push(Routes.bid(a.shipmentId, a.bidId!));
    } else {
      context.push(Routes.shipment(a.shipmentId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(activityFeedProvider);
    return Scaffold(
      appBar: const DetailAppBar(title: 'Notifications'),
      body: switch (feed) {
        AsyncData(:final value) when value.isEmpty => const Center(
          child: EmptyView(
            icon: Icons.notifications_none_rounded,
            title: "You're all caught up",
            message: 'Bids, bookings and delivery updates will show up here.',
          ),
        ),
        AsyncData(:final value) => _list(value),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(shipmentsProvider),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(Gap.page),
          children: List.generate(
            6,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: SkeletonBox(height: 72, radius: 16),
            ),
          ),
        ),
      },
    );
  }

  Widget _list(List<ActivityItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final groups = <String, List<ActivityItem>>{};
    for (final a in items) {
      final label = !a.at.isBefore(today)
          ? 'Today'
          : !a.at.isBefore(today.subtract(const Duration(days: 1)))
          ? 'Yesterday'
          : 'Earlier';
      (groups[label] ??= []).add(a);
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.xl),
      children: [
        for (final entry in groups.entries) ...[
          SectionHeader(entry.key, top: Gap.md),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (final (i, a) in entry.value.indexed) ...[
                  if (i > 0) const Divider(indent: 68),
                  _Row(
                    item: a,
                    unread: _seenBefore != null && a.at.isAfter(_seenBefore!),
                    onTap: () => _open(a),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.item, required this.unread, required this.onTap});
  final ActivityItem item;
  final bool unread;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (item.kind) {
      ActivityKind.bid => (Icons.gavel_rounded, AppColors.info),
      ActivityKind.posted => (Icons.campaign_outlined, AppColors.primary),
      ActivityKind.confirmed => (Icons.handshake_outlined, AppColors.teal),
      ActivityKind.scheduled => (
        Icons.event_available_outlined,
        AppColors.violet,
      ),
      ActivityKind.pickedUp => (
        Icons.local_shipping_outlined,
        const Color(0xFFB93C0B),
      ),
      ActivityKind.delivered => (
        Icons.check_circle_outline_rounded,
        AppColors.success,
      ),
      ActivityKind.cancelled => (Icons.cancel_outlined, AppColors.error),
      ActivityKind.expired => (
        Icons.timer_off_outlined,
        AppColors.textSecondary,
      ),
    };
    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? AppColors.primarySoft.withValues(alpha: 0.5) : null,
        padding: const EdgeInsets.fromLTRB(Gap.lg, 14, Gap.lg, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconTile(icon, color: color, size: 38),
            Space.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        Fmt.relative(item.at),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  Space.v2,
                  Text(
                    item.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            if (unread) ...[
              Space.h8,
              Container(
                margin: const EdgeInsets.only(top: 6),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
