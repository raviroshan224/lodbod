import 'package:material_ui/material_ui.dart';

import '../../data/models/bid.dart';
import '../../data/models/shipment.dart';
import '../theme/app_colors.dart';

/// Colours and icon for a status. Status is always shown with text as well
/// as colour, so it never relies on colour alone.
class StatusStyle {
  const StatusStyle(this.foreground, this.background, this.icon);
  final Color foreground;
  final Color background;
  final IconData icon;

  static StatusStyle of(ShipmentStatus s) => switch (s) {
    ShipmentStatus.awaitingBids => const StatusStyle(
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
    ShipmentStatus.delivered => const StatusStyle(
      AppColors.success,
      AppColors.successSoft,
      Icons.check_circle_outline,
    ),
    ShipmentStatus.cancelled => const StatusStyle(
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

  static StatusStyle ofBid(BidStatus s) => switch (s) {
    BidStatus.pending => const StatusStyle(
      AppColors.info,
      AppColors.infoSoft,
      Icons.schedule_rounded,
    ),
    BidStatus.accepted => const StatusStyle(
      AppColors.success,
      AppColors.successSoft,
      Icons.check_circle_outline,
    ),
    BidStatus.declined => const StatusStyle(
      Color(0xFF4B5563),
      Color(0xFFEEEFF2),
      Icons.remove_circle_outline,
    ),
  };
}

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
