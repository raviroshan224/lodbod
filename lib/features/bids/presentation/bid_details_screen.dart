import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/shipment_visuals.dart';
import '../domain/bid.dart';
import '../domain/bid_rules.dart';
import 'accept_bid.dart';
import 'widgets/bid_card.dart';

class BidDetailsScreen extends ConsumerWidget {
  const BidDetailsScreen({
    super.key,
    required this.shipmentId,
    required this.bidId,
  });
  final String shipmentId;
  final String bidId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipmentAsync = ref.watch(shipmentByIdProvider(shipmentId));
    final bidsAsync = ref.watch(bidsProvider(shipmentId));

    final Widget body;
    Widget? bottom;
    switch ((shipmentAsync, bidsAsync)) {
      case (AsyncError(:final error), _) || (_, AsyncError(:final error)):
        body = ErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(shipmentsProvider);
            ref.invalidate(bidsProvider(shipmentId));
          },
        );
      case (AsyncData(value: final s?), AsyncData(value: final bids)):
        final bid = bids.where((b) => b.id == bidId).firstOrNull;
        if (bid == null) {
          body = Center(
            child: EmptyView(
              icon: Icons.search_off_rounded,
              title: l10n.offerNotFound,
              message: l10n.offerNotFoundBody,
            ),
          );
        } else {
          final status = effectiveBidStatus(bid, s);
          body = _Details(
            shipment: s,
            bid: bid,
            status: status,
            otherBids: bids.length - 1,
          );
          // Always mounted (it collapses when the bid can't be accepted) so
          // the accept flow can still show feedback and navigate after the
          // live stream reflects the new state.
          bottom = _AcceptBar(
            shipment: s,
            bid: bid,
            otherBids: bids.length - 1,
            acceptable:
                s.status == ShipmentStatus.awaitingBids &&
                status == BidStatus.pending,
          );
        }
      case (AsyncData(value: null), _):
        body = Center(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: l10n.detailsNotFound,
            message: l10n.detailsRemoved,
          ),
        );
      default:
        body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: DetailAppBar(
        title: l10n.offerTitle,
        subtitle: shipmentAsync.value?.reference,
      ),
      body: body,
      bottomNavigationBar: bottom,
    );
  }
}

class _Details extends StatelessWidget {
  const _Details({
    required this.shipment,
    required this.bid,
    required this.status,
    required this.otherBids,
  });

  final Shipment shipment;
  final Bid bid;
  final BidStatus status;
  final int otherBids;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    final eta = bid.estimatedDeliveryFrom(s.pickupAt);
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xs, Gap.page, Gap.xl),
      children: [
        if (status == BidStatus.accepted) ...[
          InlineBanner(
            tone: BannerTone.success,
            title: l10n.offerBooked,
            message: Fmt.sentence(
              l10n.offerBookedBody(
                s.reference,
                s.status.label.toLowerCase(),
                bid.carrierName,
              ),
            ),
          ),
          Space.v12,
        ] else if (status == BidStatus.declined) ...[
          InlineBanner(
            tone: BannerTone.info,
            message: s.acceptedBidId != null
                ? l10n.offerNotSelectedBody(s.reference)
                : l10n.offerClosedBody(
                    s.reference,
                    s.status.label.toLowerCase(),
                  ),
          ),
          Space.v12,
        ],
        AppCard(
          padding: const EdgeInsets.all(Gap.xl),
          child: Column(
            children: [
              InitialsAvatar(
                Fmt.initials(bid.carrierName),
                size: 60,
                soft: true,
              ),
              Space.v12,
              Text(
                bid.carrierName,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              Space.v4,
              RatingText(rating: bid.carrierRating, trips: bid.completedTrips),
              Space.v20,
              Text(
                l10n.offerFare,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              Text(
                Fmt.npr(bid.fare),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              if (s.expectedFare != null) ...[
                Space.v4,
                _BudgetDelta(fare: bid.fare, budget: s.expectedFare!),
              ],
            ],
          ),
        ),
        Space.v12,
        SectionCard(
          title: l10n.offerSection,
          child: Column(
            children: [
              InfoRow(
                l10n.bidDelivery,
                l10n.offerAfterPickup(Fmt.days(bid.estimatedDeliveryDays)),
                icon: Icons.timer_outlined,
              ),
              InfoRow(
                l10n.offerArrivesBy,
                l10n.offerEstimate(Fmt.weekdayDayMonth(eta)),
                icon: Icons.flag_outlined,
              ),
              InfoRow(
                l10n.stepVehicle,
                bid.vehicleType.label,
                icon: vehicleIcon(bid.vehicleType),
              ),
              InfoRow(
                l10n.offerReceived,
                Fmt.relative(bid.createdAt),
                icon: Icons.schedule_rounded,
              ),
              if (bid.note.isNotEmpty)
                InfoRow(
                  l10n.offerNote,
                  bid.note,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
            ],
          ),
        ),
        Space.v12,
        SectionCard(
          title: l10n.offerYourLoad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RouteText(s.pickup, s.destination),
              Space.v8,
              InfoRow(
                l10n.stepCargo,
                l10n.bidsCargoWeight(s.cargoDescription, s.weightLabel),
              ),
              InfoRow(l10n.offerPickup, Fmt.dateTime(s.pickupAt)),
              InfoRow(l10n.offerRequested, s.vehicleType.label),
            ],
          ),
        ),
      ],
    );
  }
}

class _BudgetDelta extends StatelessWidget {
  const _BudgetDelta({required this.fare, required this.budget});
  final int fare;
  final int budget;

  @override
  Widget build(BuildContext context) {
    final diff = fare - budget;
    final text = diff == 0
        ? l10n.offerMatchesBudget
        : l10n.offerDiffBudget(
            Fmt.npr(diff.abs()),
            diff > 0 ? l10n.over : l10n.under,
          );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: Radii.chip,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AcceptBar extends ConsumerWidget {
  const _AcceptBar({
    required this.shipment,
    required this.bid,
    required this.otherBids,
    required this.acceptable,
  });
  final Shipment shipment;
  final Bid bid;
  final int otherBids;
  final bool acceptable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final running = ref.watch(shipmentActionsProvider(shipment.id));
    if (!acceptable && running != ShipmentAction.acceptBid) {
      return const SizedBox.shrink();
    }

    Future<void> accept() => confirmAndAcceptBid(
      context,
      ref,
      shipment: shipment,
      bid: bid,
      otherBids: otherBids,
    );

    return BottomActionBar(
      caption: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: AppColors.textMuted,
          ),
          SizedBox(width: 6),
          Flexible(
            child: Text(
              l10n.offerConfirmNote,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      child: PrimaryButton(
        label: l10n.acceptFor(Fmt.npr(bid.fare)),
        icon: Icons.check_rounded,
        loading: running == ShipmentAction.acceptBid,
        onPressed: running == null ? accept : null,
      ),
    );
  }
}
