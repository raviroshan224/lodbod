import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Step chips for the posting flow, after the brief's reference screens:
/// "✓ Route · 2 Cargo · 3 Vehicle · 4 Review". The current step is filled,
/// completed steps are outlined in orange and can be tapped to go back.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.current,
    required this.titles,
    this.onTapStep,
  });

  final int current;
  final List<String> titles;
  final ValueChanged<int>? onTapStep;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step ${current + 1} of ${titles.length}: ${titles[current]}',
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(Gap.page, 2, Gap.page, Gap.md),
        child: Row(
          children: [
            for (var i = 0; i < titles.length; i++) ...[
              if (i > 0) Space.h8,
              _chip(i),
            ],
          ],
        ),
      ),
    );
  }

  Widget _chip(int i) {
    final done = i < current;
    final active = i == current;
    final tappable = done && onTapStep != null;
    final fg = active
        ? Colors.white
        : done
        ? AppColors.primary
        : AppColors.textSecondary;
    return Semantics(
      button: tappable,
      selected: active,
      label: '${titles[i]}${done ? ', completed' : ''}',
      excludeSemantics: true,
      child: Material(
        color: active ? AppColors.primary : AppColors.surface,
        shape: StadiumBorder(
          side: BorderSide(
            color: active
                ? AppColors.primary
                : done
                ? AppColors.primary.withValues(alpha: 0.6)
                : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: tappable
              ? () {
                  HapticFeedback.selectionClick();
                  onTapStep!(i);
                }
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (done)
                  Icon(Icons.check_rounded, size: 14, color: fg)
                else
                  Text(
                    '${i + 1}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: fg,
                    ),
                  ),
                const SizedBox(width: 5),
                Text(
                  titles[i],
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
