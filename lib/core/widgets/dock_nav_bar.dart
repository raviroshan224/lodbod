import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// One tab in [DockNavBar].
class DockItem {
  const DockItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;

  /// Shown as a tooltip and read by screen readers (the bar shows icons).
  final String label;

  /// Items needing attention on that tab (shown as a small count badge).
  final int badgeCount;
}

/// Bottom navigation: a soft white bar with rounded top corners, icon-only
/// tabs (the active one filled in the brand colour), and a large round
/// gradient action sitting half above the bar's top edge.
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

  /// Height of the icon row.
  static const _rowHeight = 60.0;

  static const _buttonSize = 64.0;

  /// How far the action rises above the bar's straight top edge (half its
  /// height). The strip above the bar is transparent, so the page shows
  /// through it; [AppShell] lets content scroll under that strip.
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
            child: CustomPaint(
              painter: const _BarPainter(corner: 24),
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomInset),
                child: Row(
                  children: [
                    for (var i = 0; i < 2; i++) _tab(i),
                    const Spacer(),
                    for (var i = 2; i < 4; i++) _tab(i),
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

  Widget _tab(int i) {
    final item = items[i];
    final active = i == selectedIndex;
    return Expanded(
      child: Tooltip(
        message: item.label,
        child: Semantics(
          button: true,
          selected: active,
          label: item.badgeCount > 0
              ? '${item.label}, ${item.badgeCount} need attention'
              : item.label,
          excludeSemantics: true,
          child: InkResponse(
            onTap: () => onSelect(i),
            radius: 28,
            highlightShape: BoxShape.circle,
            child: Center(
              child: AnimatedScale(
                scale: active ? 1.06 : 1,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: _BadgedIcon(
                  icon: active ? item.selectedIcon : item.icon,
                  color: active ? AppColors.primary : const Color(0xFF8E8A88),
                  count: item.badgeCount,
                ),
              ),
            ),
          ),
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Soft brand-coloured glow under the button.
            Positioned(
              left: -18,
              right: -18,
              top: -8,
              bottom: -28,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.30),
                      AppColors.primary.withValues(alpha: 0),
                    ],
                    stops: const [0.42, 1],
                  ),
                ),
              ),
            ),
            Material(
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
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
                    child: Icon(
                      Icons.add_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The bar's surface: a white rectangle with a straight top edge and rounded
/// top corners, over a soft upward shadow.
class _BarPainter extends CustomPainter {
  const _BarPainter({required this.corner});
  final double corner;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndCorners(
      Offset.zero & size,
      topLeft: Radius.circular(corner),
      topRight: Radius.circular(corner),
    );
    canvas
      ..drawRRect(
        rect.shift(const Offset(0, -2)),
        Paint()
          ..color = const Color(0x1F5A3A2E)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      )
      ..drawRRect(rect, Paint()..color = AppColors.surface);
  }

  @override
  bool shouldRepaint(_BarPainter old) => old.corner != corner;
}

/// Tab icon with an optional count badge in its top-right corner.
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
    final iconWidget = Icon(icon, size: 27, color: color);
    if (count <= 0) return iconWidget;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        iconWidget,
        Positioned(
          right: -7,
          top: -4,
          child: Container(
            constraints: const BoxConstraints(minWidth: 16),
            height: 16,
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
                fontSize: 9.5,
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
