import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../create_shipment/presentation/open_post_load.dart';
import '../domain/shipment_query.dart';
import 'shipments_providers.dart';
import 'widgets/shipment_card.dart';

class ShipmentsScreen extends ConsumerStatefulWidget {
  const ShipmentsScreen({super.key});

  @override
  ConsumerState<ShipmentsScreen> createState() => _ShipmentsScreenState();
}

class _ShipmentsScreenState extends ConsumerState<ShipmentsScreen> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(
      text: ref.read(shipmentListQueryProvider).search,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _showSortSheet() async {
    final current = ref.read(shipmentListQueryProvider).sort;
    final picked = await showModalBottomSheet<ShipmentSort>(
      useRootNavigator: true,
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Gap.sm, 0, Gap.sm, Gap.sm),
                child: Text(
                  'Sort shipments',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              for (final s in ShipmentSort.values)
                ListTile(
                  shape: RoundedRectangleBorder(borderRadius: Radii.input),
                  title: Text(s.label),
                  trailing: s == current
                      ? const Icon(
                          Icons.check_rounded,
                          color: AppColors.primary,
                        )
                      : null,
                  onTap: () => Navigator.of(context).pop(s),
                ),
            ],
          ),
        ),
      ),
    );
    if (picked != null) {
      ref.read(shipmentListQueryProvider.notifier).setSort(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(shipmentListQueryProvider.select((q) => q.search), (_, next) {
      if (_search.text != next) _search.text = next;
    });

    final query = ref.watch(shipmentListQueryProvider);
    final controller = ref.read(shipmentListQueryProvider.notifier);
    final summary = ref.watch(shipmentSummaryProvider).value;
    final results = ref.watch(filteredShipmentsProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            TabHeader(
              title: 'Shipments',
              actions: [
                CircleIconButton(
                  icon: Icons.swap_vert_rounded,
                  tooltip: 'Sort: ${query.sort.label}',
                  onPressed: _showSortSheet,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Gap.page),
              child: TextField(
                controller: _search,
                onChanged: controller.setSearch,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search reference, route or cargo',
                  prefixIcon: const Icon(Icons.search_rounded, size: 21),
                  suffixIcon: query.search.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () => controller.setSearch(''),
                        ),
                ),
              ),
            ),
            SizedBox(
              height: 56,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(Gap.page, 10, Gap.page, 6),
                itemCount: ShipmentFilter.values.length,
                separatorBuilder: (_, _) => Space.h8,
                itemBuilder: (context, i) {
                  final f = ShipmentFilter.values[i];
                  final count = summary?.countFor(f);
                  return ChoicePill(
                    label: count == null ? f.label : '${f.label}  $count',
                    selected: query.filter == f,
                    onTap: () => controller.setFilter(f),
                  );
                },
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.primary,
                onRefresh: () async {
                  ref.invalidate(shipmentsProvider);
                  await ref.read(shipmentsProvider.future);
                },
                child: switch (results) {
                  AsyncData(:final value) when value.isEmpty => ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _EmptyResults(
                        hasAnyShipments: (summary?.total ?? 0) > 0,
                        onClear: () {
                          HapticFeedback.selectionClick();
                          controller.clear();
                        },
                        onPostLoad: () => openPostLoad(context, ref),
                      ),
                    ],
                  ),
                  AsyncData(:final value) => ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      Gap.page,
                      Gap.sm,
                      Gap.page,
                      Gap.xl + MediaQuery.paddingOf(context).bottom,
                    ),
                    itemCount: value.length + 1,
                    separatorBuilder: (_, _) => Space.v8,
                    itemBuilder: (context, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Text(
                            '${value.length} ${value.length == 1 ? 'shipment' : 'shipments'} · ${query.sort.label.toLowerCase()}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12.5,
                            ),
                          ),
                        );
                      }
                      final s = value[i - 1];
                      return ShipmentCard(
                        shipment: s,
                        onTap: () => context.push(Routes.shipment(s.id)),
                      );
                    },
                  ),
                  AsyncError(:final error) => ErrorView(
                    error: error,
                    onRetry: () => ref.invalidate(shipmentsProvider),
                  ),
                  _ => ListView(
                    padding: const EdgeInsets.all(Gap.page),
                    children: const [
                      SkeletonBox(height: 140, radius: 16),
                      Space.v8,
                      SkeletonBox(height: 140, radius: 16),
                      Space.v8,
                      SkeletonBox(height: 140, radius: 16),
                    ],
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.hasAnyShipments,
    required this.onClear,
    required this.onPostLoad,
  });

  final bool hasAnyShipments;
  final VoidCallback onClear;
  final VoidCallback onPostLoad;

  @override
  Widget build(BuildContext context) {
    return hasAnyShipments
        ? EmptyView(
            icon: Icons.search_off_rounded,
            title: 'No matching shipments',
            message: 'Try a different reference, city or status.',
            action: OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(minimumSize: const Size(210, 46)),
              child: const Text('Clear search and filters'),
            ),
          )
        : EmptyView(
            icon: Icons.inventory_2_outlined,
            title: 'No shipments yet',
            message: 'Post a load and carriers will start bidding on it.',
            action: FilledButton.icon(
              onPressed: onPostLoad,
              style: FilledButton.styleFrom(minimumSize: const Size(180, 48)),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Post a load'),
            ),
          );
  }
}
