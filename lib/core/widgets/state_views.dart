import 'package:material_ui/material_ui.dart';

import '../errors/app_exception.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Explicit loading / error / empty states, reused by every screen.

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final message = mapError(error).message;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Gap.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.errorSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: AppColors.error,
              ),
            ),
            Space.v16,
            Text(
              "Couldn't load this",
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            Space.v6,
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              Space.v20,
              OutlinedButton.icon(
                onPressed: onRetry,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(150, 46),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.secondaryAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Gap.xl,
        vertical: Gap.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFFFFE4D6), AppColors.primarySoft],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: AppColors.primary, size: 34),
          ),
          Space.v20,
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          Space.v6,
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          if (action != null) ...[Space.v20, action!],
          if (secondaryAction != null) ...[Space.v4, secondaryAction!],
        ],
      ),
    );
  }
}

/// Shimmering placeholder used for skeleton loading screens.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.height = 16,
    this.width,
    this.radius = 12,
  });
  final double height;
  final double? width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value * 3 - 1;
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.radius),
            gradient: LinearGradient(
              begin: Alignment(t - 1, 0),
              end: Alignment(t + 1, 0),
              colors: const [
                AppColors.skeleton,
                AppColors.skeletonHighlight,
                AppColors.skeleton,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Inline banner for warnings, info and errors inside forms/screens.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    super.key,
    required this.message,
    this.tone = BannerTone.error,
    this.title,
    this.action,
  });

  final String message;
  final String? title;
  final BannerTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final (fg, bg, icon) = switch (tone) {
      BannerTone.error => (
        AppColors.error,
        AppColors.errorSoft,
        Icons.error_outline_rounded,
      ),
      BannerTone.warning => (
        AppColors.warning,
        AppColors.warningSoft,
        Icons.info_outline_rounded,
      ),
      BannerTone.info => (
        AppColors.info,
        AppColors.infoSoft,
        Icons.info_outline_rounded,
      ),
      BannerTone.success => (
        AppColors.success,
        AppColors.successSoft,
        Icons.check_circle_outline_rounded,
      ),
    };
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(Gap.md),
        decoration: BoxDecoration(color: bg, borderRadius: Radii.input),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: fg, size: 19),
            Space.h10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: TextStyle(
                        color: fg,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                    Space.v2,
                  ],
                  Text(
                    message,
                    style: TextStyle(
                      color: fg,
                      fontSize: 13,
                      height: 1.4,
                      fontWeight: title == null
                          ? FontWeight.w500
                          : FontWeight.w400,
                    ),
                  ),
                  if (action != null) ...[Space.v4, action!],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum BannerTone { error, warning, info, success }
