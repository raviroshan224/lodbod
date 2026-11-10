import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/state_views.dart';
import '../../data/models/shipment.dart';
import '../../data/providers.dart';
import '../../domain/request_limit.dart';
import '../../domain/shipment_query.dart';
import '../../domain/tracking.dart';
import '../../routing/routes.dart';
import '../auth/session.dart';
import '../shipments/request_limit_sheet.dart';
import '../shipments/shipments_providers.dart';
import '../shipments/widgets/shipment_card.dart';

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
                    padding: const EdgeInsets.fromLTRB(
                      Gap.page,
                      0,
                      Gap.page,
                      Gap.xl,
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
      return [_Welcome(onPostLoad: () => context.push(Routes.postLoad))];
    }

    final summary = ShipmentSummary.from(all);
    final usage = RequestLimit.usageOf(all);
    final now = DateTime.now();
    final needsAction = all
        .where((s) => s.status == ShipmentStatus.awaitingBids && s.bidCount > 0)
        .toList();
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
      _PostLoadCard(
        usage: usage,
        onPostLoad: () => context.push(Routes.postLoad),
        onLearnMore: () => showRequestLimitSheet(context, usage),
      ),
      Space.v12,
      Row(
        children: [
          Expanded(
            child: _StatTile(
              icon: Icons.local_shipping_outlined,
              color: const Color(0xFFB93C0B),
              count: summary.active,
              label: 'Active',
              onTap: () => openFiltered(ShipmentFilter.active),
            ),
          ),
          Space.h8,
          Expanded(
            child: _StatTile(
              icon: Icons.gavel_rounded,
              color: AppColors.info,
              count: summary.awaitingBids,
              label: 'Awaiting bids',
              onTap: () => openFiltered(ShipmentFilter.awaitingBids),
            ),
          ),
          Space.h8,
          Expanded(
            child: _StatTile(
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.success,
              count: summary.completed,
              label: 'Completed',
              onTap: () => openFiltered(ShipmentFilter.completed),
            ),
          ),
        ],
      ),
      if (needsAction.isNotEmpty) ...[
        const SectionHeader('Needs your action'),
        for (final s in needsAction) ...[
          _ActionTile(
            icon: Icons.gavel_rounded,
            iconColor: AppColors.info,
            title:
                '${s.bidCount} ${s.bidCount == 1 ? 'bid' : 'bids'} on ${s.reference}',
            subtitle: '${s.routeLabel} · Pickup ${Fmt.dayMonth(s.pickupAt)}',
            onTap: () => context.push(Routes.bids(s.id)),
          ),
          Space.v8,
        ],
      ],
      if (onTheRoad.isNotEmpty) ...[
        const SectionHeader('On the road'),
        for (final s in onTheRoad) ...[
          _LiveCard(shipment: s, onTap: () => context.push(Routes.track(s.id))),
          Space.v8,
        ],
      ],
      if (upcoming.isNotEmpty) ...[
        const SectionHeader('Next pickup'),
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
      SectionHeader(
        'Recent shipments',
        action: TextButton(
          onPressed: () => openFiltered(ShipmentFilter.all),
          child: const Text('See all'),
        ),
      ),
      for (final s in all.take(3)) ...[
        ShipmentCard(
          shipment: s,
          onTap: () => context.push(Routes.shipment(s.id)),
        ),
        Space.v8,
      ],
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
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.md, Gap.page, Gap.lg),
      child: Row(
        children: [
          Semantics(
            button: true,
            label: 'Account',
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
                  style: const TextStyle(
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
            tooltip: 'Notifications',
            badge: unread,
            onPressed: onBell,
          ),
        ],
      ),
    );
  }
}

class _PostLoadCard extends StatelessWidget {
  const _PostLoadCard({
    required this.usage,
    required this.onPostLoad,
    required this.onLearnMore,
  });

  final RequestLimitUsage usage;
  final VoidCallback onPostLoad;
  final VoidCallback onLearnMore;

  @override
  Widget build(BuildContext context) {
    final atLimit = usage.isAtLimit;
    return Container(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.md),
      decoration: BoxDecoration(
        borderRadius: Radii.card,
        border: Border.all(color: AppColors.primaryBorder),
        boxShadow: AppColors.shadow,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFEFE6), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      atLimit ? 'All requests in use' : 'Ship something new',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Space.v2,
                    Text.rich(
                      TextSpan(
                        text: 'Mobile requests used: ',
                        children: [
                          TextSpan(
                            text: '${usage.used} of ${usage.limit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Space.h8,
              FilledButton.icon(
                onPressed: onPostLoad,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 42),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.add_rounded, size: 20),
                label: const Text('Post Load'),
              ),
            ],
          ),
          Space.v12,
          Semantics(
            label: '${usage.used} of ${usage.limit} mobile requests used',
            child: ClipRRect(
              borderRadius: Radii.chip,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: usage.fraction),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 6,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryBorder.withValues(
                    alpha: 0.5,
                  ),
                ),
              ),
            ),
          ),
          InkWell(
            onTap: onLearnMore,
            borderRadius: Radii.input,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      atLimit
                          ? 'Finish or cancel a request to post another.'
                          : '${usage.remaining} more ${usage.remaining == 1 ? 'request' : 'requests'} available from mobile.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  const Text(
                    'How it works',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
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
      padding: const EdgeInsets.fromLTRB(Gap.md, Gap.md, Gap.md, 10),
      semanticLabel: '$count $label. Show these shipments',
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12.5,
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
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

/// In-transit shipment with simulated progress.
class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.shipment, required this.onTap});
  final Shipment shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    final t = trackingFor(s, now: DateTime.now());
    final where = t.lastPassed == null
        ? 'Left ${s.pickup}'
        : 'Passed ${t.lastPassed!.name}';
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
                  style: const TextStyle(
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
                  '$where · ${t.remainingKm} km left',
                ),
              ),
              if (t.eta != null)
                Text(
                  t.isLate ? 'Running late' : 'ETA ${Fmt.time(t.eta!)}',
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
              const Expanded(
                child: Text(
                  'Simulated tracking',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                ),
              ),
              const Flexible(
                child: Text(
                  'Track shipment',
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

/// First-run state for a new account.
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
        showMessage(context, 'Sample shipments added. Have a look around!');
      }
    } catch (e) {
      if (mounted) {
        showMessage(
          context,
          "Couldn't add sample shipments. Try again.",
          isError: true,
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        Icons.edit_note_rounded,
        'Post a load',
        'Route, cargo and truck in under a minute.',
      ),
      (
        Icons.gavel_rounded,
        'Compare bids',
        'Verified carriers send offers you can compare.',
      ),
      (
        Icons.local_shipping_outlined,
        'Track delivery',
        'Follow every step until it is delivered.',
      ),
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
                'Welcome to LODBOD',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Space.v6,
              const Text(
                'Move goods across Nepal with trusted carriers. Here is how it works:',
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
                            style: const TextStyle(
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
                label: 'Post your first load',
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
                      : const Text('Explore with sample shipments'),
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
      label: 'Loading your shipments',
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
