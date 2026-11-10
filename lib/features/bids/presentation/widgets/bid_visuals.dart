import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/visuals.dart';
import '../../domain/bid.dart';

/// Colours and icon for a bid status, always shown with its label.
StatusStyle bidStatusStyle(BidStatus s) => switch (s) {
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
