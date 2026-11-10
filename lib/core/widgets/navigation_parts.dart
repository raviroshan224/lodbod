import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'common.dart';

/// App bar for pushed screens: circular back button, title and optional
/// subtitle and actions.
class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.onBack,
    this.closeIcon = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final VoidCallback? onBack;
  final bool closeIcon;

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 64,
      leadingWidth: 64,
      leading: Center(
        child: CircleIconButton(
          icon: closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded,
          tooltip: closeIcon ? 'Close' : 'Back',
          size: 40,
          onPressed:
              onBack ??
              () => context.canPop() ? context.pop() : context.go('/home'),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (subtitle != null)
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [...actions, Space.h8],
    );
  }
}

/// Large title header for top-level tabs.
class TabHeader extends StatelessWidget {
  const TabHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.inset = true,
  });
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  /// False when the parent already applies the page's side padding.
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final side = inset ? Gap.page : 0.0;
    return Padding(
      padding: EdgeInsets.fromLTRB(side, Gap.md, side, Gap.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineMedium),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Pill-shaped segmented control (Phone | Email, periods, sort orders).
class PillTabs<T> extends StatelessWidget {
  const PillTabs({
    super.key,
    required this.values,
    required this.selected,
    required this.labelOf,
    required this.onChanged,
    this.iconOf,
  });

  final List<T> values;
  final T selected;
  final String Function(T) labelOf;
  final IconData? Function(T)? iconOf;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: Radii.button,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          for (final v in values)
            Expanded(
              child: Semantics(
                selected: v == selected,
                button: true,
                label: labelOf(v),
                excludeSemantics: true,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onChanged == null
                      ? null
                      : () {
                          if (v != selected) HapticFeedback.selectionClick();
                          onChanged!(v);
                        },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    height: 40,
                    decoration: BoxDecoration(
                      color: v == selected
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (iconOf?.call(v) != null) ...[
                          Icon(
                            iconOf!(v),
                            size: 17,
                            color: v == selected
                                ? Colors.white
                                : AppColors.textSecondary,
                          ),
                          Space.h6,
                        ],
                        Flexible(
                          child: Text(
                            labelOf(v),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: v == selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Selectable chip used for filters, dates, times and categories.
class ChoicePill extends StatelessWidget {
  const ChoicePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.caption,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final String? caption;

  /// Disabled pills are shown but can't be chosen (e.g. a time slot that
  /// has already passed today).
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final fg = selected
        ? Colors.white
        : enabled
        ? AppColors.textPrimary
        : AppColors.textMuted;
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      label: caption == null ? label : '$label, $caption',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppColors.primary
            : enabled
            ? AppColors.surface
            : AppColors.surfaceMuted,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(caption == null ? 999 : 12),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.selectionClick();
                  onTap();
                }
              : null,
          // Centre within whatever height the parent gives (tight in
          // horizontal lists, loose in wraps) so text never overflows.
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                // In a fixed-size cell (grids) shrink the content rather than
                // overflow; elsewhere the pill just takes its natural size.
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(
                              icon,
                              size: 16,
                              color: selected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                            ),
                            Space.h6,
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: fg,
                            ),
                          ),
                        ],
                      ),
                      if (caption != null)
                        Text(
                          caption!,
                          style: TextStyle(
                            fontSize: 11,
                            color: selected
                                ? Colors.white.withValues(alpha: 0.85)
                                : AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// iOS-style grouped list for settings-like screens.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, Gap.lg, 4, Gap.sm),
            child: Text(
              title!.toUpperCase(),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
          ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 56),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Gap.lg, vertical: 13),
        child: Row(
          children: [
            Icon(icon, size: 21, color: iconColor),
            const SizedBox(width: 19),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Space.v2,
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
