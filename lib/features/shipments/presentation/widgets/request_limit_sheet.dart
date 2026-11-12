import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common.dart';
import '../../../../routing/routes.dart';
import '../../domain/request_limit.dart';
import '../../domain/shipment.dart';
import 'status_badge.dart';

/// Explains the three-request rule. When [blocked] it leads with the
/// prescribed message: [detailsSaved] says whether a filled-in load was kept
/// (a submission was refused) or Post Load was stopped before the form.
Future<void> showRequestLimitSheet(
  BuildContext context,
  RequestLimitUsage usage, {
  bool blocked = false,
  bool detailsSaved = true,
}) {
  return showModalBottomSheet<void>(
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconTile(
                blocked ? Icons.block_rounded : Icons.layers_outlined,
                color: blocked ? AppColors.error : AppColors.primary,
                size: 48,
              ),
            ),
            Space.v16,
            Text(
              blocked ? l10n.reviewLimitReached : l10n.limitTitle,
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            Space.v8,
            Text(
              blocked
                  ? RequestLimit.message
                  : l10n.limitBody(RequestLimit.max, usage.used, usage.limit),
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            if (blocked) ...[
              Space.v8,
              Text(
                detailsSaved ? l10n.limitDetailsSaved : l10n.limitCanPost,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            Space.v20,
            ClipRRect(
              borderRadius: Radii.chip,
              child: LinearProgressIndicator(
                value: usage.fraction,
                minHeight: 8,
                color: usage.isAtLimit ? AppColors.error : AppColors.primary,
              ),
            ),
            Space.v6,
            Text(
              l10n.homeUsedOfInUse(usage.used, usage.limit),
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Space.v20,
            Text(
              l10n.limitCounts,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Space.v8,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in ShipmentStatus.values.where(
                  (s) => s.countsTowardRequestLimit,
                ))
                  StatusBadge(s),
              ],
            ),
            Space.v16,
            Text(
              l10n.limitDoesNotCount,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            Space.v8,
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in ShipmentStatus.values.where(
                  (s) => !s.countsTowardRequestLimit,
                ))
                  StatusBadge(s),
              ],
            ),
            Space.v24,
            FilledButton(
              onPressed: () {
                Navigator.of(sheetContext).pop();
                context.go(Routes.shipments);
              },
              child: Text(l10n.actionViewMyRequests),
            ),
            Space.v8,
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size.fromHeight(46),
              ),
              child: Text(l10n.actionGotIt),
            ),
          ],
        ),
      ),
    ),
  );
}
