import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Step header for the posting flow: the step's name with "Step 2 of 4"
/// beside it, over a segmented progress bar. Completed segments can be
/// tapped to go back to that step.
///
/// Kept to one text line so the first input stays above the fold on small
/// phones (the app bar already says "Post a load").
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.current,
    required this.titles,
    this.onTapStep,
  });

  /// Index of the current step in [titles].
  final int current;
  final List<String> titles;
  final ValueChanged<int>? onTapStep;

  @override
  Widget build(BuildContext context) {
    final count = titles.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.page + 4, 0, Gap.page + 4, Gap.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.centerLeft,
                    children: [...previous, ?current],
                  ),
                  child: Text(
                    titles[current],
                    key: ValueKey(current),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ),
              Space.h12,
              Text(
                'Step ${current + 1} of $count',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          Space.v4,
          Row(
            children: [
              for (var i = 0; i < count; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(child: _segment(i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _segment(int i) {
    final done = i < current;
    final reached = i <= current;
    final tappable = done && onTapStep != null;
    return Semantics(
      button: tappable,
      label:
          '${titles[i]}${done
              ? ', completed'
              : i == current
              ? ', current step'
              : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: tappable
            ? () {
                HapticFeedback.selectionClick();
                onTapStep!(i);
              }
            : null,
        // A taller hit area than the visible bar.
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            height: 4,
            decoration: BoxDecoration(
              color: reached ? AppColors.primary : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
