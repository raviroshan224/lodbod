import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../create_shipment/presentation/open_post_load.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/shipment_visuals.dart';
import '../domain/shipment_analytics.dart';

enum AnalyticsPeriod {
  days30(30),
  days90(90),
  all(null);

  const AnalyticsPeriod(this.days);
  final int? days;

  String get label => switch (this) {
    days30 => l10n.period30,
    days90 => l10n.period90,
    all => l10n.periodAll,
  };

  List<Shipment> filter(List<Shipment> shipments, DateTime now) {
    final d = days;
    if (d == null) return shipments;
    final from = now.subtract(Duration(days: d));
    return shipments.where((s) => s.createdAt.isAfter(from)).toList();
  }
}

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  AnalyticsPeriod _period = AnalyticsPeriod.days30;

  @override
  Widget build(BuildContext context) {
    final shipments = ref.watch(shipmentsProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TabHeader(
              title: l10n.navAnalytics,
              subtitle: l10n.analyticsSubtitle,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.sm),
              child: PillTabs<AnalyticsPeriod>(
                values: AnalyticsPeriod.values,
                selected: _period,
                labelOf: (p) => p.label,
                onChanged: (p) => setState(() => _period = p),
              ),
            ),
            Expanded(
              child: switch (shipments) {
                AsyncData(:final value) => _body(value),
                AsyncError(:final error) => ErrorView(
                  error: error,
                  onRetry: () => ref.invalidate(shipmentsProvider),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(List<Shipment> all) {
    final inPeriod = _period.filter(all, DateTime.now());
    if (inPeriod.isEmpty) {
      return ListView(
        children: [
          EmptyView(
            icon: Icons.insert_chart_outlined_rounded,
            title: all.isEmpty
                ? l10n.analyticsNoData
                : l10n.analyticsNothingPeriod,
            message: all.isEmpty
                ? l10n.analyticsNoDataBody
                : l10n.analyticsNothingPeriodBody,
            action: all.isEmpty
                ? FilledButton(
                    onPressed: () => openPostLoad(context, ref),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(170, 48),
                    ),
                    child: Text(l10n.actionPostALoad),
                  )
                : null,
          ),
        ],
      );
    }
    return _Content(
      analytics: ShipmentAnalytics.from(inPeriod),
      period: _period,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.analytics, required this.period});
  final ShipmentAnalytics analytics;
  final AnalyticsPeriod period;

  @override
  Widget build(BuildContext context) {
    final a = analytics;
    final ranked = a.byStatus.entries.where((e) => e.value > 0).toList()
      ..sort((x, y) => y.value.compareTo(x.value));
    final statusTotal = ranked.fold(0, (sum, e) => sum + e.value);
    final open = a.byStatus.entries
        .where((e) => e.key.countsTowardRequestLimit)
        .fold(0, (sum, e) => sum + e.value);

    return ListView(
      padding: EdgeInsets.fromLTRB(
        Gap.page,
        Gap.xs,
        Gap.page,
        Gap.xl + MediaQuery.paddingOf(context).bottom,
      ),
      children: [
        AppCard(
          padding: const EdgeInsets.all(Gap.lg),
          color: AppColors.primaryContainer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.analyticsBookedSpend(period.label.toLowerCase()),
                style: TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Space.v4,
              Text(
                Fmt.npr(a.committedSpend),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              Space.v4,
              Text(
                l10n.analyticsBookedLoads(a.bookedCount) +
                    (a.averageFare == null
                        ? ''
                        : l10n.analyticsAvgPerLoad(Fmt.npr(a.averageFare!))),
                style: TextStyle(
                  color: AppColors.onPrimaryContainer,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Space.v12,
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.analyticsLoadsPosted,
                value: '${a.total}',
                caption: l10n.analyticsOpenNow(open),
              ),
            ),
            Space.h8,
            Expanded(
              child: _StatTile(
                label: l10n.statusDelivered,
                value: '${a.byStatus[ShipmentStatus.delivered]}',
                caption: l10n.analyticsTonnesMoved(
                  Fmt.number(
                    double.parse(a.deliveredTonnes.toStringAsFixed(1)),
                  ),
                ),
              ),
            ),
          ],
        ),
        Space.v8,
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: l10n.analyticsBidsReceived,
                value: '${a.totalBids}',
                caption: l10n.analyticsAcrossLoads(a.biddedRequests),
              ),
            ),
            Space.h8,
            Expanded(
              child: _StatTile(
                label: l10n.analyticsAvgBids,
                value: a.averageBids == null
                    ? '—'
                    : a.averageBids!.toStringAsFixed(1),
                caption: l10n.analyticsPerPostedLoad,
              ),
            ),
          ],
        ),
        Space.v12,
        SectionCard(
          title: l10n.analyticsByStatus,
          child: Column(
            children: [
              for (final e in ranked)
                _StatusBar(status: e.key, count: e.value, total: statusTotal),
            ],
          ),
        ),
        Space.v12,
        SectionCard(
          title: l10n.analyticsTopRoutes,
          child: Column(
            children: [
              for (final (i, r) in a.topRoutes.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Space.h12,
                      Expanded(
                        child: Text(
                          r.route,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        l10n.analyticsLoads(r.count),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.caption,
  });
  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
          ),
          Space.v4,
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          Text(
            caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Ranked horizontal bar: one hue, thin, rounded data-end, square at the
/// baseline. Label and value use text colours; the status icon carries
/// identity alongside the name.
class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.status,
    required this.count,
    required this.total,
  });
  final ShipmentStatus status;
  final int count;

  /// Bars show each status's share of all shipments, so four statuses with
  /// one shipment each read as quarters, not four full bars.
  final int total;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.analyticsStatusA11y(status.label, count),
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  shipmentStatusStyle(status).icon,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                Space.h8,
                Expanded(
                  child: Text(
                    status.label,
                    style: const TextStyle(fontSize: 13.5),
                  ),
                ),
                Text(
                  '$count',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 6),
            LayoutBuilder(
              builder: (context, c) => Container(
                height: 10,
                alignment: Alignment.centerLeft,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: total == 0 ? 0 : count / total),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutCubic,
                  builder: (_, f, _) => Container(
                    height: 10,
                    width: c.maxWidth * f,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
