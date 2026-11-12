import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'visuals.dart';

class Pill extends StatelessWidget {
  const Pill({
    super.key,
    required this.label,
    required this.style,
    this.dense = false,
  });
  final String label;
  final StatusStyle style;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: $label',
      excludeSemantics: true,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dense ? 7 : 9,
          vertical: dense ? 3 : 4,
        ),
        decoration: BoxDecoration(
          color: style.background,
          borderRadius: Radii.chip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(style.icon, size: dense ? 12 : 13, color: style.foreground),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: style.foreground,
                fontSize: dense ? 11 : 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Flat white surface with large rounded corners (Material 3 card on the
/// tinted background). Tappable when [onTap] is given; [borderColor] adds an
/// accent outline (e.g. the accepted bid).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.color = AppColors.surface,
    this.borderColor,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, child: content);
    }
    final card = Material(
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: Radii.card,
        side: borderColor == null
            ? BorderSide.none
            : BorderSide(color: borderColor!, width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
    if (semanticLabel == null) return card;
    return Semantics(button: onTap != null, label: semanticLabel, child: card);
  }
}

/// Card with a title row, used to group related details.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.child,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(Gap.lg),
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                ?trailing,
              ],
            ),
            Space.v8,
          ],
          child,
        ],
      ),
    );
  }
}

/// Section title with an optional action ("See all").
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.action, this.top = Gap.xl});
  final String title;
  final Widget? action;
  final double top;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: top, bottom: Gap.sm),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// "Kathmandu → Pokhara" with the arrow in brand orange.
class RouteText extends StatelessWidget {
  const RouteText(this.pickup, this.destination, {super.key, this.style});
  final String pickup;
  final String destination;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final s =
        style ??
        const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        );
    return Semantics(
      label: '$pickup to $destination',
      excludeSemantics: true,
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: pickup),
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: (s.fontSize ?? 16) + 1,
                  color: AppColors.primary,
                ),
              ),
            ),
            TextSpan(text: destination),
          ],
        ),
        style: s,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

/// Vertical pickup → destination with a connector line, like a boarding pass.
class RouteStack extends StatelessWidget {
  const RouteStack({
    super.key,
    required this.pickup,
    required this.destination,
    this.pickupCaption,
    this.destinationCaption,
  });

  final String pickup;
  final String destination;
  final String? pickupCaption;
  final String? destinationCaption;

  @override
  Widget build(BuildContext context) {
    Widget stop(String place, String? caption, {required bool start}) => Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 20,
          child: Icon(
            start
                ? Icons.radio_button_checked_rounded
                : Icons.location_on_rounded,
            size: start ? 16 : 18,
            color: start ? AppColors.textPrimary : AppColors.primary,
          ),
        ),
        Space.h10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                place,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              if (caption != null) ...[
                Space.v2,
                Text(
                  caption,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        stop(pickup, pickupCaption, start: true),
        Padding(
          padding: const EdgeInsets.only(left: 9),
          child: Column(
            children: List.generate(
              3,
              (_) => Container(
                width: 2,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 1.5),
                color: AppColors.border,
              ),
            ),
          ),
        ),
        stop(destination, destinationCaption, start: false),
      ],
    );
  }
}

/// Small icon + text pair used for metadata lines.
class IconText extends StatelessWidget {
  const IconText(
    this.icon,
    this.text, {
    super.key,
    this.color,
    this.bold = false,
  });
  final IconData icon;
  final String text;
  final Color? color;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textSecondary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: c),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              color: c,
              fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Label/value row for detail screens.
class InfoRow extends StatelessWidget {
  const InfoRow(this.label, this.value, {super.key, this.icon, this.trailing});
  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        // A trailing control (call button) centres on its row; plain rows
        // top-align so a wrapped value hangs under its label.
        crossAxisAlignment: trailing == null
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 17, color: AppColors.textMuted),
            Space.h10,
          ],
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Circle with initials.
class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar(
    this.initials, {
    super.key,
    this.size = 40,
    this.soft = false,
  });
  final String initials;
  final double size;
  final bool soft;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: soft ? AppColors.primarySoft : AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: soft ? AppColors.onPrimarySoft : Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: size * 0.36,
        ),
      ),
    );
  }
}

/// Rounded icon tile, e.g. leading icons in lists.
class IconTile extends StatelessWidget {
  const IconTile(
    this.icon, {
    super.key,
    this.color = AppColors.primary,
    this.background,
    this.size = 40,
  });
  final IconData icon;
  final Color color;
  final Color? background;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(icon, size: size * 0.5, color: color),
    );
  }
}

/// Tonal circular icon button (bell, sort), with an optional count badge.
class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.badge,
    this.size = 42,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final int? badge;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: badge != null && badge! > 0 ? '$tooltip, $badge new' : tooltip,
        excludeSemantics: true,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.surfaceContainer,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPressed,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: Icon(
                    icon,
                    size: size * 0.48,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            if (badge != null && badge! > 0)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 18),
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: Radii.chip,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    badge! > 9 ? '9+' : '$badge',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1,
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

/// LODBOD app mark: orange tile with the "lb" monogram, plus optional
/// wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 48,
    this.showWordmark = false,
    this.elevated = true,
  });
  final double size;
  final bool showWordmark;

  /// Soft orange glow under the tile. Off for small, inline uses such as a
  /// header lockup, where it reads as a smudge.
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: const BrandGlyph(),
    );
    if (!showWordmark) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Space.v16,
        const BrandWordmark(size: 32),
        Space.v4,
        const Text(
          'SHIPPER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// "lodbod" in lowercase italic, "bod" in orange, like the lodbod.com
/// wordmark.
class BrandWordmark extends StatelessWidget {
  const BrandWordmark({super.key, this.size = 32});

  /// Font size of the letters.
  final double size;

  @override
  Widget build(BuildContext context) {
    // Inter ships upright only here, so the slant is a skew rather than a
    // faux-italic face.
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.skewX(-BrandGlyph.slant),
      child: Text.rich(
        const TextSpan(
          children: [
            TextSpan(text: 'lod'),
            TextSpan(
              text: 'bod',
              style: TextStyle(color: AppColors.primary),
            ),
          ],
        ),
        semanticsLabel: 'LODBOD',
        style: TextStyle(
          fontSize: size,
          fontWeight: FontWeight.w800,
          letterSpacing: -size * 0.025,
          height: 1,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

/// The "lb" monogram on its own, filling a square of whatever size it is
/// given. Drawn after the lodbod.com mark: a forward-leaning "l" broken by
/// speed stripes, and a "b" whose shoulder is cut at an angle like a truck
/// cab's windscreen.
class BrandGlyph extends StatelessWidget {
  const BrandGlyph({super.key, this.color = Colors.white});
  final Color color;

  /// Forward lean shared by the monogram and the wordmark (about 9.6°).
  static final slant = math.atan(_BrandGlyphPainter.lean);

  @override
  Widget build(BuildContext context) =>
      SizedBox.expand(child: CustomPaint(painter: _BrandGlyphPainter(color)));
}

class _BrandGlyphPainter extends CustomPainter {
  _BrandGlyphPainter(this.color);
  final Color color;

  /// Horizontal shift per unit of height, pivoting on the vertical centre.
  static const lean = 0.17;

  // Geometry on a 100×100 grid, drawn upright and then leaned. Vertical
  // strokes are heavier than horizontal ones, as in the source mark.
  static const _top = 19.0, _base = 81.0;
  static const _stemL = 30.0, _stemR = 44.0; // "l" stem
  static const _legL = 59.0, _legR = 73.0; // "b" right-hand leg
  static const _shoulder = 36.5; // top of the "b" bowl
  static const _bar = 9.5; // horizontal stroke weight
  static const _gap = 3.0; // slit between the two letters
  static const _cab = 11.0; // windscreen chamfer on the "b"

  /// Speed stripes cut across the stem: (top, bottom) of each solid slice.
  static const _slices = [
    (_top, 30.8),
    (34.6, 38.7),
    (42.5, 46.6),
    (50.4, 54.5),
  ];

  /// Closed outlines as (x, y, corner radius) points, clockwise.
  static final List<List<(double, double, double)>> _outlines = [
    for (final (i, (y0, y1)) in _slices.indexed)
      [
        (_stemL, y0, i == 0 ? 2.0 : 0.6),
        (_stemR, y0, i == 0 ? 2.0 : 0.6),
        (_stemR, y1, 0.6),
        (_stemL, y1, 0.6),
      ],
    // Lower stem and foot of the "l".
    [
      (_stemL, 58.3, 0.6),
      (_stemR, 58.3, 0.6),
      (_stemR, _base - _bar, 1.5),
      (_legL - _gap, _base - _bar, 0.6),
      (_legL - _gap, _base, 0.6),
      (_stemL, _base, 9),
    ],
    // Shoulder and leg of the "b", with the cab-shaped corner.
    [
      (_stemR + _gap, _shoulder, 0.6),
      (_legR - _cab, _shoulder, 3),
      (_legR, _shoulder + _cab, 3),
      (_legR, _base, 6),
      (_legL, _base, 0.6),
      (_legL, _shoulder + _bar + 4, 1),
      (_legL - 4, _shoulder + _bar, 1),
      (_stemR + _gap, _shoulder + _bar, 0.6),
    ],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width, size.height) / 100;
    final origin = Offset(
      (size.width - 100 * scale) / 2,
      (size.height - 100 * scale) / 2,
    );
    // Lean and scale. Affine, so the corner curves stay exact.
    Offset map(Offset p) =>
        origin + Offset(p.dx + lean * (50 - p.dy), p.dy) * scale;

    final path = Path();
    for (final outline in _outlines) {
      _addRounded(path, outline, map);
    }
    canvas.drawPath(path, Paint()..color = color);
  }

  /// Adds a closed polygon whose corners are rounded with circular arcs
  /// (as cubics), each clamped so it never takes more than half an edge.
  static void _addRounded(
    Path path,
    List<(double, double, double)> points,
    Offset Function(Offset) map,
  ) {
    final n = points.length;
    final corners = <(Offset, Offset, Offset, Offset)>[];
    for (var i = 0; i < n; i++) {
      final (x, y, r) = points[i];
      final (px, py, _) = points[(i - 1 + n) % n];
      final (nx, ny, _) = points[(i + 1) % n];
      final v = Offset(x, y);
      final inEdge = v - Offset(px, py);
      final outEdge = Offset(nx, ny) - v;
      final dIn = inEdge / inEdge.distance;
      final dOut = outEdge / outEdge.distance;
      final turn = math.acos(
        (dIn.dx * dOut.dx + dIn.dy * dOut.dy).clamp(-1.0, 1.0),
      );
      final reach = math.min(
        r * math.tan(turn / 2),
        math.min(inEdge.distance, outEdge.distance) / 2,
      );
      final radius = turn == 0 ? 0.0 : reach / math.tan(turn / 2);
      final handle = 4 / 3 * math.tan(turn / 4) * radius;
      final a = v - dIn * reach, e = v + dOut * reach;
      corners.add((a, a + dIn * handle, e - dOut * handle, e));
    }
    final start = map(corners.last.$4);
    path.moveTo(start.dx, start.dy);
    for (final (a, c1, c2, e) in corners) {
      final pa = map(a), p1 = map(c1), p2 = map(c2), pe = map(e);
      path
        ..lineTo(pa.dx, pa.dy)
        ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, pe.dx, pe.dy);
    }
    path.close();
  }

  @override
  bool shouldRepaint(_BrandGlyphPainter old) => old.color != color;
}
