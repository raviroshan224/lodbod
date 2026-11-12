import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/l10n/strings.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../shipments/domain/request_limit.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/request_limit_sheet.dart';
import '../domain/shipment_draft.dart';
import 'create_shipment_controller.dart';
import 'widgets/step_header.dart';

/// Summary of the draft with edit links. Nothing is written before Post.
class ReviewShipmentScreen extends ConsumerWidget {
  const ReviewShipmentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(createShipmentProvider);
    final controller = ref.read(createShipmentProvider.notifier);
    final usage =
        ref.watch(requestLimitUsageProvider).value ??
        const RequestLimitUsage(used: 0);
    final d = state.draft;
    final at = d.pickupAt;

    void edit(DraftStep step) {
      controller.goTo(step);
      context.pop();
    }

    Future<void> saveDraft() async {
      try {
        await controller.saveDraft();
        if (context.mounted) {
          showMessage(context, l10n.postDraftSaved);
        }
      } catch (e) {
        if (context.mounted) {
          showMessage(context, mapError(e).message, isError: true);
        }
      }
    }

    Future<void> submit() async {
      final result = await controller.submit();
      if (!context.mounted) return;
      switch (result) {
        case SubmitSucceeded(:final shipment):
          HapticFeedback.mediumImpact();
          context.go(Routes.posted(shipment.id));
        case SubmitInvalid():
          context.pop();
          showMessage(context, l10n.reviewNeedsAttention, isError: true);
        case SubmitFailed(error: RequestLimitReachedException()):
          HapticFeedback.heavyImpact();
          await showRequestLimitSheet(
            context,
            ref.read(requestLimitUsageProvider).value ?? usage,
            blocked: true,
          );
        case SubmitFailed():
        case SubmitIgnored():
          break; // The error banner comes from state.
      }
    }

    // A limit failure stops applying once a request is delivered or cancelled.
    final error =
        state.submitError is RequestLimitReachedException && !usage.isAtLimit
        ? null
        : state.submitError;

    return PopScope(
      canPop: !state.submitting,
      child: Scaffold(
        appBar: DetailAppBar(
          title: l10n.actionPostALoad,
          subtitle: l10n.reviewSubtitle,
          onBack: state.submitting ? () {} : null,
        ),
        body: Column(
          children: [
            StepHeader(
              current: DraftStep.values.length,
              titles: [
                for (final s in DraftStep.values) s.shortTitle,
                l10n.stepReview,
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  Gap.page,
                  Gap.xs,
                  Gap.page,
                  Gap.xl,
                ),
                children: [
                  if (error != null) ...[
                    InlineBanner(
                      title: error is RequestLimitReachedException
                          ? l10n.reviewLimitReached
                          : l10n.reviewCouldNotPost,
                      message: error is RequestLimitReachedException
                          ? l10n.reviewDetailsSaved(RequestLimit.message)
                          : l10n.reviewDetailsSaved(error.message),
                    ),
                    Space.v12,
                  ] else if (usage.isAtLimit) ...[
                    InlineBanner(
                      tone: BannerTone.warning,
                      title: l10n.postAllInUse,
                      message: l10n.postAllInUseReviewBody,
                      action: GestureDetector(
                        onTap: () => showRequestLimitSheet(context, usage),
                        child: Text(
                          l10n.actionHowItWorks,
                          style: TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    Space.v12,
                  ],
                  SectionCard(
                    title: l10n.stepRouteTitle,
                    trailing: _EditButton(
                      onPressed: state.submitting
                          ? null
                          : () => edit(DraftStep.route),
                    ),
                    child: RouteStack(
                      pickup: d.pickup.trim(),
                      destination: d.destination.trim(),
                      pickupCaption: at == null
                          ? null
                          : l10n.detailsPickupLine(
                              '${Fmt.weekdayDayMonth(at)}, ${Fmt.time(at)}',
                            ),
                      destinationCaption: l10n.detailsDropOff,
                    ),
                  ),
                  Space.v12,
                  _ReviewSection(
                    title: l10n.stepCargo,
                    onEdit: state.submitting
                        ? null
                        : () => edit(DraftStep.cargo),
                    rows: [
                      (l10n.postMaterial, d.category?.label ?? '—'),
                      (l10n.reviewDescription, d.description.trim()),
                      (
                        l10n.detailsWeight,
                        d.weight == null
                            ? '—'
                            : '${Fmt.number(d.weight!)} ${d.weightUnit.symbol}',
                      ),
                    ],
                  ),
                  Space.v12,
                  _ReviewSection(
                    title: l10n.stepVehicleTitle,
                    onEdit: state.submitting
                        ? null
                        : () => edit(DraftStep.vehicle),
                    rows: [
                      (l10n.stepVehicle, d.vehicleType?.label ?? '—'),
                      (
                        l10n.reviewBudget,
                        d.expectedFare == null
                            ? l10n.openToBids
                            : Fmt.npr(d.expectedFare!),
                      ),
                      if (d.contactName.trim().isNotEmpty)
                        (l10n.detailsContact, d.contactName.trim()),
                      if (d.contactPhone.trim().isNotEmpty)
                        (
                          l10n.reviewPhone,
                          '+977 ${Validators.normalizePhone(d.contactPhone)}',
                        ),
                      if (d.notes.trim().isNotEmpty)
                        (l10n.detailsNotes, d.notes.trim()),
                    ],
                  ),
                  Space.v16,
                  if (!usage.isAtLimit)
                    InlineBanner(
                      tone: BannerTone.info,
                      message: l10n.reviewUsesRequest(
                        usage.used + 1,
                        usage.limit,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: state.submitting ? null : saveDraft,
                  child: Text(
                    l10n.actionSaveDraft,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              Space.h12,
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: error != null && error.isRetryable
                      ? l10n.actionTryAgain
                      : l10n.actionPostLoad,
                  icon: Icons.send_rounded,
                  loading: state.submitting,
                  onPressed: submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 34),
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
      icon: const Icon(Icons.edit_outlined, size: 16),
      label: Text(l10n.actionEdit),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.title, required this.rows, this.onEdit});
  final String title;
  final List<(String, String)> rows;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      trailing: _EditButton(onPressed: onEdit),
      child: Column(
        children: [for (final (label, value) in rows) InfoRow(label, value)],
      ),
    );
  }
}
