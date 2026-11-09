import 'package:material_ui/material_ui.dart';

import '../../data/models/bid.dart';
import '../../data/models/shipment.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'visuals.dart';

/// Compact pill showing a shipment status with icon + text (never colour
/// alone).
class StatusBadge extends StatelessWidget {
  const StatusBadge(this.status, {super.key, this.dense = false});
  final ShipmentStatus status;
  final bool dense;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, style: StatusStyle.of(status), dense: dense);
}

class BidStatusBadge extends StatelessWidget {
  const BidStatusBadge(this.status, {super.key});
  final BidStatus status;

  @override
  Widget build(BuildContext context) =>
      Pill(label: status.label, style: StatusStyle.ofBid(status));
}

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

/// White rounded surface with a hairline border and soft shadow. Tappable
/// when [onTap] is given.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(Gap.lg),
    this.color = AppColors.surface,
    this.borderColor = AppColors.border,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Color borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(onTap: onTap, child: content);
    }
    final card = Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: Radii.card,
        border: Border.all(color: borderColor),
        boxShadow: AppColors.shadow,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: Radii.card,
        clipBehavior: Clip.antiAlias,
        child: content,
      ),
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
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.1,
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
        crossAxisAlignment: CrossAxisAlignment.start,
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

/// White circular icon button with a hairline border (back, bell, filter).
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
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.border),
              ),
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

/// LODBOD app mark: orange tile with a truck, plus optional wordmark.
class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 48, this.showWordmark = false});
  final double size;
  final bool showWordmark;

  @override
  Widget build(BuildContext context) {
    final tile = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size: size * 0.52,
      ),
    );
    if (!showWordmark) return tile;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        tile,
        Space.v16,
        const Text.rich(
          TextSpan(
            children: [
              TextSpan(text: 'LOD'),
              TextSpan(
                text: 'BOD',
                style: TextStyle(color: AppColors.primary),
              ),
            ],
          ),
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: 3,
          ),
        ),
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
