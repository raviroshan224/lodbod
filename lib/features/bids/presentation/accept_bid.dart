import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
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
    title: l10n.acceptTitle(bid.carrierName),
    message: l10n.acceptBody(
      shipment.reference,
      otherBids > 0 ? l10n.acceptOthersDeclined(otherBids) : '',
    ),
    confirmLabel: l10n.acceptFor(Fmt.npr(bid.fare)),
    cancelLabel: l10n.actionGoBack,
    icon: Icons.handshake_outlined,
    details: AppCard(
      color: const Color(0xFFFBF5F2),
      padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: Gap.sm),
      child: Column(
        children: [
          InfoRow(l10n.stepRoute, shipment.routeLabel),
          InfoRow(l10n.acceptFare, Fmt.npr(bid.fare)),
          InfoRow(
            l10n.bidDelivery,
            l10n.acceptAbout(Fmt.days(bid.estimatedDeliveryDays)),
          ),
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
      Fmt.sentence(l10n.acceptBooked(shipment.reference, bid.carrierName)),
    );
    context.go(Routes.shipment(shipment.id));
    return true;
  }
  if (error is BidAlreadyAcceptedException || error is InvalidStateException) {
    showMessage(context, error.message, isError: true);
  } else {
    showMessage(context, l10n.acceptFailed(error.message), isError: true);
  }
  return false;
}
