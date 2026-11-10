import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Material 3 step header: "Step 2 of 4", the step's name, and a segmented
/// progress bar. Completed segments can be tapped to go back to that step.
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
      padding: const EdgeInsets.fromLTRB(Gap.page + 4, 0, Gap.page + 4, Gap.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Step ${current + 1} of $count',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          Space.v2,
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              titles[current],
              key: ValueKey(current),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          Space.v12,
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
            height: 6,
            decoration: BoxDecoration(
              color: reached ? AppColors.primary : AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
