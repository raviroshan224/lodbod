import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Material 3 top app bar for pushed screens: back (or close) icon, title
/// with an optional subtitle, and actions.
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
      leading: IconButton(
        icon: Icon(closeIcon ? Icons.close_rounded : Icons.arrow_back_rounded),
        tooltip: closeIcon ? l10n.close : l10n.back,
        onPressed:
            onBack ??
            () => context.canPop() ? context.pop() : context.go('/home'),
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
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
                letterSpacing: 0,
              ),
            ),
        ],
      ),
      actions: [...actions, Space.h4],
    );
  }
}

/// Large title for top-level tabs (Material 3 large top app bar style).
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
    return Padding(
      padding: EdgeInsets.fromLTRB(
        inset ? Gap.page + 4 : 4,
        Gap.lg,
        inset ? Gap.page : 0,
        Gap.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineLarge),
                if (subtitle != null) ...[
                  Space.v2,
                  Text(
                    subtitle!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

/// Material 3 segmented button (Phone | Email, periods): connected pill
/// segments, the selected one tonal with a check mark.
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

  static const _outline = Color(0xFFD8C2BC);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        borderRadius: Radii.chip,
        border: Border.all(color: _outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < values.length; i++) ...[
            if (i > 0) const VerticalDivider(width: 1, color: _outline),
            Expanded(child: _segment(values[i])),
          ],
        ],
      ),
    );
  }

  Widget _segment(T v) {
    final isSelected = v == selected;
    final icon = isSelected ? Icons.check_rounded : iconOf?.call(v);
    final fg = isSelected
        ? AppColors.onPrimaryContainer
        : AppColors.textSecondary;
    return Semantics(
      selected: isSelected,
      button: true,
      label: labelOf(v),
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.primaryContainer : Colors.transparent,
        child: InkWell(
          onTap: onChanged == null
              ? null
              : () {
                  if (!isSelected) HapticFeedback.selectionClick();
                  onChanged!(v);
                },
          // Narrow segments (e.g. a "Tonnes | kg" toggle) drop the icon so
          // the label always fits.
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null && constraints.maxWidth >= 96) ...[
                  Icon(icon, size: 18, color: fg),
                  Space.h6,
                ],
                Flexible(
                  child: Text(
                    labelOf(v),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: fg,
                    ),
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

/// Selectable chip used for filters, dates, times and categories. Selected
/// is tonal (Material 3 filter chip), so it never competes with buttons.
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
        ? AppColors.onPrimaryContainer
        : enabled
        ? AppColors.textPrimary
        : AppColors.textMuted;
    // A check replaces the icon on selected chips (none on tiles with a
    // caption, where the fill already shows the choice).
    final leading = selected && caption == null ? Icons.check_rounded : icon;
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      label: caption == null ? label : '$label, $caption',
      excludeSemantics: true,
      child: Material(
        color: selected
            ? AppColors.primaryContainer
            : enabled
            ? AppColors.surface
            : AppColors.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(caption == null ? 999 : 12),
          side: BorderSide(
            color: selected
                ? AppColors.primaryContainer
                : enabled
                ? const Color(0xFFD8C2BC)
                : Colors.transparent,
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
            constraints: const BoxConstraints(minHeight: 40),
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
                          if (leading != null) ...[
                            Icon(leading, size: 17, color: fg),
                            Space.h6,
                          ],
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 14,
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
                            fontSize: 12,
                            color: selected
                                ? AppColors.onPrimaryContainer
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

/// Grouped settings list after the reference Account screen: a small
/// uppercase label, then one white card with hairline dividers.
class ListGroup extends StatelessWidget {
  const ListGroup({super.key, this.title, required this.children});
  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, Gap.xl, 4, Gap.sm),
            child: Text(
              title!.toUpperCase(),
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.textMuted,
              ),
            ),
          ),
        Material(
          color: AppColors.surface,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(borderRadius: Radii.card),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 48, color: AppColors.divider),
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
    this.value,
    this.trailing,
    this.onTap,
    this.iconColor = AppColors.primary,
    this.titleColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;

  /// Current setting shown at the trailing edge, e.g. "2 of 3".
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(Gap.lg, 11, Gap.md, 11),
        child: Row(
          children: [
            SizedBox(width: 20, child: Icon(icon, size: 20, color: iconColor)),
            Space.h12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: value == null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    Space.v2,
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              // Right-aligned beside the chevron; the title gives way first,
              // and only a very long value (an email) truncates.
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.4,
                ),
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Space.h4,
            ],
            if (trailing != null)
              trailing!
            else if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
