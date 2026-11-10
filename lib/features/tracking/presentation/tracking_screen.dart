import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/platform/launch.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/state_views.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/status_badge.dart';
import '../data/providers.dart';
import '../domain/simulated_driver.dart';
import '../domain/tracking.dart';
import 'live_tracking.dart';

/// Route view for a booked shipment. While it's open, a simulated driver
/// reports the truck's position to Firestore and the view follows those
/// reports live (as does any other device watching). Without reports it
/// falls back to an estimate from the schedule. Both are labelled simulated.
class TrackingScreen extends ConsumerWidget {
  const TrackingScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipment = ref.watch(shipmentByIdProvider(shipmentId));
    return Scaffold(
      body: switch (shipment) {
        AsyncData(value: final s?) => _Tracking(shipment: s),
        AsyncData() => const Center(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Shipment not found',
            message: 'It may have been removed.',
          ),
        ),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(shipmentsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Tracking extends ConsumerWidget {
  const _Tracking({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    if (s.status == ShipmentStatus.inTransit) {
      ref.watch(simulatedDriverProvider(s.id));
    }
    final feed = ref.watch(livePositionProvider(s.id));
    final t = trackingFor(s, now: DateTime.now(), live: feed.value);
    final mapHeight = MediaQuery.sizeOf(context).height * 0.46;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: mapHeight + 24,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: t.progress),
            // Live: glide to each report over the gap between reports.
            duration: _moveDuration(t),
            curve: _moveCurve(t),
            builder: (_, p, _) =>
                _RouteMap(shipment: s, tracking: t, animatedProgress: p),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(Gap.page, Gap.sm, Gap.page, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleIconButton(
                      icon: Icons.arrow_back_rounded,
                      tooltip: 'Back',
                      size: 42,
                      onPressed: () => context.pop(),
                    ),
                    Space.h8,
                    Expanded(
                      child: Container(
                        height: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: Radii.chip,
                          border: Border.all(color: AppColors.border),
                          boxShadow: AppColors.shadow,
                        ),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: s.reference,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: '   ${s.routeLabel}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13.5),
                        ),
                      ),
                    ),
                  ],
                ),
                Space.v8,
                _TrackingBadge(
                  live: t.live,
                  // Offline, or the project's rules don't allow tracking.
                  unavailable:
                      s.status == ShipmentStatus.inTransit && feed.hasError,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: mapHeight,
          left: 0,
          right: 0,
          bottom: 0,
          child: _Panel(shipment: s, tracking: t),
        ),
      ],
    );
  }
}

Duration _moveDuration(TrackingInfo t) => t.live == null
    ? const Duration(milliseconds: 1400)
    : SimulatedDriver.reportInterval;

Curve _moveCurve(TrackingInfo t) =>
    t.live == null ? Curves.easeOutCubic : Curves.linear;

/// "Live" while position reports arrive, with their age; otherwise says the
/// position is estimated, and why when live updates can't be read. Both say
/// the source is simulated.
class _TrackingBadge extends StatefulWidget {
  const _TrackingBadge({required this.live, this.unavailable = false});
  final LivePosition? live;
  final bool unavailable;

  @override
  State<_TrackingBadge> createState() => _TrackingBadgeState();
}

class _TrackingBadgeState extends State<_TrackingBadge> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _syncTicker();
  }

  @override
  void didUpdateWidget(_TrackingBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  /// Ticks once a second while live, so "updated 3s ago" stays current.
  void _syncTicker() {
    if (widget.live == null) {
      _ticker?.cancel();
      _ticker = null;
    } else {
      _ticker ??= Timer.periodic(
        const Duration(seconds: 1),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final live = widget.live;
    final String text;
    final Color color;
    final Color background;
    final Widget leading;
    if (live == null) {
      text = widget.unavailable
          ? 'Estimated from schedule · live updates unavailable'
          : 'Simulated tracking · sample route';
      color = AppColors.warning;
      background = AppColors.warningSoft;
      leading = const Icon(
        Icons.science_outlined,
        size: 14,
        color: AppColors.warning,
      );
    } else {
      final seconds = DateTime.now().difference(live.reportedAt).inSeconds;
      final age = seconds < 2 ? 'just now' : '${seconds}s ago';
      text = [
        'Live · simulated driver · $age',
        if (live.speedFactor > 1) '×${live.speedFactor}',
      ].join(' · ');
      color = AppColors.success;
      background = AppColors.successSoft;
      leading = Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: Radii.chip),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.shipment, required this.tracking});
  final Shipment shipment;
  final TrackingInfo tracking;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    final t = tracking;
    final eta = t.eta;
    final live = t.live;
    final speed = live == null
        ? ''
        : live.speedKmh < 1
        ? ' · Stopped'
        : ' · ${live.speedKmh.round()} km/h';
    final (headline, sub) = switch (s.status) {
      ShipmentStatus.inTransit when t.arrived => (
        'Arrived',
        'At ${s.destination} · waiting for the carrier to confirm delivery',
      ),
      ShipmentStatus.inTransit when t.isLate => (
        'Running late',
        'Expected ${Fmt.weekdayDayMonth(eta!)}, ${Fmt.time(eta)} · ${t.remainingKm} km remaining',
      ),
      ShipmentStatus.inTransit => (
        eta == null ? 'On the way' : 'ETA ${Fmt.time(eta)}',
        '${eta == null ? '' : '${Fmt.weekdayDayMonth(eta)} · '}${t.remainingKm} km remaining$speed',
      ),
      ShipmentStatus.delivered => (
        'Delivered',
        Fmt.dateTime(s.reachedAt(ShipmentStatus.delivered) ?? s.updatedAt),
      ),
      _ => (
        'Awaiting pickup',
        'Pickup ${Fmt.weekdayDayMonth(s.pickupAt)}, ${Fmt.time(s.pickupAt)} · ${t.distanceKm} km trip',
      ),
    };
    final carrier = s.carrierName ?? 'Carrier';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: Radii.sheet,
        boxShadow: [
          BoxShadow(
            color: Color(0x14101828),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(Gap.xl, Gap.md, Gap.xl, Gap.xl),
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: Radii.chip,
              ),
            ),
          ),
          Space.v16,
          Row(
            children: [
              Expanded(
                child: Text(
                  headline,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              StatusBadge(s.status),
            ],
          ),
          Space.v2,
          Text(
            sub,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13.5,
            ),
          ),
          Space.v16,
          ClipRRect(
            borderRadius: Radii.chip,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: t.progress),
              duration: _moveDuration(t),
              curve: _moveCurve(t),
              builder: (_, v, _) =>
                  LinearProgressIndicator(value: v, minHeight: 6),
            ),
          ),
          Space.v6,
          Row(
            children: [
              Text(
                s.pickup,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Expanded(
                child: Text(
                  s.status == ShipmentStatus.inTransit && t.lastPassed != null
                      ? '${t.lastPassed!.name} · ${(t.progress * 100).round()}%'
                      : '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                s.destination,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          if (s.status == ShipmentStatus.inTransit && !t.arrived) ...[
            Space.v8,
            _FastForward(shipment: s, on: (live?.speedFactor ?? 1) > 1),
          ],
          Space.v20,
          AppCard(
            padding: const EdgeInsets.all(Gap.md),
            child: Row(
              children: [
                InitialsAvatar(Fmt.initials(carrier), size: 42, soft: true),
                Space.h12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        carrier,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        [
                          if ((s.vehicleNumber ?? '').isNotEmpty)
                            s.vehicleNumber!,
                          s.vehicleType.label,
                        ].join(' · '),
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if ((s.carrierPhone ?? '').isNotEmpty)
                  IconButton.filledTonal(
                    tooltip: 'Call $carrier',
                    onPressed: () => callNumber(context, s.carrierPhone!),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primarySoft,
                      foregroundColor: AppColors.primary,
                    ),
                    icon: const Icon(Icons.call_rounded, size: 20),
                  ),
              ],
            ),
          ),
          Space.v20,
          const Text(
            'Route',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          Space.v12,
          _Stop(
            name: s.pickup,
            caption:
                'Pickup · ${Fmt.dateTime(s.reachedAt(ShipmentStatus.inTransit) ?? s.pickupAt)}',
            reached: t.progress > 0,
            first: true,
          ),
          for (final c in t.checkpoints)
            _Stop(
              name: c.name,
              caption: c.fraction <= t.progress ? 'Passed' : 'Upcoming',
              reached: c.fraction <= t.progress,
            ),
          _Stop(
            name: s.destination,
            caption: s.status == ShipmentStatus.delivered
                ? 'Delivered'
                : t.arrived
                ? 'Arrived'
                : eta == null
                ? 'Drop-off'
                : 'Estimated ${Fmt.dateTime(eta)}',
            reached: t.progress >= 1,
            last: true,
          ),
        ],
      ),
    );
  }
}

/// Demo control for the simulated driver: speeds the truck up so a trip can
/// be watched in a couple of minutes. Every device watching sees it.
class _FastForward extends ConsumerWidget {
  const _FastForward({required this.shipment, required this.on});
  final Shipment shipment;
  final bool on;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<void> toggle(bool value) async {
      try {
        await ref
            .read(trackingRepositoryProvider)
            .reportSimulatedPosition(
              shipment,
              speedFactor: value ? SimulatedDriver.fastForward : 1,
            );
      } catch (e) {
        if (context.mounted) {
          showMessage(context, mapError(e).message, isError: true);
        }
      }
    }

    return Row(
      children: [
        const Icon(
          Icons.fast_forward_rounded,
          size: 18,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        const Expanded(
          child: Text(
            'Simulate: fast-forward ×${SimulatedDriver.fastForward}',
            style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
          ),
        ),
        Switch.adaptive(value: on, onChanged: toggle),
      ],
    );
  }
}

class _Stop extends StatelessWidget {
  const _Stop({
    required this.name,
    required this.caption,
    required this.reached,
    this.first = false,
    this.last = false,
  });
  final String name;
  final String caption;
  final bool reached;
  final bool first;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final color = reached ? AppColors.primary : AppColors.border;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 20,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: reached ? AppColors.primary : AppColors.surface,
                    border: Border.all(color: color, width: 2.5),
                  ),
                ),
                if (!last) Expanded(child: Container(width: 2, color: color)),
              ],
            ),
          ),
          Space.h12,
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: first || last
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                  Text(
                    caption,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stylised map: soft background, decorative roads, the route as a curve,
/// checkpoints and the truck at the current (simulated) position.
class _RouteMap extends StatelessWidget {
  const _RouteMap({
    required this.shipment,
    required this.tracking,
    required this.animatedProgress,
  });
  final Shipment shipment;
  final TrackingInfo tracking;
  final double animatedProgress;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final route = _routePath(size);
        final metric = route.computeMetrics().first;
        final truck = metric
            .getTangentForOffset(metric.length * animatedProgress)!
            .position;
        return Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MapPainter(
                  route: route,
                  progress: animatedProgress,
                  checkpoints: tracking.checkpoints,
                ),
              ),
            ),
            for (final cp in tracking.checkpoints)
              _label(
                metric
                    .getTangentForOffset(metric.length * cp.fraction)!
                    .position,
                cp.name,
                small: true,
              ),
            _label(metric.getTangentForOffset(0)!.position, shipment.pickup),
            _label(
              metric.getTangentForOffset(metric.length)!.position,
              shipment.destination,
              leftOf: true,
              width: size.width,
            ),
            Positioned(
              left: truck.dx - 19,
              top: truck.dy - 19,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.45),
                      blurRadius: 14,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _label(
    Offset at,
    String text, {
    bool small = false,
    bool leftOf = false,
    double width = 0,
  }) {
    return Positioned(
      left: leftOf ? null : at.dx + 12,
      right: leftOf ? width - at.dx + 12 : null,
      top: at.dy - (small ? 22 : 28),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 6 : 8,
          vertical: small ? 2 : 4,
        ),
        decoration: BoxDecoration(
          color: small ? Colors.white.withValues(alpha: 0.85) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: small ? null : AppColors.shadow,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: small ? 10.5 : 12,
            fontWeight: small ? FontWeight.w600 : FontWeight.w800,
            color: small ? AppColors.textSecondary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Route kept clear of the floating header at the top of the map.
  static Path _routePath(Size s) => Path()
    ..moveTo(s.width * 0.14, s.height * 0.86)
    ..cubicTo(
      s.width * 0.40,
      s.height * 0.74,
      s.width * 0.30,
      s.height * 0.55,
      s.width * 0.55,
      s.height * 0.60,
    )
    ..cubicTo(
      s.width * 0.78,
      s.height * 0.65,
      s.width * 0.72,
      s.height * 0.44,
      s.width * 0.84,
      s.height * 0.40,
    );
}

class _MapPainter extends CustomPainter {
  _MapPainter({
    required this.route,
    required this.progress,
    required this.checkpoints,
  });
  final Path route;
  final double progress;
  final List<Checkpoint> checkpoints;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFECEEF1),
    );

    // Terrain blocks and decorative roads, for a map-like texture.
    final block = Paint()..color = const Color(0xFFE3E7EA);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.05,
          size.height * 0.08,
          size.width * 0.3,
          size.height * 0.22,
        ),
        const Radius.circular(18),
      ),
      block,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          size.width * 0.62,
          size.height * 0.58,
          size.width * 0.32,
          size.height * 0.28,
        ),
        const Radius.circular(18),
      ),
      block,
    );
    final water = Paint()
      ..color = const Color(0xFFD5E6F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(
          size.width * 0.3,
          size.height * 0.45,
          size.width * 0.42,
          size.height * 0.95,
        ),
      water,
    );
    final road = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.5, 0),
      Offset(size.width * 0.38, size.height),
      road,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.28),
      Offset(size.width, size.height * 0.62),
      road..strokeWidth = 5,
    );

    // Full route, then the travelled part on top.
    final remaining = Paint()
      ..color = const Color(0xFFB9BEC6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    final metric = route.computeMetrics().first;
    _dashed(canvas, metric, remaining);
    final travelled = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(metric.extractPath(0, metric.length * progress), travelled);

    for (final cp in checkpoints) {
      final p = metric
          .getTangentForOffset(metric.length * cp.fraction)!
          .position;
      canvas.drawCircle(p, 6, Paint()..color = Colors.white);
      canvas.drawCircle(
        p,
        6,
        Paint()
          ..color = cp.fraction <= progress
              ? AppColors.primary
              : const Color(0xFFB9BEC6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    final start = metric.getTangentForOffset(0)!.position;
    canvas.drawCircle(start, 9, Paint()..color = AppColors.textPrimary);
    canvas.drawCircle(start, 4, Paint()..color = Colors.white);
    final end = metric.getTangentForOffset(metric.length)!.position;
    canvas.drawCircle(
      end,
      11,
      Paint()..color = AppColors.primary.withValues(alpha: 0.25),
    );
    canvas.drawCircle(end, 7, Paint()..color = AppColors.primary);
    canvas.drawCircle(end, 3, Paint()..color = Colors.white);
  }

  void _dashed(Canvas canvas, ui.PathMetric metric, Paint paint) {
    const dash = 10.0, gap = 8.0;
    var d = 0.0;
    while (d < metric.length) {
      canvas.drawPath(
        metric.extractPath(d, (d + dash).clamp(0, metric.length)),
        paint,
      );
      d += dash + gap;
    }
  }

  @override
  bool shouldRepaint(_MapPainter old) =>
      old.progress != progress || old.route != route;
}
