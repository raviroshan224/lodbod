import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/common.dart';
import '../../../shipments/domain/request_limit.dart';

/// Home's "Ship something new" card, after the brief's reference screen:
/// title, "Mobile requests used: n of 3", the Post Load button, and a thin
/// usage bar. At the limit the button becomes "Manage requests" and one
/// line says what to do about it.
class RequestUsageCard extends StatefulWidget {
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

  @override
  State<RequestUsageCard> createState() => _RequestUsageCardState();
}

class _RequestUsageCardState extends State<RequestUsageCard> {
  late final _learnMore = TapGestureRecognizer()
    ..onTap = () => widget.onLearnMore();

  @override
  void dispose() {
    _learnMore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final usage = widget.usage;
    final atLimit = usage.isAtLimit;
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.55),
      padding: const EdgeInsets.fromLTRB(Gap.lg, 14, Gap.md, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ship something new',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    Space.v4,
                    Text.rich(
                      TextSpan(
                        text: 'Mobile requests used: ',
                        children: [
                          TextSpan(
                            text: '${usage.used} of ${usage.limit}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (!atLimit) ...[
                Space.h12,
                Flexible(
                  child: FilledButton.icon(
                    onPressed: widget.onPostLoad,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                      padding: const EdgeInsets.fromLTRB(12, 0, 16, 0),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('Post Load', maxLines: 1),
                  ),
                ),
              ],
            ],
          ),
          Space.v12,
          Semantics(
            label: '${usage.used} of ${usage.limit} mobile requests in use',
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: usage.fraction),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOut,
                builder: (_, f, _) => LinearProgressIndicator(
                  value: f,
                  minHeight: 6,
                  // ignore: deprecated_member_use
                  year2023: true,
                  backgroundColor: AppColors.primaryContainer,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          if (atLimit) ...[
            Space.v8,
            Text.rich(
              TextSpan(
                text:
                    'All ${usage.limit} are in use. Finish or cancel one to '
                    'post a new load. ',
                children: [
                  TextSpan(
                    text: 'How it works',
                    recognizer: _learnMore,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              style: const TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppColors.textSecondary,
              ),
            ),
            Space.v12,
            OutlinedButton(
              onPressed: widget.onManage,
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(42),
                visualDensity: VisualDensity.compact,
              ),
              child: const Text('Manage requests'),
            ),
          ],
        ],
      ),
    );
  }
}
