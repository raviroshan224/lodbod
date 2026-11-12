import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../domain/bid.dart';
import '../domain/bid_rules.dart';
import 'accept_bid.dart';
import 'widgets/bid_card.dart';

/// Neutral sort orders. The default is arrival order so no offer is
/// promoted; the shipper chooses what matters to them.
enum BidSort {
  received('Newest'),
  fare('Price'),
  rating('Rating'),
  delivery('Fastest');

  const BidSort(this.label);
  final String label;

  List<Bid> apply(List<Bid> bids) {
    final sorted = [...bids];
    switch (this) {
      case received:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case fare:
        sorted.sort((a, b) => a.fare.compareTo(b.fare));
      case rating:
        sorted.sort((a, b) => b.carrierRating.compareTo(a.carrierRating));
      case delivery:
        sorted.sort(
          (a, b) => a.estimatedDeliveryDays.compareTo(b.estimatedDeliveryDays),
        );
    }
    return sorted;
  }
}

class BidsScreen extends ConsumerStatefulWidget {
  const BidsScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  ConsumerState<BidsScreen> createState() => _BidsScreenState();
}

class _BidsScreenState extends ConsumerState<BidsScreen> {
  BidSort _sort = BidSort.received;

  /// Bid whose accept is running (disables the other cards meanwhile).
  String? _accepting;

  Future<void> _accept(Shipment s, Bid bid, int otherBids) async {
    setState(() => _accepting = bid.id);
    try {
      await confirmAndAcceptBid(
        context,
        ref,
        shipment: s,
        bid: bid,
        otherBids: otherBids,
      );
    } finally {
      if (mounted) setState(() => _accepting = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentAsync = ref.watch(shipmentByIdProvider(widget.shipmentId));
    final bidsAsync = ref.watch(bidsProvider(widget.shipmentId));
    final shipment = shipmentAsync.value;

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Bids',
        subtitle: shipment == null
            ? null
            : '${shipment.reference} · ${shipment.routeLabel}',
      ),
      body: switch ((shipmentAsync, bidsAsync)) {
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(shipmentsProvider);
            ref.invalidate(bidsProvider(widget.shipmentId));
          },
        ),
        (AsyncData(value: final s?), AsyncData(value: final bids)) => _content(
          s,
          bids,
        ),
        (AsyncData(value: null), _) => const Center(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Shipment not found',
            message: 'It may have been removed.',
          ),
        ),
        _ => ListView(
          padding: const EdgeInsets.all(Gap.page),
          children: List.generate(
            3,
            (_) => const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: SkeletonBox(height: 150, radius: 16),
            ),
          ),
        ),
      },
    );
  }

  Widget _content(Shipment s, List<Bid> bids) {
    final sorted = _sort.apply(bids);
    final booking =
        ref.watch(shipmentActionsProvider(s.id)) == ShipmentAction.acceptBid;
    final accepted = bids.where((b) => b.id == s.acceptedBidId).firstOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xs, Gap.page, Gap.xl),
      children: [
        AppCard(
          padding: const EdgeInsets.all(Gap.md),
          child: Row(
            children: [
              const IconTile(Icons.inventory_2_outlined, size: 40),
              Space.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${s.cargoDescription} · ${s.weightLabel}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Space.v2,
                    Text(
                      'Pickup ${Fmt.weekdayDayMonth(s.pickupAt)}, ${Fmt.time(s.pickupAt)} · ${s.vehicleType.label}'
                      '${s.expectedFare == null ? '' : ' · Budget ${Fmt.npr(s.expectedFare!)}'}',
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
        ),
        Space.v12,
        if (accepted != null)
          InlineBanner(
            tone: BannerTone.success,
            title: 'Booked with ${accepted.carrierName}',
            message:
                '${Fmt.npr(accepted.fare)} · ${s.reference} is ${s.status.label.toLowerCase()}.',
          )
        else if (s.status != ShipmentStatus.awaitingBids)
          InlineBanner(
            tone: BannerTone.info,
            message:
                'This shipment is ${s.status.label.toLowerCase()} and no longer accepting bids.',
          ),
        if (bids.isEmpty)
          _NoBids(shipment: s)
        else ...[
          if (accepted != null || s.status != ShipmentStatus.awaitingBids)
            Space.v12,
          Row(
            children: [
              Text(
                '${bids.length} ${bids.length == 1 ? 'offer' : 'offers'}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              Text(
                'Sort by',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
            ],
          ),
          Space.v8,
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: BidSort.values.length,
              separatorBuilder: (_, _) => Space.h8,
              itemBuilder: (_, i) {
                final o = BidSort.values[i];
                return ChoicePill(
                  label: o.label,
                  selected: _sort == o,
                  onTap: () => setState(() => _sort = o),
                );
              },
            ),
          ),
          Space.v12,
          for (final bid in sorted) ...[
            BidCard(
              bid: bid,
              displayStatus: effectiveBidStatus(bid, s),
              pickupAt: s.pickupAt,
              budget: s.expectedFare,
              onTap: () => context.push(Routes.bid(s.id, bid.id)),
              // Accept straight from the list; the same confirmation sheet
              // as the offer details screen.
              accepting: booking && _accepting == bid.id,
              onAccept:
                  s.status == ShipmentStatus.awaitingBids &&
                      effectiveBidStatus(bid, s) == BidStatus.pending &&
                      _accepting == null
                  ? () => _accept(s, bid, bids.length - 1)
                  : null,
            ),
            Space.v12,
          ],
        ],
      ],
    );
  }
}

class _NoBids extends ConsumerWidget {
  const _NoBids({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waiting = shipment.status == ShipmentStatus.awaitingBids;
    final running = ref.watch(shipmentActionsProvider(shipment.id));

    return EmptyView(
      icon: Icons.gavel_rounded,
      title: waiting ? 'Waiting for carriers' : 'No bids',
      message: waiting
          ? 'Your load is visible to carriers. Offers usually arrive within minutes, and we will notify you.'
          : 'This shipment did not receive any bids.',
      action: waiting
          ? TextButton.icon(
              onPressed: running != null
                  ? null
                  : () async {
                      final error = await ref
                          .read(shipmentActionsProvider(shipment.id).notifier)
                          .simulateBids();
                      if (context.mounted && error != null) {
                        showMessage(context, error.message, isError: true);
                      }
                    },
              icon: const Icon(Icons.science_outlined, size: 18),
              label: const Text('Simulate bids now (demo)'),
            )
          : null,
    );
  }
}
