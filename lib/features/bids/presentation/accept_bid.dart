import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../routing/routes.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../domain/bid.dart';

/// The one booking flow, used from the bid list and from offer details:
/// confirm in a sheet, accept (the shipment only changes after the server
/// commits), then show the booked shipment. Returns whether it was booked.
Future<bool> confirmAndAcceptBid(
  BuildContext context,
  WidgetRef ref, {
  required Shipment shipment,
  required Bid bid,
  required int otherBids,
}) async {
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
      color: const Color(0xFFFBF5F2),
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.sm),
      child: Column(
        children: [
          InfoRow('Route', shipment.routeLabel),
          InfoRow('Fare', Fmt.npr(bid.fare)),
          InfoRow('Delivery', 'About ${Fmt.days(bid.estimatedDeliveryDays)}'),
        ],
      ),
    ),
  );
  if (!confirmed || !context.mounted) return false;

  final error = await ref
      .read(shipmentActionsProvider(shipment.id).notifier)
      .acceptBid(bid.id);
  if (!context.mounted) return error == null;
  if (error == null) {
    HapticFeedback.mediumImpact();
    showMessage(
      context,
      Fmt.sentence(
        'Booked! ${shipment.reference} is confirmed with ${bid.carrierName}',
      ),
    );
    context.go(Routes.shipment(shipment.id));
    return true;
  }
  if (error is BidAlreadyAcceptedException || error is InvalidStateException) {
    showMessage(context, error.message, isError: true);
  } else {
    showMessage(
      context,
      "${error.message} The offer hasn't been accepted yet.",
      isError: true,
    );
  }
  return false;
}
