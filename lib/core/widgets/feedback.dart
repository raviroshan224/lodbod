import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Primary call to action with a built-in busy state. While [loading] the
/// button is disabled so the action cannot be triggered twice.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: loading ? null : onPressed,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: loading
            ? const SizedBox(
                key: ValueKey('loading'),
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: Colors.white,
                ),
              )
            : Row(
                key: const ValueKey('label'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                  ],
                  Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(trailingIcon, size: 20),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Bottom-anchored action area used by detail and form screens.
class BottomActionBar extends StatelessWidget {
  const BottomActionBar({super.key, required this.child, this.caption});
  final Widget child;
  final Widget? caption;

  @override
  Widget build(BuildContext context) {
    // No fill: blends with the page it sits on (tinted screens, white auth).
    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            Gap.page,
            Gap.md,
            Gap.page,
            Gap.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (caption != null) ...[caption!, Space.v8],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// Confirmation as a bottom sheet. Resolves to `true` only if confirmed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Not now',
  bool destructive = false,
  IconData? icon,
  Widget? details,
}) async {
  final accent = destructive ? AppColors.error : AppColors.primary;
  final result = await showModalBottomSheet<bool>(
    // Above the tab bar, so it's dimmed and can't be tapped meanwhile.
    useRootNavigator: true,
    context: context,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.xl, 0, Gap.xl, Gap.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (icon != null) ...[
              Center(
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: destructive
                        ? AppColors.errorSoft
                        : AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: destructive
                        ? AppColors.error
                        : AppColors.onPrimaryContainer,
                  ),
                ),
              ),
              Space.v16,
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Space.v8,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.45,
              ),
            ),
            if (details != null) ...[Space.v16, details],
            Space.v24,
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(backgroundColor: accent),
              child: Text(confirmLabel),
            ),
            Space.v8,
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(cancelLabel),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

/// Toast-style feedback. Success feedback also gives a light haptic tick.
void showMessage(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  if (isError) {
    HapticFeedback.heavyImpact();
  } else {
    HapticFeedback.lightImpact();
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: Duration(seconds: actionLabel != null ? 5 : 3),
        // Snack bars with an action stay up by default; ours are shortcuts to
        // things also listed in Notifications, so let them time out.
        persist: false,
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : Icons.check_circle_rounded,
              color: isError
                  ? const Color(0xFFFF9F8F)
                  : const Color(0xFF7FDDA0),
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      ),
    );
}
