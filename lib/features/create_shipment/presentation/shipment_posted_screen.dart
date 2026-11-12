import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../routing/routes.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/status_badge.dart';
import 'create_shipment_controller.dart';
import 'open_post_load.dart';

/// Confirmation after a successful post. Only reachable once the shipment
/// has actually been created.
class ShipmentPostedScreen extends ConsumerWidget {
  const ShipmentPostedScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final live = ref.watch(shipmentByIdProvider(shipmentId)).value;
    final created = ref.watch(
      createShipmentProvider.select((s) => s.lastCreated),
    );
    final shipment = live ?? (created?.id == shipmentId ? created : null);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned(
              top: -120,
              left: 0,
              right: 0,
              height: 420,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [Color(0xFFFFE1D1), AppColors.background],
                    radius: 0.7,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        Gap.xl,
                        Gap.xxl * 1.5,
                        Gap.xl,
                        Gap.xl,
                      ),
                      child: Column(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.6, end: 1),
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.elasticOut,
                            builder: (_, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(26),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.35,
                                    ),
                                    blurRadius: 30,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                          ),
                          Space.v24,
                          Text(
                            l10n.postedTitle,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          Space.v8,
                          Text(
                            shipment == null
                                ? l10n.postedLive
                                : l10n.postedLiveBody(shipment.reference),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              height: 1.45,
                              fontSize: 14.5,
                            ),
                          ),
                          Space.v24,
                          if (shipment != null)
                            AppCard(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.postedRequestCreated,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 1,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  Space.v12,
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          shipment.reference,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      StatusBadge(shipment.status),
                                    ],
                                  ),
                                  Space.v8,
                                  RouteText(
                                    shipment.pickup,
                                    shipment.destination,
                                  ),
                                  Space.v8,
                                  InfoRow(
                                    l10n.offerPickup,
                                    '${Fmt.weekdayDayMonth(shipment.pickupAt)}, ${Fmt.time(shipment.pickupAt)}',
                                  ),
                                  InfoRow(
                                    l10n.stepCargo,
                                    l10n.bidsCargoWeight(
                                      shipment.cargoDescription,
                                      shipment.weightLabel,
                                    ),
                                  ),
                                  InfoRow(
                                    l10n.stepVehicle,
                                    shipment.vehicleType.label,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Gap.xl,
                      0,
                      Gap.xl,
                      Gap.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrimaryButton(
                          label: l10n.postedViewRequest,
                          onPressed: () =>
                              context.go(Routes.shipment(shipmentId)),
                        ),
                        Space.v4,
                        TextButton(
                          // Post Load is nested under Home, so this lands on a
                          // fresh form with Home underneath.
                          onPressed: () =>
                              openPostLoad(context, ref, replace: true),
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(46),
                          ),
                          child: Text(l10n.postedPostAnother),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
