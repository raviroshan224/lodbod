import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../account/data/providers.dart';
import '../../auth/presentation/session.dart';
import '../../create_shipment/presentation/open_post_load.dart';
import '../../shipments/domain/request_limit.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/domain/shipment_query.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/request_limit_sheet.dart';
import '../../shipments/presentation/widgets/shipment_card.dart';
import '../../shipments/presentation/widgets/status_badge.dart';
import '../../tracking/domain/tracking.dart';
import '../../tracking/presentation/live_tracking.dart';
import 'widgets/request_usage_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final shipments = ref.watch(shipmentsProvider);
    final unread = ref.watch(unreadActivityCountProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            ref.invalidate(shipmentsProvider);
            await ref.read(shipmentsProvider.future);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _Header(
                  name: user.name,
                  unread: unread,
                  onBell: () => context.push(Routes.notifications),
                  onAvatar: () => context.go(Routes.account),
                ),
              ),
              ...switch (shipments) {
                AsyncData(:final value) => [
                  SliverPadding(
                    // Bottom inset keeps the last item clear of the
                    // floating navigation bar.
                    padding: EdgeInsets.fromLTRB(
                      Gap.page,
                      0,
                      Gap.page,
                      Gap.xl + MediaQuery.paddingOf(context).bottom,
                    ),
                    sliver: SliverList.list(
                      children: _content(context, ref, value),
                    ),
                  ),
                ],
                AsyncError(:final error) => [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: ErrorView(
                      error: error,
                      onRetry: () => ref.invalidate(shipmentsProvider),
                    ),
                  ),
                ],
                _ => const [SliverToBoxAdapter(child: _DashboardSkeleton())],
              },
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    WidgetRef ref,
    List<Shipment> all,
  ) {
    if (all.isEmpty) {
      return [_Welcome(onPostLoad: () => openPostLoad(context, ref))];
    }

    final summary = ShipmentSummary.from(all);
    final usage = RequestLimit.usageOf(all);
    final now = DateTime.now();
    final needsAction = all.where(awaitsShipperDecision).toList();
    final onTheRoad = all
        .where((s) => s.status == ShipmentStatus.inTransit)
        .toList();
    final upcoming =
        all
            .where(
              (s) =>
                  (s.status == ShipmentStatus.confirmed ||
                      s.status == ShipmentStatus.scheduled) &&
                  s.pickupAt.isAfter(now),
            )
            .toList()
          ..sort((a, b) => a.pickupAt.compareTo(b.pickupAt));

    void openFiltered(ShipmentFilter filter) {
      ref.read(shipmentListQueryProvider.notifier).showOnly(filter);
      context.go(Routes.shipments);
    }

    return [
      RequestUsageCard(
        usage: usage,
        onPostLoad: () => openPostLoad(context, ref),
        onManage: () => openFiltered(ShipmentFilter.all),
        onLearnMore: () => showRequestLimitSheet(context, usage),
      ),
      Space.v12,
      // Equal-height tiles even when one label wraps at large text sizes.
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFFB93C0B),
                count: summary.active,
                label: l10n.filterActive,
                onTap: () => openFiltered(ShipmentFilter.active),
              ),
            ),
            Space.h8,
            Expanded(
              child: _StatTile(
                icon: Icons.gavel_rounded,
                color: AppColors.info,
                count: summary.awaitingBids,
                label: l10n.statusAwaitingBids,
                onTap: () => openFiltered(ShipmentFilter.awaitingBids),
              ),
            ),
            Space.h8,
            Expanded(
              child: _StatTile(
                icon: Icons.check_circle_outline_rounded,
                color: AppColors.success,
                count: summary.completed,
                label: l10n.filterCompleted,
                onTap: () => openFiltered(ShipmentFilter.completed),
              ),
            ),
          ],
        ),
      ),
      if (needsAction.isNotEmpty) ...[
        SectionHeader(l10n.homeNeedsAction),
        for (final s in needsAction) ...[
          _ActionTile(
            icon: Icons.gavel_rounded,
            iconColor: AppColors.info,
            title: l10n.homeBidsOn(s.bidCount, s.reference),
            subtitle: l10n.homeRoutePickup(
              s.routeLabel,
              Fmt.dayMonth(s.pickupAt),
            ),
            onTap: () => context.push(Routes.bids(s.id)),
          ),
          Space.v8,
        ],
      ],
      if (onTheRoad.isNotEmpty) ...[
        SectionHeader(l10n.homeOnTheRoad),
        for (final s in onTheRoad) ...[
          _LiveCard(shipment: s, onTap: () => context.push(Routes.track(s.id))),
          Space.v8,
        ],
      ],
      if (upcoming.isNotEmpty) ...[
        SectionHeader(l10n.homeNextPickup),
        _ActionTile(
          icon: Icons.event_available_outlined,
          iconColor: AppColors.violet,
          title:
              '${upcoming.first.reference} · ${Fmt.weekdayDayMonth(upcoming.first.pickupAt)}, ${Fmt.time(upcoming.first.pickupAt)}',
          subtitle:
              '${upcoming.first.routeLabel}${upcoming.first.carrierName == null ? '' : ' · ${upcoming.first.carrierName}'}',
          onTap: () => context.push(Routes.shipment(upcoming.first.id)),
        ),
      ],
      // Shipments already shown in a section above are not repeated here.
      ...() {
        final featured = {
          for (final s in needsAction) s.id,
          for (final s in onTheRoad) s.id,
          if (upcoming.isNotEmpty) upcoming.first.id,
        };
        final recent = all.where((s) => !featured.contains(s.id)).take(3);
        if (recent.isEmpty) {
          return [
            Space.v24,
            OutlinedButton(
              onPressed: () => openFiltered(ShipmentFilter.all),
              child: Text(l10n.homeSeeAllN(all.length)),
            ),
          ];
        }
        return [
          SectionHeader(
            l10n.homeOtherShipments,
            action: TextButton(
              onPressed: () => openFiltered(ShipmentFilter.all),
              child: Text(l10n.actionSeeAll),
            ),
          ),
          for (final s in recent) ...[
            ShipmentCard(
              shipment: s,
              onTap: () => context.push(Routes.shipment(s.id)),
            ),
            Space.v8,
          ],
        ];
      }(),
    ];
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.unread,
    required this.onBell,
    required this.onAvatar,
  });
  final String name;
  final int unread;
  final VoidCallback onBell;
  final VoidCallback onAvatar;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.homeGoodMorning;
    if (h < 17) return l10n.homeGoodAfternoon;
    return l10n.homeGoodEvening;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, Gap.lg),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: l10n.navAccount,
            child: GestureDetector(
              onTap: onAvatar,
              child: InitialsAvatar(Fmt.initials(name), size: 44),
            ),
          ),
          Space.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          CircleIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: l10n.notifTitle,
            badge: unread,
            onPressed: onBell,
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(10, Gap.md, 10, 10),
      semanticLabel: l10n.homeStatA11y(count, label),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconTile(icon, color: color, size: 32),
          Space.v8,
          TweenAnimationBuilder<double>(
            tween: Tween(end: count.toDouble()),
            duration: const Duration(milliseconds: 500),
            builder: (_, v, _) => Text(
              '${v.round()}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
                height: 1.1,
              ),
            ),
          ),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            // The count scales fully; the caption is capped so a single
            // word (l10n.filterCompleted) still fits a third of a 320dp screen.
            textScaler: MediaQuery.textScalerOf(context)
                .clamp(maxScaleFactor: 1.15),
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: Gap.md, vertical: Gap.md),
      child: Row(
        children: [
          IconTile(icon, color: iconColor, size: 40),
          Space.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                  ),
                ),
                Space.v2,
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

class _LiveCard extends ConsumerWidget {
  const _LiveCard({required this.shipment, required this.onTap});
  final Shipment shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    final t = trackingFor(
      s,
      now: DateTime.now(),
      live: ref.watch(livePositionProvider(s.id)).value,
    );
    final where = t.lastPassed == null
        ? l10n.homeLeft(s.pickup)
        : l10n.homePassed(t.lastPassed!.name);
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  s.reference,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              StatusBadge(s.status, dense: true),
            ],
          ),
          Space.v6,
          RouteText(s.pickup, s.destination),
          Space.v12,
          ClipRRect(
            borderRadius: Radii.chip,
            child: LinearProgressIndicator(value: t.progress, minHeight: 6),
          ),
          Space.v8,
          Row(
            children: [
              Expanded(
                child: IconText(
                  Icons.near_me_outlined,
                  l10n.homeKmLeft(where, t.remainingKm),
                ),
              ),
              if (t.eta != null)
                Text(
                  t.isLate ? l10n.runningLate : l10n.etaTime(Fmt.time(t.eta!)),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: t.isLate ? AppColors.warning : null,
                  ),
                ),
            ],
          ),
          Space.v12,
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.simulatedTracking,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
              Flexible(
                child: Text(
                  l10n.actionTrackShipment,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Welcome extends ConsumerStatefulWidget {
  const _Welcome({required this.onPostLoad});
  final VoidCallback onPostLoad;

  @override
  ConsumerState<_Welcome> createState() => _WelcomeState();
}

class _WelcomeState extends ConsumerState<_Welcome> {
  bool _loading = false;

  Future<void> _loadSamples() async {
    setState(() => _loading = true);
    try {
      await ref
          .read(accountRepositoryProvider)
          .loadSampleData(ref.read(currentUserProvider).id);
      if (mounted) {
        showMessage(context, l10n.homeSamplesAdded);
      }
    } catch (e) {
      if (mounted) {
        showMessage(context, l10n.homeSamplesFailed, isError: true);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      (Icons.edit_note_rounded, l10n.actionPostALoad, l10n.homeStep1Body),
      (Icons.gavel_rounded, l10n.actionCompareBids, l10n.homeStep2Body),
      (Icons.local_shipping_outlined, l10n.homeStep3, l10n.homeStep3Body),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const BrandMark(size: 44),
              Space.v16,
              Text(
                l10n.homeWelcome,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Space.v6,
              Text(
                l10n.homeWelcomeBody,
                style: TextStyle(color: AppColors.textSecondary, height: 1.45),
              ),
              Space.v16,
              for (final (i, step) in steps.indexed) ...[
                Row(
                  children: [
                    IconTile(step.$1, size: 36),
                    Space.h12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ${step.$2}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            step.$3,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Space.v12,
              ],
              Space.v8,
              PrimaryButton(
                label: l10n.homePostFirst,
                icon: Icons.add_rounded,
                onPressed: widget.onPostLoad,
              ),
              Space.v4,
              Center(
                child: TextButton(
                  onPressed: _loading ? null : _loadSamples,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.homeExploreSamples),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.homeLoading,
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: Gap.page),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(height: 118, radius: 16),
            Space.v12,
            Row(
              children: [
                Expanded(child: SkeletonBox(height: 98, radius: 16)),
                Space.h8,
                Expanded(child: SkeletonBox(height: 98, radius: 16)),
                Space.h8,
                Expanded(child: SkeletonBox(height: 98, radius: 16)),
              ],
            ),
            Space.v24,
            SkeletonBox(height: 18, width: 150),
            Space.v12,
            SkeletonBox(height: 70, radius: 16),
            Space.v24,
            SkeletonBox(height: 18, width: 170),
            Space.v12,
            SkeletonBox(height: 140, radius: 16),
            Space.v8,
            SkeletonBox(height: 140, radius: 16),
          ],
        ),
      ),
    );
  }
}
