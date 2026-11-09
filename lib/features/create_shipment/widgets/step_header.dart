import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Step chips (✓ Route · 2 Cargo · 3 Vehicle · 4 Review): shows where you
/// are and lets you jump back to a completed step.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.current,
    required this.labels,
    this.onTapStep,
  });

  final int current;
  final List<String> labels;
  final ValueChanged<int>? onTapStep;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Gap.page, 0, Gap.page, Gap.sm),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(child: _pill(i)),
          ],
        ],
      ),
    );
  }

  Widget _pill(int i) {
    final done = i < current;
    final active = i == current;
    final fg = active
        ? Colors.white
        : done
        ? AppColors.primary
        : AppColors.textSecondary;
    final tappable = done && onTapStep != null;
    return Semantics(
      button: tappable,
      label:
          '${labels[i]}${done
              ? ', completed'
              : active
              ? ', current step'
              : ''}',
      excludeSemantics: true,
      child: GestureDetector(
        onTap: tappable
            ? () {
                HapticFeedback.selectionClick();
                onTapStep!(i);
              }
            : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.surface,
            borderRadius: Radii.chip,
            border: Border.all(
              color: done
                  ? AppColors.primaryBorder
                  : active
                  ? AppColors.primary
                  : AppColors.border,
            ),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (done)
                    Icon(Icons.check_rounded, size: 14, color: fg)
                  else
                    Text(
                      '${i + 1} ',
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  if (done) const SizedBox(width: 3),
                  Text(
                    labels[i],
                    style: TextStyle(
                      color: fg,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
