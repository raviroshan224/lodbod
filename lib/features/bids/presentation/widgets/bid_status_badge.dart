import 'package:material_ui/material_ui.dart';

import '../../../../core/widgets/common.dart';
import '../../domain/bid.dart';
import 'bid_visuals.dart';

class BidStatusBadge extends StatelessWidget {
  const BidStatusBadge(this.status, {super.key});
  final BidStatus status;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, style: bidStatusStyle(status));
}
