import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../data/models/bid.dart';

/// One carrier offer. Every bid shows the same fields in the same places so
/// offers can be compared at a glance; no bid is singled out as "best".
class BidCard extends StatelessWidget {
  const BidCard({
    super.key,
    required this.bid,
    required this.displayStatus,
    required this.pickupAt,
    required this.onTap,
    this.budget,
  });

  final Bid bid;
  final BidStatus displayStatus;
  final DateTime pickupAt;
  final VoidCallback onTap;

  /// The shipper's own budget, if they set one.
  final int? budget;

  /// Neutral difference from the budget. Deliberately not coloured or
  /// ranked: a cheaper offer is not automatically the better one.
  static String budgetDelta(int fare, int budget) {
    final diff = fare - budget;
    if (diff == 0) return 'Matches';
    return diff < 0 ? '${Fmt.npr(-diff)} under' : '${Fmt.npr(diff)} over';
  }

  @override
  Widget build(BuildContext context) {
    final accepted = displayStatus == BidStatus.accepted;
    final declined = displayStatus == BidStatus.declined;
    return Opacity(
      opacity: declined ? 0.6 : 1,
      child: AppCard(
        onTap: onTap,
        borderColor: accepted ? AppColors.success : AppColors.border,
        padding: const EdgeInsets.fromLTRB(Gap.lg, 14, Gap.lg, 12),
        semanticLabel:
            '${bid.carrierName}, ${Fmt.npr(bid.fare)}, ${Fmt.days(bid.estimatedDeliveryDays)}, rated ${bid.carrierRating}',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InitialsAvatar(
                  Fmt.initials(bid.carrierName),
                  size: 40,
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
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
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
                if (displayStatus != BidStatus.pending)
                  BidStatusBadge(displayStatus)
                else
                  Text(
                    Fmt.npr(bid.fare),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // The fare sits top-right while the offer is open; once the
                // status badge takes that spot, show it here instead.
                if (displayStatus != BidStatus.pending)
                  Expanded(
                    child: _Metric(label: 'Fare', value: Fmt.npr(bid.fare)),
                  )
                else if (budget != null)
                  Expanded(
                    child: _Metric(
                      label: 'Budget',
                      value: budgetDelta(bid.fare, budget!),
                    ),
                  ),
                Expanded(
                  child: _Metric(
                    label: 'Delivery',
                    value: Fmt.days(bid.estimatedDeliveryDays),
                    caption:
                        'by ${Fmt.dayMonth(bid.estimatedDeliveryFrom(pickupAt))}',
                  ),
                ),
                Expanded(
                  child: _Metric(
                    label: 'Vehicle',
                    value: bid.vehicleType.label,
                  ),
                ),
              ],
            ),
            Space.v8,
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Received ${Fmt.relative(bid.createdAt).toLowerCase()}',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Text(
                  'Details',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 18,
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
      label: 'Rated ${rating.toStringAsFixed(1)} out of 5 from $trips trips',
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
              '  ·  $trips trips',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12.5,
              ),
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
          style: const TextStyle(
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
            style: const TextStyle(color: AppColors.textMuted, fontSize: 11.5),
          ),
      ],
    );
  }
}
