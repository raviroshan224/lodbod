import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

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
              blocked ? 'Request limit reached' : 'Mobile request limit',
              style: Theme.of(sheetContext).textTheme.headlineSmall,
            ),
            Space.v8,
            Text(
              blocked
                  ? RequestLimit.message
                  : 'You can have up to ${RequestLimit.max} open requests from the mobile app at a time. '
                        'You are using ${usage.used} of ${usage.limit}.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
            if (blocked) ...[
              Space.v8,
              Text(
                detailsSaved
                    ? 'Your details are saved. You can submit as soon as a request is delivered, cancelled or expires.'
                    : 'You can post a new load as soon as a request is delivered, cancelled or expires.',
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
              '${usage.used} of ${usage.limit} in use',
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            Space.v20,
            const Text(
              'Counts toward the limit',
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
            const Text(
              "Doesn't count",
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
              child: const Text('View my requests'),
            ),
            Space.v8,
            TextButton(
              onPressed: () => Navigator.of(sheetContext).pop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size.fromHeight(46),
              ),
              child: const Text('Got it'),
            ),
          ],
        ),
      ),
    ),
  );
}
