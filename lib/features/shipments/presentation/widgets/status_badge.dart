import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/common.dart';
import '../../domain/shipment.dart';
import 'shipment_visuals.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.dense = false});
  final ShipmentStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) => Pill(
    label: status.label,
    style: shipmentStatusStyle(status),
    dense: dense,
  );
}
