import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/errors/app_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/common.dart';
import '../../core/widgets/feedback.dart';
import '../../core/widgets/navigation_parts.dart';
import '../../core/widgets/state_views.dart';
import '../../core/widgets/visuals.dart';
import '../../data/models/bid.dart';
import '../../data/models/shipment.dart';
import '../../domain/bid_rules.dart';
import '../../routing/routes.dart';
import '../shipments/shipments_providers.dart';
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
          body = const Center(
            child: EmptyView(
              icon: Icons.search_off_rounded,
              title: 'Bid not found',
              message: 'This bid may have been withdrawn.',
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
        body = const Center(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Shipment not found',
            message: 'It may have been removed.',
          ),
        );
      default:
        body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: DetailAppBar(
        title: 'Offer details',
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
            title: 'You booked this carrier',
            message: Fmt.sentence(
              '${s.reference} is ${s.status.label.toLowerCase()} with ${bid.carrierName}',
            ),
          ),
          Space.v12,
        ] else if (status == BidStatus.declined) ...[
          InlineBanner(
            tone: BannerTone.info,
            message: s.acceptedBidId != null
                ? 'Not selected: you booked another carrier for ${s.reference}.'
                : '${s.reference} is ${s.status.label.toLowerCase()}, so this offer can no longer be accepted.',
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
              const Text(
                'Offered fare',
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
          title: 'Offer',
          child: Column(
            children: [
              InfoRow(
                'Delivery',
                '${Fmt.days(bid.estimatedDeliveryDays)} after pickup',
                icon: Icons.timer_outlined,
              ),
              InfoRow(
                'Arrives by',
                '${Fmt.weekdayDayMonth(eta)} (estimate)',
                icon: Icons.flag_outlined,
              ),
              InfoRow(
                'Vehicle',
                bid.vehicleType.label,
                icon: vehicleIcon(bid.vehicleType),
              ),
              InfoRow(
                'Received',
                Fmt.relative(bid.createdAt),
                icon: Icons.schedule_rounded,
              ),
              if (bid.note.isNotEmpty)
                InfoRow(
                  'Note',
                  bid.note,
                  icon: Icons.chat_bubble_outline_rounded,
                ),
            ],
          ),
        ),
        Space.v12,
        SectionCard(
          title: 'Your load',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RouteText(s.pickup, s.destination),
              Space.v8,
              InfoRow('Cargo', '${s.cargoDescription} · ${s.weightLabel}'),
              InfoRow('Pickup', Fmt.dateTime(s.pickupAt)),
              InfoRow('Requested', s.vehicleType.label),
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
        ? 'Matches your budget'
        : '${Fmt.npr(diff.abs())} ${diff > 0 ? 'above' : 'below'} your budget';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: Radii.chip,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        style: const TextStyle(
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

    Future<void> accept() async {
      final confirmed = await confirmAction(
        context,
        title: 'Book ${bid.carrierName}?',
        message:
            'This confirms ${shipment.reference} with this carrier. '
            '${otherBids > 0 ? 'The other $otherBids ${otherBids == 1 ? 'offer' : 'offers'} will be declined. ' : ''}'
            "This can't be undone from the app.",
        confirmLabel: 'Accept for ${Fmt.npr(bid.fare)}',
        cancelLabel: 'Go back',
        icon: Icons.handshake_outlined,
        details: AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: Gap.md,
            vertical: Gap.sm,
          ),
          child: Column(
            children: [
              InfoRow('Route', shipment.routeLabel),
              InfoRow('Fare', Fmt.npr(bid.fare)),
              InfoRow(
                'Delivery',
                'About ${Fmt.days(bid.estimatedDeliveryDays)}',
              ),
            ],
          ),
        ),
      );
      if (!confirmed || !context.mounted) return;

      final error = await ref
          .read(shipmentActionsProvider(shipment.id).notifier)
          .acceptBid(bid.id);
      if (!context.mounted) return;
      if (error == null) {
        HapticFeedback.mediumImpact();
        showMessage(
          context,
          Fmt.sentence(
            'Booked! ${shipment.reference} is confirmed with ${bid.carrierName}',
          ),
        );
        context.go(Routes.shipment(shipment.id));
      } else if (error is BidAlreadyAcceptedException ||
          error is InvalidStateException) {
        showMessage(context, error.message, isError: true);
      } else {
        showMessage(
          context,
          "${error.message} The offer hasn't been accepted yet.",
          isError: true,
        );
      }
    }

    return BottomActionBar(
      caption: const Row(
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
              'You confirm before anything is booked',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Accept for ${Fmt.npr(bid.fare)}',
        icon: Icons.check_rounded,
        loading: running == ShipmentAction.acceptBid,
        onPressed: running == null ? accept : null,
      ),
    );
  }
}
