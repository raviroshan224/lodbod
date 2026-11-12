import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/common.dart';
import '../../domain/shipment.dart';
import 'shipment_visuals.dart';
import 'status_badge.dart';

/// Summary card for one shipment, used on Home and the Shipments list.
class ShipmentCard extends StatelessWidget {
  const ShipmentCard({super.key, required this.shipment, required this.onTap});

  final Shipment shipment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.fromLTRB(Gap.lg, 14, Gap.lg, 12),
      semanticLabel:
          '${s.reference}, ${s.status.label}, ${s.pickup} to ${s.destination}',
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
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              StatusBadge(s.status, dense: true),
            ],
          ),
          Space.v6,
          RouteText(s.pickup, s.destination),
          Space.v8,
          Wrap(
            spacing: 14,
            runSpacing: 4,
            children: [
              IconText(
                cargoIcon(s.cargoCategory),
                '${s.cargoDescription} · ${s.weightLabel}',
              ),
              IconText(Icons.calendar_today_outlined, Fmt.dayMonth(s.pickupAt)),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 11),
            child: Divider(),
          ),
          _Footer(shipment: s),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    final (Widget left, Widget right) = switch (s.status) {
      ShipmentStatus.awaitingBids => (
        IconText(
          s.bidCount > 0 ? Icons.schedule_rounded : Icons.hourglass_top_rounded,
          s.bidCount > 0
              ? 'Posted ${Fmt.relative(s.createdAt)}'
              : 'Waiting for bids',
        ),
        s.bidCount > 0
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${s.bidCount} ${s.bidCount == 1 ? 'bid' : 'bids'}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: s.expectedFare == null
                          ? '  ·  Fare pending'
                          : '  ·  Budget ${Fmt.npr(s.expectedFare!)}',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                style: const TextStyle(fontSize: 12.5),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                s.expectedFare == null
                    ? 'Fare pending'
                    : 'Budget ${Fmt.npr(s.expectedFare!)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
      ShipmentStatus.cancelled || ShipmentStatus.expired => (
        IconText(
          Icons.history_rounded,
          '${s.status.label} ${Fmt.relative(s.updatedAt).toLowerCase()}',
        ),
        const SizedBox.shrink(),
      ),
      ShipmentStatus.delivered => (
        IconText(
          Icons.check_circle_outline_rounded,
          'Delivered ${Fmt.dayMonth(s.reachedAt(ShipmentStatus.delivered) ?? s.updatedAt)}',
        ),
        _Amount(s.agreedFare),
      ),
      ShipmentStatus.inTransit => (
        IconText(
          Icons.near_me_outlined,
          _lastUpdate(s),
          color: AppColors.textSecondary,
        ),
        _Amount(s.agreedFare),
      ),
      _ => (
        IconText(Icons.badge_outlined, s.carrierName ?? 'Carrier assigned'),
        _Amount(s.agreedFare),
      ),
    };
    return Row(
      children: [
        Expanded(
          child: Align(alignment: Alignment.centerLeft, child: left),
        ),
        Space.h8,
        // Both sides can shrink so long values ellipsize on narrow screens
        // or with large text instead of overflowing.
        Flexible(child: right),
      ],
    );
  }

  static String _lastUpdate(Shipment s) {
    final at = s.reachedAt(ShipmentStatus.inTransit);
    return at == null
        ? 'On the way'
        : 'Picked up ${Fmt.relative(at).toLowerCase()}';
  }
}

class _Amount extends StatelessWidget {
  const _Amount(this.amount);
  final int? amount;

  @override
  Widget build(BuildContext context) {
    if (amount == null) return const SizedBox.shrink();
    return Text(
      Fmt.npr(amount!),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 15.5,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.2,
      ),
    );
  }
}
