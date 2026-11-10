import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/platform/launch.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../create_shipment/presentation/create_shipment_controller.dart';
import '../../create_shipment/presentation/open_post_load.dart';
import '../../tracking/domain/tracking.dart';
import '../../tracking/presentation/live_tracking.dart';
import '../domain/shipment.dart';
import 'shipments_providers.dart';
import 'widgets/shipment_visuals.dart';
import 'widgets/status_badge.dart';
import 'widgets/status_timeline.dart';

class ShipmentDetailsScreen extends ConsumerWidget {
  const ShipmentDetailsScreen({super.key, required this.shipmentId});
  final String shipmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shipment = ref.watch(shipmentByIdProvider(shipmentId));
    final s = shipment.value;

    return Scaffold(
      appBar: DetailAppBar(
        title: s?.reference ?? 'Shipment',
        subtitle: s == null ? null : 'Posted ${Fmt.date(s.createdAt)}',
        actions: [if (s != null) _MoreMenu(shipment: s)],
      ),
      body: switch (shipment) {
        AsyncData(value: final s?) => _Body(shipment: s),
        AsyncData() => const Center(
          child: EmptyView(
            icon: Icons.search_off_rounded,
            title: 'Shipment not found',
            message: 'It may have been removed. Go back to your shipments.',
          ),
        ),
        AsyncError(:final error) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(shipmentsProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      bottomNavigationBar: s == null ? null : _ActionBar(shipment: s),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context) {
    final s = shipment;
    return ListView(
      padding: const EdgeInsets.fromLTRB(Gap.page, Gap.xs, Gap.page, Gap.xl),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  StatusBadge(s.status),
                  const Spacer(),
                  Text(
                    Fmt.relative(s.updatedAt),
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Space.v16,
              RouteStack(
                pickup: s.pickup,
                destination: s.destination,
                pickupCaption:
                    'Pickup · ${Fmt.weekdayDayMonth(s.pickupAt)}, ${Fmt.time(s.pickupAt)}',
                destinationCaption: s.etaAt == null
                    ? 'Drop-off'
                    : s.status == ShipmentStatus.delivered
                    ? 'Delivered · ${Fmt.weekdayDayMonth(s.reachedAt(ShipmentStatus.delivered) ?? s.etaAt!)}'
                    : 'Estimated arrival · ${Fmt.weekdayDayMonth(s.etaAt!)}',
              ),
              Space.v20,
              LifecycleStepper(status: s.status),
            ],
          ),
        ),
        Space.v12,
        _ContextCard(shipment: s),
        Space.v12,
        SectionCard(
          title: 'Shipment details',
          child: Column(
            children: [
              InfoRow(
                'Cargo',
                s.cargoDescription.toLowerCase() ==
                        s.cargoCategory.label.toLowerCase()
                    ? s.cargoDescription
                    : '${s.cargoDescription} · ${s.cargoCategory.label}',
                icon: cargoIcon(s.cargoCategory),
              ),
              InfoRow('Weight', s.weightLabel, icon: Icons.scale_outlined),
              InfoRow(
                'Vehicle',
                s.vehicleType.label,
                icon: vehicleIcon(s.vehicleType),
              ),
              InfoRow(
                'Your budget',
                s.expectedFare == null
                    ? 'Open to bids'
                    : Fmt.npr(s.expectedFare!),
                icon: Icons.account_balance_wallet_outlined,
              ),
            ],
          ),
        ),
        if (s.contactName.isNotEmpty ||
            s.contactPhone.isNotEmpty ||
            s.notes.isNotEmpty) ...[
          Space.v12,
          SectionCard(
            title: 'Pickup contact & notes',
            child: Column(
              children: [
                if (s.contactName.isNotEmpty)
                  InfoRow(
                    'Contact',
                    s.contactName,
                    icon: Icons.person_outline_rounded,
                  ),
                if (s.contactPhone.isNotEmpty)
                  InfoRow(
                    'Phone',
                    '+977 ${s.contactPhone}',
                    icon: Icons.phone_outlined,
                    trailing: _SmallIconButton(
                      icon: Icons.call_rounded,
                      tooltip:
                          'Call ${s.contactName.isEmpty ? 'contact' : s.contactName}',
                      onPressed: () => callNumber(context, s.contactPhone),
                    ),
                  ),
                if (s.notes.isNotEmpty)
                  InfoRow('Notes', s.notes, icon: Icons.sticky_note_2_outlined),
              ],
            ),
          ),
        ],
        Space.v12,
        SectionCard(
          title: 'Activity',
          child: StatusTimeline(shipment: s),
        ),
      ],
    );
  }
}

/// The card that answers "what's happening now?" for each status.
class _ContextCard extends ConsumerWidget {
  const _ContextCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    switch (s.status) {
      case ShipmentStatus.awaitingBids:
        final hasBids = s.bidCount > 0;
        return AppCard(
          onTap: hasBids ? () => context.push(Routes.bids(s.id)) : null,
          color: hasBids ? AppColors.infoSoft : AppColors.surface,
          child: Row(
            children: [
              hasBids
                  ? const IconTile(
                      Icons.gavel_rounded,
                      color: AppColors.info,
                      background: Colors.white,
                      size: 44,
                    )
                  : const SizedBox(
                      width: 44,
                      height: 44,
                      child: Padding(
                        padding: EdgeInsets.all(11),
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      ),
                    ),
              Space.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasBids
                          ? '${s.bidCount} ${s.bidCount == 1 ? 'carrier has' : 'carriers have'} bid'
                          : 'Finding carriers…',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Space.v2,
                    Text(
                      hasBids
                          ? 'Compare price, rating and delivery time, then book one.'
                          : 'Your load is visible to carriers. Bids usually arrive within minutes.',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasBids)
                const Icon(Icons.chevron_right_rounded, color: AppColors.info),
            ],
          ),
        );
      case ShipmentStatus.cancelled:
      case ShipmentStatus.expired:
        return InlineBanner(
          tone: BannerTone.info,
          title: s.status == ShipmentStatus.cancelled
              ? 'This request was cancelled'
              : 'This request expired',
          message: 'It no longer counts toward your mobile request limit. You can post it again in a tap.',
        );
      default:
        return _CarrierCard(shipment: s);
    }
  }
}

class _CarrierCard extends ConsumerWidget {
  const _CarrierCard({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    final t = trackingFor(
      s,
      now: DateTime.now(),
      live: ref.watch(livePositionProvider(s.id)).value,
    );
    final carrier = s.carrierName ?? 'Carrier';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              InitialsAvatar(Fmt.initials(carrier), size: 44, soft: true),
              Space.h12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      carrier,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Space.v2,
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
                _SmallIconButton(
                  icon: Icons.call_rounded,
                  tooltip: 'Call $carrier',
                  onPressed: () => callNumber(context, s.carrierPhone!),
                ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 14),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: _Metric(
                  label: 'Agreed fare',
                  value: s.agreedFare == null ? '—' : Fmt.npr(s.agreedFare!),
                ),
              ),
              Expanded(
                child: _Metric(
                  label: s.status == ShipmentStatus.delivered
                      ? 'Delivered'
                      : 'Estimated arrival',
                  value: s.status == ShipmentStatus.delivered
                      ? Fmt.dayMonth(
                          s.reachedAt(ShipmentStatus.delivered) ?? s.updatedAt,
                        )
                      : s.etaAt == null
                      ? '—'
                      : '${Fmt.dayMonth(s.etaAt!)}, ${Fmt.time(s.etaAt!)}',
                ),
              ),
            ],
          ),
          if (s.status == ShipmentStatus.inTransit) ...[
            Space.v16,
            ClipRRect(
              borderRadius: Radii.chip,
              child: LinearProgressIndicator(value: t.progress, minHeight: 6),
            ),
            Space.v8,
            Text(
              '${t.lastPassed == null ? 'Left ${s.pickup}' : 'Passed ${t.lastPassed!.name}'} · ${t.remainingKm} km to go · simulated',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        Space.v2,
        Text(
          value,
          style: const TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

class _SmallIconButton extends StatelessWidget {
  const _SmallIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primarySoft,
        foregroundColor: AppColors.primary,
        minimumSize: const Size(40, 40),
      ),
      icon: Icon(icon, size: 19),
    );
  }
}

/// Status-dependent primary action, pinned to the bottom.
class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    final busy = ref.watch(shipmentActionsProvider(s.id)) != null;

    Future<void> postSimilar() async {
      // Before asking to replace an unfinished load: nothing can be posted.
      if (explainLimitIfReached(context, ref)) return;
      final controller = ref.read(createShipmentProvider.notifier);
      if (controller.hasUserInput) {
        final replace = await confirmAction(
          context,
          title: 'Replace your unfinished load?',
          message:
              'You have a load you were still filling in. Starting from ${s.reference} will replace it.',
          confirmLabel: 'Replace it',
          cancelLabel: 'Keep it',
          icon: Icons.edit_note_rounded,
        );
        if (!replace || !context.mounted) return;
      }
      controller.prefillFrom(s);
      context.push(Routes.postLoad);
    }

    final Widget child = switch (s.status) {
      ShipmentStatus.awaitingBids when s.bidCount > 0 => PrimaryButton(
        label: 'Compare ${s.bidCount} ${s.bidCount == 1 ? 'bid' : 'bids'}',
        icon: Icons.gavel_rounded,
        onPressed: busy ? null : () => context.push(Routes.bids(s.id)),
      ),
      ShipmentStatus.awaitingBids => OutlinedButton(
        onPressed: busy ? null : () => _cancel(context, ref, s),
        style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
        child: const Text('Cancel request'),
      ),
      ShipmentStatus.confirmed ||
      ShipmentStatus.scheduled ||
      ShipmentStatus.inTransit => Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.push(Routes.bids(s.id)),
              child: const Text('View bids'),
            ),
          ),
          Space.h12,
          Expanded(
            flex: 2,
            child: PrimaryButton(
              label: 'Track shipment',
              icon: Icons.near_me_outlined,
              onPressed: () => context.push(Routes.track(s.id)),
            ),
          ),
        ],
      ),
      _ => PrimaryButton(
        label: 'Post a similar load',
        icon: Icons.replay_rounded,
        onPressed: postSimilar,
      ),
    };
    return BottomActionBar(child: child);
  }
}

Future<void> _cancel(BuildContext context, WidgetRef ref, Shipment s) async {
  final confirmed = await confirmAction(
    context,
    title: 'Cancel ${s.reference}?',
    message: s.status == ShipmentStatus.awaitingBids
        ? 'Carriers will no longer be able to bid, and any open bids will be declined.'
        : 'Your booking with ${s.carrierName ?? 'the carrier'} will be cancelled. This frees up one of your mobile requests.',
    confirmLabel: 'Cancel shipment',
    cancelLabel: 'Keep it',
    destructive: true,
    icon: Icons.cancel_outlined,
  );
  if (!confirmed || !context.mounted) return;
  final error = await ref.read(shipmentActionsProvider(s.id).notifier).cancel();
  if (!context.mounted) return;
  showMessage(
    context,
    error?.message ?? '${s.reference} cancelled.',
    isError: error != null,
  );
}

enum _MenuAction { copy, cancel, carrierUpdate, bidsNow }

/// Secondary actions. Carrier events can be simulated from here because
/// this build has no carrier app; they're clearly labelled.
class _MoreMenu extends ConsumerWidget {
  const _MoreMenu({required this.shipment});
  final Shipment shipment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = shipment;
    final next = s.status.nextCarrierStatus;
    final actions = ref.read(shipmentActionsProvider(s.id).notifier);

    Future<void> onSelected(_MenuAction a) async {
      switch (a) {
        case _MenuAction.copy:
          await Clipboard.setData(ClipboardData(text: s.reference));
          if (context.mounted) showMessage(context, '${s.reference} copied');
        case _MenuAction.cancel:
          await _cancel(context, ref, s);
        case _MenuAction.carrierUpdate:
          final ok = await confirmAction(
            context,
            title: 'Simulate carrier update',
            message:
                'Mark ${s.reference} as "${next!.label}". In the live service this update comes from the carrier.',
            confirmLabel: 'Mark ${next.label.toLowerCase()}',
            icon: Icons.science_outlined,
          );
          if (!ok || !context.mounted) return;
          final error = await actions.applyCarrierUpdate(s.status);
          if (context.mounted) {
            showMessage(
              context,
              error?.message ??
                  '${s.reference} is now ${next.label.toLowerCase()}.',
              isError: error != null,
            );
          }
        case _MenuAction.bidsNow:
          final error = await actions.simulateBids();
          if (context.mounted && error != null) {
            showMessage(context, error.message, isError: true);
          }
      }
    }

    return PopupMenuButton<_MenuAction>(
      tooltip: 'More actions',
      icon: const Icon(Icons.more_vert_rounded),
      position: PopupMenuPosition.under,
      onSelected: onSelected,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _MenuAction.copy,
          child: ListTile(
            leading: Icon(Icons.copy_rounded),
            title: Text('Copy reference'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        if (s.status.canCancel)
          const PopupMenuItem(
            value: _MenuAction.cancel,
            child: ListTile(
              leading: Icon(Icons.cancel_outlined, color: AppColors.error),
              title: Text(
                'Cancel shipment',
                style: TextStyle(color: AppColors.error),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        if (next != null ||
            (s.status == ShipmentStatus.awaitingBids && s.bidCount == 0)) ...[
          const PopupMenuDivider(),
          if (next != null)
            PopupMenuItem(
              value: _MenuAction.carrierUpdate,
              child: ListTile(
                leading: Icon(shipmentStatusStyle(next).icon),
                title: Text('Simulate: mark ${next.label.toLowerCase()}'),
                subtitle: const Text('Demo carrier update'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          if (s.status == ShipmentStatus.awaitingBids && s.bidCount == 0)
            const PopupMenuItem(
              value: _MenuAction.bidsNow,
              child: ListTile(
                leading: Icon(Icons.gavel_rounded),
                title: Text('Simulate: bids arrive now'),
                subtitle: Text('Demo carrier bids'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
        ],
      ],
    );
  }
}
