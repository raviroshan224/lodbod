import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/visuals.dart';
import '../../domain/shipment.dart';

/// Colours and icon for a shipment status. Status is always shown with text
/// as well as colour, so it never relies on colour alone.
StatusStyle shipmentStatusStyle(ShipmentStatus s) => switch (s) {
  ShipmentStatus.awaitingBids => StatusStyle(
    AppColors.info,
    AppColors.infoSoft,
    Icons.gavel_rounded,
  ),
  ShipmentStatus.confirmed => const StatusStyle(
    Color(0xFF0F766E),
    Color(0xFFE0F5F2),
    Icons.handshake_outlined,
  ),
  ShipmentStatus.scheduled => const StatusStyle(
    Color(0xFF6D28D9),
    Color(0xFFF0EBFD),
    Icons.event_available_outlined,
  ),
  ShipmentStatus.inTransit => const StatusStyle(
    Color(0xFFB93C0B),
    Color(0xFFFFEDE3),
    Icons.local_shipping_outlined,
  ),
  ShipmentStatus.delivered => StatusStyle(
    AppColors.success,
    AppColors.successSoft,
    Icons.check_circle_outline,
  ),
  ShipmentStatus.cancelled => StatusStyle(
    AppColors.error,
    AppColors.errorSoft,
    Icons.cancel_outlined,
  ),
  ShipmentStatus.expired => const StatusStyle(
    Color(0xFF4B5563),
    Color(0xFFEEEFF2),
    Icons.timer_off_outlined,
  ),
};

IconData vehicleIcon(VehicleType v) => switch (v) {
  VehicleType.openTruck => Icons.local_shipping_outlined,
  VehicleType.closedTruck => Icons.local_shipping_rounded,
  VehicleType.container => Icons.inventory_2_outlined,
  VehicleType.trailer => Icons.rv_hookup_outlined,
  VehicleType.tipper => Icons.agriculture_outlined,
  VehicleType.tanker => Icons.propane_tank_outlined,
  VehicleType.miniTruck => Icons.airport_shuttle_outlined,
};

IconData cargoIcon(CargoCategory c) => switch (c) {
  CargoCategory.cement => Icons.foundation_outlined,
  CargoCategory.steel => Icons.view_column_outlined,
  CargoCategory.construction => Icons.construction_outlined,
  CargoCategory.foodGrains => Icons.grass_outlined,
  CargoCategory.fmcg => Icons.shopping_basket_outlined,
  CargoCategory.furniture => Icons.chair_outlined,
  CargoCategory.electronics => Icons.devices_other_outlined,
  CargoCategory.other => Icons.category_outlined,
};
