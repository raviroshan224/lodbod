import 'package:material_ui/material_ui.dart';

import '../l10n/strings.dart';
import '../theme/app_colors.dart';

class DockItem {
  const DockItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;

  /// Items needing attention on that tab (shown as a small count badge).
  final int badgeCount;
}

/// Bottom navigation after the brief's reference screens: labelled tabs,
/// the active one on a soft orange tile, and a round l10n.navPostLoad action
/// raised half above the bar with its label beneath it.
class DockNavBar extends StatelessWidget {
  const DockNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
    required this.actionLabel,
    required this.actionSemanticLabel,
    required this.onAction,
  }) : assert(items.length == 4, 'Two tabs either side of the action');

  final List<DockItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelect;
  final String actionLabel;
  final String actionSemanticLabel;
  final VoidCallback onAction;

  /// Stable handle on the centre action (for tests and automation).
  static const actionKey = ValueKey('dock-nav-action');

  static const _rowHeight = 66.0;
  static const _buttonSize = 56.0;
  static const _iconTileHeight = 30.0;
  static const _labelGap = 4.0;
  static const _inactive = Color(0xFF6F6966);

  /// How far the action rises above the bar's top edge. The strip above the
  /// bar is transparent, so the page shows through it; [AppShell] lets
  /// content scroll under that strip.
  static const overhang = _buttonSize / 2;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final barHeight = _rowHeight + bottomInset;
    return SizedBox(
      height: overhang + barHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: barHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++) _tab(context, i),
                    _actionSlot(context),
                    for (var i = 2; i < 4; i++) _tab(context, i),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Center(child: _actionButton()),
          ),
        ],
      ),
    );
  }

  static TextStyle _labelStyle(Color color) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: color,
  );

  /// Tab labels scale a little, never enough to push five of them off the
  /// bar (the icons and semantics carry the meaning at large sizes).
  static TextScaler _labelScaler(BuildContext context) =>
      MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);

  Widget _tab(BuildContext context, int i) {
    final item = items[i];
    final active = i == selectedIndex;
    final color = active ? AppColors.primary : _inactive;
    return Expanded(
      child: Tooltip(
        message: item.label,
        child: Semantics(
          button: true,
          selected: active,
          label: item.badgeCount > 0
              ? l10n.navNeedAttention(item.label, item.badgeCount)
              : item.label,
          excludeSemantics: true,
          child: InkWell(
            onTap: () => onSelect(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: _iconTileHeight,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primarySoft : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: _BadgedIcon(
                    icon: active ? item.selectedIcon : item.icon,
                    color: color,
                    count: item.badgeCount,
                  ),
                ),
                const SizedBox(height: _labelGap),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textScaler: _labelScaler(context),
                  style: _labelStyle(color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The gap under the raised button, carrying its label at the same
  /// baseline as the tab labels.
  Widget _actionSlot(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        width: 88,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: _iconTileHeight + _labelGap),
            Text(
              actionLabel,
              maxLines: 1,
              textScaler: _labelScaler(context),
              style: _labelStyle(AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton() {
    return Tooltip(
      message: actionLabel,
      child: Semantics(
        button: true,
        label: actionSemanticLabel,
        excludeSemantics: true,
        child: Material(
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          elevation: 6,
          shadowColor: AppColors.primary.withValues(alpha: 0.45),
          child: Ink(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF2834F), AppColors.primary],
              ),
            ),
            child: InkWell(
              key: actionKey,
              onTap: onAction,
              child: const SizedBox.square(
                dimension: _buttonSize,
                child: Icon(Icons.add_rounded, color: Colors.white, size: 30),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BadgedIcon extends StatelessWidget {
  const _BadgedIcon({
    required this.icon,
    required this.color,
    required this.count,
  });
  final IconData icon;
  final Color color;
  final int count;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 23, color: color);
    if (count <= 0) return iconWidget;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        iconWidget,
        Positioned(
          right: 6,
          top: 1,
          child: Container(
            constraints: const BoxConstraints(minWidth: 15),
            height: 15,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
