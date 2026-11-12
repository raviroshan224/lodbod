import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/shipment.dart';
import 'shipment_visuals.dart';

class LifecycleStepper extends StatelessWidget {
  const LifecycleStepper({super.key, required this.status});
  final ShipmentStatus status;

  static const _labels = [
    'Posted',
    'Booked',
    'Scheduled',
    'On the way',
    'Delivered',
  ];

  @override
  Widget build(BuildContext context) {
    final current = ShipmentStatus.lifecycle.indexOf(status);
    final stopped = current < 0; // Cancelled or expired.
    return Semantics(
      label: stopped
          ? 'Shipment ${status.label.toLowerCase()}'
          : 'Step ${current + 1} of 5: ${_labels[current]}',
      excludeSemantics: true,
      child: Column(
        children: [
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++) ...[
                _Dot(
                  done: !stopped && i <= current,
                  current: i == current,
                  stopped: stopped,
                ),
                if (i < _labels.length - 1)
                  Expanded(
                    child: Container(
                      height: 2.5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: !stopped && i < current
                            ? AppColors.primary
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: Text(
                    _labels[i],
                    textAlign: i == 0
                        ? TextAlign.left
                        : i == _labels.length - 1
                        ? TextAlign.right
                        : TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: i == current
                          ? FontWeight.w800
                          : FontWeight.w500,
                      color: !stopped && i <= current
                          ? AppColors.textPrimary
                          : AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({
    required this.done,
    required this.current,
    required this.stopped,
  });
  final bool done;
  final bool current;
  final bool stopped;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: current ? 16 : 12,
      height: current ? 16 : 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? AppColors.primary : AppColors.surface,
        border: Border.all(
          color: done ? AppColors.primary : AppColors.border,
          width: 2,
        ),
        boxShadow: current
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                ),
              ]
            : null,
      ),
      child: done && !current
          ? const Icon(Icons.check_rounded, size: 8, color: Colors.white)
          : null,
    );
  }
}

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({super.key, required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final history = [...shipment.timeline]
      ..sort((a, b) => b.at.compareTo(a.at));
    return Column(
      children: [
        for (var i = 0; i < history.length; i++)
          _TimelineRow(
            entry: history[i],
            latest: i == 0,
            isLast: i == history.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.entry,
    required this.latest,
    required this.isLast,
  });
  final TimelineEntry entry;
  final bool latest;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final style = shipmentStatusStyle(entry.status);
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: latest ? style.background : AppColors.surfaceMuted,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: latest
                          ? style.foreground.withValues(alpha: 0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: Icon(
                    style.icon,
                    size: 14,
                    color: latest ? style.foreground : AppColors.textMuted,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: AppColors.divider,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16, top: 3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.status.label,
                    style: TextStyle(
                      fontWeight: latest ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    [
                      Fmt.dateTime(entry.at),
                      if (entry.note.isNotEmpty) entry.note,
                    ].join(' · '),
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textSecondary,
                      height: 1.35,
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
