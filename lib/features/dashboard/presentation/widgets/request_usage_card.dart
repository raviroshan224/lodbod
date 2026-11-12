import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common.dart';
import '../../../shipments/domain/request_limit.dart';

/// Home's request-limit card: how many of the 3 mobile requests are in use,
/// one meter segment per request, and the one action that makes sense now
/// (post a load while a slot is free, otherwise manage the open requests).
///
/// Kept to a strip: Home's primary action is the + button in the tab bar,
/// so this card only needs to report the quota, not compete with it.
class RequestUsageCard extends StatelessWidget {
  const RequestUsageCard({
    super.key,
    required this.usage,
    required this.onPostLoad,
    required this.onManage,
    required this.onLearnMore,
  });

  final RequestLimitUsage usage;
  final VoidCallback onPostLoad;
  final VoidCallback onManage;
  final VoidCallback onLearnMore;

  String get _message {
    if (usage.isAtLimit) {
      return 'All ${usage.limit} are in use. Finish or cancel one to post a new load.';
    }
    if (usage.used == 0) {
      return 'You can have up to ${usage.limit} open requests from mobile.';
    }
    final n = usage.remaining;
    return 'You can post $n more ${n == 1 ? 'load' : 'loads'} from mobile.';
  }

  @override
  Widget build(BuildContext context) {
    final atLimit = usage.isAtLimit;
    return AppCard(
      padding: const EdgeInsets.fromLTRB(Gap.lg, Gap.md, Gap.sm, Gap.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Mobile requests',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              _SlotMeter(used: usage.used, limit: usage.limit),
              Space.h4,
              IconButton(
                onPressed: onLearnMore,
                tooltip: 'How the request limit works',
                visualDensity: VisualDensity.compact,
                iconSize: 20,
                icon: const Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Text(
            '${usage.used} of ${usage.limit} in use',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.2,
              color: AppColors.textPrimary,
            ),
          ),
          Space.v4,
          Padding(
            padding: const EdgeInsets.only(right: Gap.sm),
            child: Text(
              _message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Space.v4,
          // Text action rather than a full button: the + tab already posts,
          // and the Shipments tab already lists, so this is a shortcut.
          TextButton.icon(
            onPressed: atLimit ? onManage : onPostLoad,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(48, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.chevron_right_rounded, size: 20),
            label: Text(atLimit ? 'Manage requests' : 'Post a new load'),
          ),
        ],
      ),
    );
  }
}

class _SlotMeter extends StatelessWidget {
  const _SlotMeter({required this.used, required this.limit});
  final int used;
  final int limit;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$used of $limit mobile requests in use',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < limit; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              width: 22,
              height: 6,
              decoration: BoxDecoration(
                color: i < used
                    ? AppColors.primary
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
