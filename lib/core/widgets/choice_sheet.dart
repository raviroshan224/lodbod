import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class ChoiceOption<T> {
  const ChoiceOption(this.value, this.label, {this.caption, this.icon});
  final T value;
  final String label;
  final String? caption;
  final IconData? icon;
}

/// Bottom sheet with one radio-style row per option. Resolves to the chosen
/// value, or null when dismissed.
Future<T?> showChoiceSheet<T>(
  BuildContext context, {
  required String title,
  required List<ChoiceOption<T>> options,
  required T selected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.sm, 0, Gap.sm, Gap.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Gap.lg,
                Gap.xs,
                Gap.lg,
                Gap.sm,
              ),
              child: Text(title, style: Theme.of(context).textTheme.titleLarge),
            ),
            for (final o in options)
              ListTile(
                leading: o.icon == null
                    ? null
                    : Icon(o.icon, color: AppColors.textSecondary),
                title: Text(o.label),
                subtitle: o.caption == null ? null : Text(o.caption!),
                trailing: o.value == selected
                    ? const Icon(Icons.check_rounded, color: AppColors.primary)
                    : null,
                selected: o.value == selected,
                selectedColor: AppColors.textPrimary,
                shape: RoundedRectangleBorder(borderRadius: Radii.input),
                onTap: () => Navigator.of(context).pop(o.value),
              ),
          ],
        ),
      ),
    ),
  );
}
