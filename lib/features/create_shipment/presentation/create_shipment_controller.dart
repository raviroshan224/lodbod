import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exception.dart';
import '../../data/models/shipment.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/formatters.dart';
import '../../data/providers.dart';
import '../../domain/shipment_draft.dart';
import '../auth/session.dart';

const _keep = Object();

class CreateShipmentState {
  const CreateShipmentState({
    required this.draft,
    this.step = DraftStep.route,
    this.revealed = const {},
    this.submitting = false,
    this.submitError,
    this.requestId,
    this.lastCreated,
    this.version = 0,
  });

  final ShipmentDraft draft;
  final DraftStep step;

  /// Steps the user tried to leave; only these show validation errors, so a
  /// fresh form isn't covered in red.
  final Set<DraftStep> revealed;
  final bool submitting;
  final AppException? submitError;

  /// Idempotency key for the current submission. Kept across retries of an
  /// unchanged draft so a retry after a lost response can't double-create.
  final String? requestId;

  /// The shipment created by the last successful submit (for confirmation).
  final Shipment? lastCreated;

  /// Bumped when the form is reset so text fields re-initialise.
  final int version;

  CreateShipmentState copyWith({
    ShipmentDraft? draft,
    DraftStep? step,
    Set<DraftStep>? revealed,
    bool? submitting,
    Object? submitError = _keep,
    Object? requestId = _keep,
  }) {
    return CreateShipmentState(
      draft: draft ?? this.draft,
      step: step ?? this.step,
      revealed: revealed ?? this.revealed,
      submitting: submitting ?? this.submitting,
      submitError: identical(submitError, _keep)
          ? this.submitError
          : submitError as AppException?,
      requestId: identical(requestId, _keep)
          ? this.requestId
          : requestId as String?,
      lastCreated: lastCreated,
      version: version,
    );
  }
}

sealed class SubmitResult {
  const SubmitResult();
}

class SubmitSucceeded extends SubmitResult {
  const SubmitSucceeded(this.shipment);
  final Shipment shipment;
}

/// Validation failed (e.g. the pickup time passed while reviewing). The
/// controller has moved to the first step with errors.
class SubmitInvalid extends SubmitResult {
  const SubmitInvalid();
}

class SubmitFailed extends SubmitResult {
  const SubmitFailed(this.error);
  final AppException error;
}

class SubmitIgnored extends SubmitResult {
  const SubmitIgnored();
}

/// Post Load form state and submission.
///
/// Not auto-disposed: the draft survives leaving the form, switching tabs
/// and a rejected submission (including the request limit). It is cleared
/// only by a successful submit, an explicit "Clear", or signing out.
class CreateShipmentController extends Notifier<CreateShipmentState> {
  @override
  CreateShipmentState build() {
    ref.watch(currentUidProvider); // A new account starts with a new form.
    return CreateShipmentState(draft: _blankDraft());
  }

  ShipmentDraft _blankDraft() {
    final session = ref.read(sessionProvider);
    final user = session is SessionReady ? session.profile : null;
    return _withContact(const ShipmentDraft(), user);
  }

  static ShipmentDraft _withContact(ShipmentDraft d, UserProfile? user) => d
      .copyWith(contactName: user?.name ?? '', contactPhone: user?.phone ?? '');

  /// True when the user has typed anything worth keeping.
  bool get hasUserInput {
    final d = state.draft;
    return d.pickup.isNotEmpty ||
        d.destination.isNotEmpty ||
        d.description.isNotEmpty ||
        d.weightText.isNotEmpty ||
        d.category != null ||
        d.vehicleType != null;
  }

  /// Restores the draft saved to the account (if the form is still empty).
  Future<bool> restoreSavedDraft() async {
    if (hasUserInput || state.submitting) return false;
    final uid = ref.read(currentUidProvider);
    if (uid == null) return false;
    try {
      final saved = await ref.read(accountRepositoryProvider).loadDraft(uid);
      if (saved == null || !ref.mounted || hasUserInput) return false;
      state = CreateShipmentState(
        draft: saved.withoutPastSchedule(now: _now),
        version: state.version + 1,
      );
      return true;
    } catch (_) {
      return false; // A missing draft is not worth an error message.
    }
  }

  /// Saves the current form to the account so it can be finished later,
  /// on any device.
  Future<void> saveDraft() async {
    final uid = ref.read(currentUidProvider);
    if (uid == null) return;
    await ref.read(accountRepositoryProvider).saveDraft(uid, state.draft);
  }

  /// Starts a new form from an earlier shipment ("Post a similar load").
  /// The schedule is left empty because it must be in the future.
  void prefillFrom(Shipment s) {
    final session = ref.read(sessionProvider);
    final user = session is SessionReady ? session.profile : null;
    state = CreateShipmentState(
      draft: _withContact(
        ShipmentDraft(
          pickup: s.pickup,
          destination: s.destination,
          category: s.cargoCategory,
          description: s.cargoDescription,
          weightText: Fmt.number(s.weight),
          weightUnit: s.weightUnit,
          vehicleType: s.vehicleType,
          fareText: (s.agreedFare ?? s.expectedFare)?.toString() ?? '',
          notes: s.notes,
        ),
        user,
      ),
      version: state.version + 1,
    );
  }

  DateTime get _now => ref.read(clockProvider)();

  /// Errors to display for [step] (empty until the user tries to continue).
  Map<DraftField, String> visibleErrors(DraftStep step) =>
      state.revealed.contains(step)
      ? state.draft.validateStep(step, now: _now)
      : const {};

  void edit(ShipmentDraft Function(ShipmentDraft draft) change) {
    if (state.submitting) return;
    state = state.copyWith(
      draft: change(state.draft),
      submitError: null,
      // A changed draft is a different request.
      requestId: null,
    );
  }

  /// Validates the current step and advances. Returns false if invalid.
  bool next() {
    final errors = state.draft.validateStep(state.step, now: _now);
    if (errors.isNotEmpty) {
      state = state.copyWith(revealed: {...state.revealed, state.step});
      return false;
    }
    final i = state.step.index;
    if (i < DraftStep.values.length - 1) {
      state = state.copyWith(step: DraftStep.values[i + 1]);
    }
    return true;
  }

  /// Whole-form check before showing the review screen. On failure, jumps to
  /// the first step with errors.
  bool readyForReview() {
    final errors = state.draft.validate(now: _now);
    if (errors.isEmpty) return true;
    final firstInvalid = DraftStep.values.firstWhere(
      (s) => s.fields.any(errors.containsKey),
    );
    state = state.copyWith(
      step: firstInvalid,
      revealed: {...state.revealed, firstInvalid},
    );
    return false;
  }

  void goTo(DraftStep step) => state = state.copyWith(step: step);

  /// Picks a pickup date. A chosen time that would be in the past on that
  /// date is cleared rather than kept and flagged.
  void selectPickupDate(DateTime day) =>
      edit((d) => d.withPickupDate(day, now: _now));

  /// Picks a pickup time. Returns false (and changes nothing) if that time
  /// has already passed on the chosen date.
  bool selectPickupTime(PickupTime time) {
    final day = state.draft.pickupDate;
    if (day != null && !ShipmentDraft.isOpen(day, time, now: _now)) {
      return false;
    }
    edit((d) => d.copyWith(pickupTime: time));
    return true;
  }

  bool back() {
    if (state.step.index == 0) return false;
    state = state.copyWith(step: DraftStep.values[state.step.index - 1]);
    return true;
  }

  /// Discards the form and any draft saved to the account.
  void reset() {
    final uid = ref.read(currentUidProvider);
    if (uid != null) {
      ref.read(accountRepositoryProvider).clearDraft(uid).ignore();
    }
    state = CreateShipmentState(
      draft: _blankDraft(),
      version: state.version + 1,
    );
  }

  Future<SubmitResult> submit() async {
    if (state.submitting) return const SubmitIgnored();
    if (!readyForReview()) return const SubmitInvalid();

    final user = ref.read(currentUserProvider);
    final repo = ref.read(shipmentRepositoryProvider);
    final requestId = state.requestId ?? repo.newRequestId();
    state = state.copyWith(
      submitting: true,
      submitError: null,
      requestId: requestId,
    );

    try {
      final created = await repo.createShipment(
        shipperId: user.id,
        requestId: requestId,
        input: state.draft.toNewShipment(),
      );
      ref.read(accountRepositoryProvider).clearDraft(user.id).ignore();
      state = CreateShipmentState(
        draft: _blankDraft(),
        lastCreated: created,
        version: state.version + 1,
      );
      return SubmitSucceeded(created);
    } catch (e) {
      final error = mapError(e);
      // Keep the draft (and the request id) exactly as they were.
      state = state.copyWith(submitting: false, submitError: error);
      return SubmitFailed(error);
    }
  }
}

final createShipmentProvider =
    NotifierProvider<CreateShipmentController, CreateShipmentState>(
      CreateShipmentController.new,
    );
