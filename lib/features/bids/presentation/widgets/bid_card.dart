import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/common.dart';
import '../../domain/bid.dart';
import 'bid_status_badge.dart';

/// One carrier offer. Every bid shows the same fields in the same places so
/// offers can be compared at a glance; no bid is singled out as "best".
/// While the offer is open the card has its own Accept and Details actions.
class BidCard extends StatelessWidget {
  const BidCard({
    super.key,
    required this.bid,
    required this.displayStatus,
    required this.pickupAt,
    required this.onTap,
    this.budget,
    this.onAccept,
    this.accepting = false,
  });

  final Bid bid;
  final BidStatus displayStatus;
  final DateTime pickupAt;
  final VoidCallback onTap;

  /// The shipper's own budget, if they set one.
  final int? budget;

  /// Shown as an Accept button while the offer can be accepted; null when
  /// it can't (or another action is already running).
  final VoidCallback? onAccept;

  /// This card's accept is in progress.
  final bool accepting;

  /// Neutral difference from the budget. Deliberately not coloured or
  /// ranked: a cheaper offer is not automatically the better one.
  static String budgetDelta(int fare, int budget) {
    final diff = fare - budget;
    if (diff == 0) return l10n.matches;
    return diff < 0
        ? l10n.bidUnder(Fmt.npr(-diff))
        : l10n.bidOver(Fmt.npr(diff));
  }

  @override
  Widget build(BuildContext context) {
    final pending = displayStatus == BidStatus.pending;
    final accepted = displayStatus == BidStatus.accepted;
    final declined = displayStatus == BidStatus.declined;
    final showActions = pending && (onAccept != null || accepting);
    return Opacity(
      opacity: declined ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        borderColor: accepted ? AppColors.success : null,
        padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.lg, Gap.lg, Gap.md),
        semanticLabel: l10n.bidA11y(
          bid.carrierName,
          Fmt.npr(bid.fare),
          Fmt.days(bid.estimatedDeliveryDays),
          '${bid.carrierRating}',
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                InitialsAvatar(
                  Fmt.initials(bid.carrierName),
                  size: 44,
                  soft: true,
                ),
                Space.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bid.carrierName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Space.v2,
                      RatingText(
                        rating: bid.carrierRating,
                        trips: bid.completedTrips,
                      ),
                    ],
                  ),
                ),
                Space.h8,
                if (pending)
                  Text(
                    Fmt.npr(bid.fare),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  )
                else
                  BidStatusBadge(displayStatus),
              ],
            ),
            Space.v16,
            // Facts on a tonal strip so they read as one comparable unit.
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // The fare sits top-right while the offer is open; once
                  // the status badge takes that spot, show it here instead.
                  if (!pending)
                    Expanded(
                      child: _Metric(
                        label: l10n.acceptFare,
                        value: Fmt.npr(bid.fare),
                      ),
                    )
                  else if (budget != null)
                    Expanded(
                      child: _Metric(
                        label: l10n.reviewBudget,
                        value: budgetDelta(bid.fare, budget!),
                      ),
                    ),
                  Expanded(
                    child: _Metric(
                      label: l10n.bidDelivery,
                      value: Fmt.days(bid.estimatedDeliveryDays),
                      caption: l10n.bidBy(
                        Fmt.dayMonth(bid.estimatedDeliveryFrom(pickupAt)),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _Metric(
                      label: l10n.stepVehicle,
                      value: bid.vehicleType.label,
                    ),
                  ),
                ],
              ),
            ),
            Space.v12,
            if (showActions) ...[
              Text(
                l10n.bidReceived(Fmt.relative(bid.createdAt).toLowerCase()),
                style: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              ),
              Space.v12,
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: accepting ? null : onTap,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                      ),
                      child: Text(l10n.actionDetails),
                    ),
                  ),
                  Space.h8,
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: accepting ? null : onAccept,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      icon: accepting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check_rounded, size: 20),
                      label: Text(l10n.actionAccept),
                    ),
                  ),
                ],
              ),
            ] else
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.bidReceived(
                        Fmt.relative(bid.createdAt).toLowerCase(),
                      ),
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                  Text(
                    l10n.actionDetails,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class RatingText extends StatelessWidget {
  const RatingText({super.key, required this.rating, required this.trips});
  final double rating;
  final int trips;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: l10n.bidRatedA11y(rating.toStringAsFixed(1), trips),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 15, color: Color(0xFFE8A200)),
          const SizedBox(width: 3),
          Text(
            rating.toStringAsFixed(1),
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          Flexible(
            child: Text(
              l10n.bidTrips(trips),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value, this.caption});
  final String label;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        Space.v2,
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
        ),
        if (caption != null)
          Text(
            caption!,
            style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
      ],
    );
  }
}
