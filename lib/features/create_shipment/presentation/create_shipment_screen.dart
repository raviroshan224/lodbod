import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/constants/locations.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/field_prefix.dart';
import '../../../core/widgets/form_parts.dart';
import '../../../core/widgets/navigation_parts.dart';
import '../../../core/widgets/state_views.dart';
import '../../../routing/routes.dart';
import '../../auth/presentation/session.dart';
import '../../shipments/domain/shipment.dart';
import '../../shipments/presentation/shipments_providers.dart';
import '../../shipments/presentation/widgets/request_limit_sheet.dart';
import '../../shipments/presentation/widgets/shipment_visuals.dart';
import '../domain/shipment_draft.dart';
import 'create_shipment_controller.dart';
import 'widgets/step_header.dart';

/// Post Load: three short steps, then a review screen.
class CreateShipmentScreen extends ConsumerStatefulWidget {
  const CreateShipmentScreen({super.key});

  @override
  ConsumerState<CreateShipmentScreen> createState() =>
      _CreateShipmentScreenState();
}

class _CreateShipmentScreenState extends ConsumerState<CreateShipmentScreen> {
  bool _savingDraft = false;

  @override
  void initState() {
    super.initState();
    // Bring back a draft saved earlier (on this or another device).
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final restored = await ref
          .read(createShipmentProvider.notifier)
          .restoreSavedDraft();
      if (restored && mounted) {
        showMessage(context, 'Picked up where you left off');
      }
    });
  }

  Future<void> _saveDraft({bool quiet = false}) async {
    if (_savingDraft) return;
    setState(() => _savingDraft = true);
    try {
      await ref.read(createShipmentProvider.notifier).saveDraft();
      if (mounted && !quiet) {
        showMessage(context, 'Draft saved. Finish it any time from Post Load.');
      }
    } catch (e) {
      if (mounted) showMessage(context, mapError(e).message, isError: true);
    } finally {
      if (mounted) setState(() => _savingDraft = false);
    }
  }

  void _close() {
    final controller = ref.read(createShipmentProvider.notifier);
    if (controller.hasUserInput) {
      // Never lose what was typed: keep it on the account too.
      controller.saveDraft().ignore();
      showMessage(context, 'Draft saved');
    }
    context.canPop() ? context.pop() : context.go(Routes.home);
  }

  Future<void> _clear() async {
    final ok = await confirmAction(
      context,
      title: 'Start over?',
      message: 'Everything you entered for this load will be cleared, including the saved draft.',
      confirmLabel: 'Clear form',
      cancelLabel: 'Keep editing',
      destructive: true,
      icon: Icons.restart_alt_rounded,
    );
    if (ok) ref.read(createShipmentProvider.notifier).reset();
  }

  void _continue() {
    FocusScope.of(context).unfocus();
    final controller = ref.read(createShipmentProvider.notifier);
    final state = ref.read(createShipmentProvider);
    final isLast = state.step == DraftStep.values.last;
    if (!controller.next()) {
      HapticFeedback.heavyImpact();
      return;
    }
    if (isLast && controller.readyForReview()) {
      context.push(Routes.postLoadReview);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createShipmentProvider);
    final controller = ref.read(createShipmentProvider.notifier);
    final user = ref.watch(currentUserProvider);
    final usage = ref.watch(requestLimitUsageProvider).value;
    final isLast = state.step == DraftStep.values.last;

    return PopScope(
      // System back steps backwards through the form before leaving it.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (!controller.back()) _close();
      },
      child: Scaffold(
        appBar: DetailAppBar(
          title: 'Post a load',
          subtitle: 'Posting as ${user.displayCompany}',
          closeIcon: true,
          onBack: _close,
          actions: [
            TextButton.icon(
              onPressed: _savingDraft ? null : _saveDraft,
              icon: _savingDraft
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.bookmark_border_rounded, size: 18),
              label: const Text('Save draft'),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: const Icon(Icons.more_vert_rounded),
              position: PopupMenuPosition.under,
              onSelected: (_) => _clear(),
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: 'clear',
                  child: ListTile(
                    leading: Icon(Icons.restart_alt_rounded),
                    title: Text('Start over'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            StepHeader(
              current: state.step.index,
              titles: [
                for (final s in DraftStep.values) s.shortTitle,
                'Review',
              ],
              onTapStep: (i) => controller.goTo(DraftStep.values[i]),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, anim) => FadeTransition(
                  opacity: anim,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0.04, 0),
                      end: Offset.zero,
                    ).animate(anim),
                    child: child,
                  ),
                ),
                child: ListView(
                  key: ValueKey('${state.version}-${state.step}'),
                  padding: const EdgeInsets.fromLTRB(
                    Gap.page,
                    Gap.xs,
                    Gap.page,
                    Gap.xl,
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    if (usage != null &&
                        usage.isAtLimit &&
                        state.step == DraftStep.route) ...[
                      InlineBanner(
                        tone: BannerTone.warning,
                        title: 'All 3 mobile requests are in use',
                        message: 'Prepare it now and post it once one of your requests is delivered or cancelled.',
                        action: GestureDetector(
                          onTap: () => showRequestLimitSheet(context, usage),
                          child: const Text(
                            'How it works',
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
                    for (final done in DraftStep.values.take(
                      state.step.index,
                    )) ...[
                      _DoneStep(
                        step: done,
                        draft: state.draft,
                        onEdit: () => controller.goTo(done),
                      ),
                      Space.v8,
                    ],
                    AppCard(
                      padding: const EdgeInsets.all(Gap.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          switch (state.step) {
                            DraftStep.route => const _RouteStep(),
                            DraftStep.cargo => const _CargoStep(),
                            DraftStep.vehicle => const _VehicleStep(),
                          },
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(
          child: PrimaryButton(
            label: isLast
                ? 'Review request'
                : 'Continue to ${DraftStep.values[state.step.index + 1].shortTitle.toLowerCase()}',
            trailingIcon: Icons.arrow_forward_rounded,
            onPressed: _continue,
          ),
        ),
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep({
    required this.step,
    required this.draft,
    required this.onEdit,
  });
  final DraftStep step;
  final ShipmentDraft draft;
  final VoidCallback onEdit;

  String get _summary {
    final d = draft;
    return switch (step) {
      DraftStep.route => [
        '${d.pickup.trim()} → ${d.destination.trim()}',
        if (d.pickupAt != null)
          '${Fmt.weekdayDayMonth(d.pickupAt!)}, ${Fmt.time(d.pickupAt!)}',
      ].join(' · '),
      DraftStep.cargo => [
        if (d.category != null) d.category!.label,
        d.description.trim(),
        if (d.weight != null) '${Fmt.number(d.weight!)} ${d.weightUnit.symbol}',
      ].join(' · '),
      DraftStep.vehicle => d.vehicleType?.label ?? '',
    };
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      padding: const EdgeInsets.fromLTRB(Gap.lg, 12, Gap.sm, 12),
      semanticLabel: '${step.title}: $_summary. Edit',
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 18,
            ),
          ),
          Space.h12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
                Text(
                  _summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          TextButton(onPressed: onEdit, child: const Text('Edit')),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 1: route & schedule

class _RouteStep extends ConsumerStatefulWidget {
  const _RouteStep();

  @override
  ConsumerState<_RouteStep> createState() => _RouteStepState();
}

class _RouteStepState extends ConsumerState<_RouteStep> {
  late final TextEditingController _pickup;
  late final TextEditingController _destination;

  @override
  void initState() {
    super.initState();
    final d = ref.read(createShipmentProvider).draft;
    _pickup = TextEditingController(text: d.pickup);
    _destination = TextEditingController(text: d.destination);
  }

  @override
  void dispose() {
    _pickup.dispose();
    _destination.dispose();
    super.dispose();
  }

  CreateShipmentController get _controller =>
      ref.read(createShipmentProvider.notifier);

  void _swap() {
    HapticFeedback.selectionClick();
    _controller.edit(
      (d) => d.copyWith(pickup: d.destination, destination: d.pickup),
    );
    final d = ref.read(createShipmentProvider).draft;
    _pickup.text = d.pickup;
    _destination.text = d.destination;
  }

  /// Recent/popular city chip: fills pickup first, then destination.
  void _useCity(String city) {
    final d = ref.read(createShipmentProvider).draft;
    if (d.pickup.trim().isEmpty) {
      _pickup.text = city;
      _controller.edit((d) => d.copyWith(pickup: city));
    } else {
      _destination.text = city;
      _controller.edit((d) => d.copyWith(destination: city));
    }
  }

  Future<void> _pickDate(DateTime today, DateTime? current) async {
    final initial = current == null || current.isBefore(today)
        ? today
        : current;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: today,
      lastDate: today.add(const Duration(days: ShipmentDraft.maxDaysAhead)),
      helpText: 'Pickup date',
    );
    if (picked != null) _controller.selectPickupDate(picked);
  }

  Future<void> _pickTime(PickupTime? current, {required bool isToday}) async {
    final now = ref.read(clockProvider)();
    // Today, start the picker at the next whole hour rather than a time
    // that has already gone.
    final initial = current != null
        ? TimeOfDay(hour: current.hour, minute: current.minute)
        : isToday
        ? (now.hour >= 23
              ? const TimeOfDay(hour: 23, minute: 59)
              : TimeOfDay(hour: now.hour + 1, minute: 0))
        : const TimeOfDay(hour: 9, minute: 0);
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      helpText: 'Pickup time',
    );
    if (picked == null || !mounted) return;
    final accepted = _controller.selectPickupTime(
      PickupTime(picked.hour, picked.minute),
    );
    if (!accepted) {
      showMessage(
        context,
        'That time has already passed today. Choose a later time.',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createShipmentProvider.select((s) => s.draft));
    ref.watch(createShipmentProvider.select((s) => s.revealed));
    final errors = _controller.visibleErrors(DraftStep.route);
    // Don't suggest a city that's already in one of the fields.
    final chosen = {
      draft.pickup.trim().toLowerCase(),
      draft.destination.trim().toLowerCase(),
    };
    final recent = _recentCities(ref.watch(shipmentsProvider).value ?? const [])
        .where((c) => !chosen.contains(c.toLowerCase()))
        .toList();

    final now = ref.read(clockProvider)();
    final today = DateTime(now.year, now.month, now.day);
    final quickDates = [
      ('Today', today),
      ('Tomorrow', today.add(const Duration(days: 1))),
      ('+2 days', today.add(const Duration(days: 2))),
    ];
    final selectedDate = draft.pickupDate;
    final isCustomDate =
        selectedDate != null &&
        !quickDates.any((q) => DateUtils.isSameDay(q.$2, selectedDate));

    const quickTimes = [
      ('Morning', PickupTime(8, 0)),
      ('Midday', PickupTime(12, 0)),
      ('Afternoon', PickupTime(15, 0)),
      ('Evening', PickupTime(18, 0)),
    ];
    final selectedTime = draft.pickupTime;
    final isCustomTime =
        selectedTime != null && !quickTimes.any((q) => q.$2 == selectedTime);
    bool slotOpen(PickupTime t) =>
        selectedDate == null || ShipmentDraft.isOpen(selectedDate, t, now: now);
    final isToday =
        selectedDate != null && DateUtils.isSameDay(selectedDate, today);
    final someSlotsPassed = quickTimes.any((q) => !slotOpen(q.$2));
    final allSlotsPassed = quickTimes.every((q) => !slotOpen(q.$2));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                const SizedBox(height: 17),
                const Icon(
                  Icons.radio_button_checked_rounded,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                ...List.generate(
                  5,
                  (_) => Container(
                    width: 2,
                    height: 5,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: AppColors.border,
                  ),
                ),
                const Icon(
                  Icons.location_on_rounded,
                  size: 19,
                  color: AppColors.primary,
                ),
              ],
            ),
            Space.h10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _CityField(
                    controller: _pickup,
                    hint: 'Pickup city',
                    errorText: errors[DraftField.pickup],
                    onChanged: (v) =>
                        _controller.edit((d) => d.copyWith(pickup: v)),
                  ),
                  Space.v8,
                  _CityField(
                    controller: _destination,
                    hint: 'Destination city',
                    errorText: errors[DraftField.destination],
                    onChanged: (v) =>
                        _controller.edit((d) => d.copyWith(destination: v)),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, top: 30),
              child: CircleIconButton(
                icon: Icons.swap_vert_rounded,
                tooltip: 'Swap pickup and destination',
                size: 40,
                onPressed: _swap,
              ),
            ),
          ],
        ),
        Space.v12,
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recent.length + 1,
            separatorBuilder: (_, _) => Space.h6,
            itemBuilder: (_, i) {
              if (i == 0) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      'RECENT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                );
              }
              final city = recent[i - 1];
              return ActionChip(
                label: Text(city),
                onPressed: () => _useCity(city),
                padding: const EdgeInsets.symmetric(horizontal: 2),
                labelStyle: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              );
            },
          ),
        ),
        Space.v20,
        const FieldLabel('Pickup date'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final (label, date) in quickDates)
              ChoicePill(
                label: label,
                selected:
                    selectedDate != null &&
                    DateUtils.isSameDay(selectedDate, date),
                onTap: () => _controller.selectPickupDate(date),
              ),
            ChoicePill(
              label: isCustomDate
                  ? Fmt.weekdayDayMonth(selectedDate)
                  : 'Pick date',
              icon: Icons.calendar_month_outlined,
              selected: isCustomDate,
              onTap: () => _pickDate(today, selectedDate),
            ),
          ],
        ),
        if (selectedDate != null && !isCustomDate)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              Fmt.weekdayDayMonth(selectedDate),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        FieldErrorText(errors[DraftField.pickupDate]),
        Space.v20,
        const FieldLabel('Pickup time'),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Gap.sm,
          crossAxisSpacing: Gap.sm,
          // Taller cells when the user has enlarged text.
          childAspectRatio:
              2.1 / MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6),
          children: [
            for (final (label, time) in quickTimes)
              ChoicePill(
                label: label,
                caption: slotOpen(time) ? _hhmm(time) : 'passed',
                selected: selectedTime == time,
                enabled: slotOpen(time),
                onTap: () => _controller.selectPickupTime(time),
              ),
            ChoicePill(
              label: isCustomTime ? _hhmm(selectedTime) : 'Exact',
              caption: isCustomTime ? 'custom' : 'pick time',
              selected: isCustomTime,
              onTap: () => _pickTime(selectedTime, isToday: isToday),
            ),
          ],
        ),
        if (isToday && someSlotsPassed && errors[DraftField.pickupTime] == null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              allSlotsPassed
                  ? "Today's usual slots have passed. Pick an exact time or another day."
                  : 'Earlier times today have passed. Pick a later slot or an exact time.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
        FieldErrorText(errors[DraftField.pickupTime]),
      ],
    );
  }

  static String _hhmm(PickupTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  /// Cities from the shipper's recent loads, then popular hubs.
  static List<String> _recentCities(List<Shipment> shipments) {
    final seen = <String>{};
    final out = <String>[];
    for (final s in shipments) {
      for (final c in [s.pickup, s.destination]) {
        if (seen.add(c.toLowerCase())) out.add(c);
      }
    }
    for (final c in const [
      'Kathmandu',
      'Pokhara',
      'Birgunj',
      'Biratnagar',
      'Butwal',
      'Hetauda',
    ]) {
      if (seen.add(c.toLowerCase())) out.add(c);
    }
    return out.take(8).toList();
  }
}

/// City text field with suggestions; free text is allowed.
class _CityField extends StatefulWidget {
  const _CityField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.errorText,
  });

  final TextEditingController controller;
  final String hint;
  final String? errorText;
  final ValueChanged<String> onChanged;

  @override
  State<_CityField> createState() => _CityFieldState();
}

class _CityFieldState extends State<_CityField> {
  final _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      textEditingController: widget.controller,
      focusNode: _focus,
      optionsBuilder: (value) => suggestCities(value.text),
      onSelected: widget.onChanged,
      fieldViewBuilder: (context, controller, focusNode, _) => TextField(
        controller: controller,
        focusNode: focusNode,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.next,
        onChanged: widget.onChanged,
        inputFormatters: [LengthLimitingTextInputFormatter(60)],
        decoration: InputDecoration(
          hintText: widget.hint,
          errorText: widget.errorText,
          suffixIcon: const Icon(Icons.search_rounded, size: 19),
        ),
      ),
      optionsViewBuilder: (context, onSelected, options) => Align(
        alignment: Alignment.topLeft,
        child: Material(
          elevation: 6,
          borderRadius: Radii.input,
          color: AppColors.surface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240, maxWidth: 280),
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 4),
              shrinkWrap: true,
              children: [
                for (final city in options)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.location_on_outlined, size: 20),
                    title: Text(city),
                    onTap: () => onSelected(city),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 2: cargo

class _CargoStep extends ConsumerStatefulWidget {
  const _CargoStep();

  @override
  ConsumerState<_CargoStep> createState() => _CargoStepState();
}

class _CargoStepState extends ConsumerState<_CargoStep> {
  late final TextEditingController _description;
  late final TextEditingController _weight;

  @override
  void initState() {
    super.initState();
    final d = ref.read(createShipmentProvider).draft;
    _description = TextEditingController(text: d.description);
    _weight = TextEditingController(text: d.weightText);
  }

  @override
  void dispose() {
    _description.dispose();
    _weight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createShipmentProvider.select((s) => s.draft));
    ref.watch(createShipmentProvider.select((s) => s.revealed));
    final controller = ref.read(createShipmentProvider.notifier);
    final errors = controller.visibleErrors(DraftStep.cargo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('Material'),
        Wrap(
          spacing: Gap.sm,
          runSpacing: Gap.sm,
          children: [
            for (final c in CargoCategory.values)
              ChoicePill(
                label: c.label,
                icon: cargoIcon(c),
                selected: draft.category == c,
                onTap: () => controller.edit((d) => d.copyWith(category: c)),
              ),
          ],
        ),
        FieldErrorText(errors[DraftField.category]),
        Space.v20,
        const FieldLabel('What are you shipping?'),
        TextField(
          controller: _description,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.next,
          maxLength: 80,
          onChanged: (v) => controller.edit((d) => d.copyWith(description: v)),
          decoration: InputDecoration(
            hintText: 'e.g. 240 cement bags, steel pipes',
            prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
            errorText: errors[DraftField.description],
            counterText: '',
          ),
        ),
        Space.v16,
        // The unit sits on the label row, as a setting for the field, so
        // the value box holds only the number.
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Expanded(child: FieldLabel('Total weight')),
            _UnitToggle(
              selected: draft.weightUnit,
              onChanged: (u) =>
                  controller.edit((d) => d.copyWith(weightUnit: u)),
            ),
          ],
        ),
        TextField(
          controller: _weight,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            // Digits with at most one decimal point and 2 decimals.
            TextInputFormatter.withFunction(
              (old, next) =>
                  RegExp(r'^\d{0,6}(\.\d{0,2})?$').hasMatch(next.text)
                  ? next
                  : old,
            ),
          ],
          onChanged: (v) => controller.edit((d) => d.copyWith(weightText: v)),
          decoration: InputDecoration(
            hintText: 'e.g. 12',
            prefixIcon: const Icon(Icons.scale_outlined, size: 20),
            suffixText: draft.weightUnit == WeightUnit.tonne ? 'tonnes' : 'kg',
            errorText: errors[DraftField.weight],
          ),
        ),
      ],
    );
  }
}

class _UnitToggle extends StatelessWidget {
  const _UnitToggle({required this.selected, required this.onChanged});
  final WeightUnit selected;
  final ValueChanged<WeightUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Matches FieldLabel's bottom padding so both sit on one baseline.
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer,
          borderRadius: Radii.chip,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [for (final unit in WeightUnit.values) _unit(unit)],
        ),
      ),
    );
  }

  Widget _unit(WeightUnit unit) {
    final isSelected = unit == selected;
    return Semantics(
      selected: isSelected,
      button: true,
      label: unit.label,
      excludeSemantics: true,
      child: Material(
        color: isSelected ? AppColors.surface : Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        elevation: isSelected ? 1 : 0,
        shadowColor: Colors.black26,
        child: InkWell(
          onTap: () {
            if (!isSelected) HapticFeedback.selectionClick();
            onChanged(unit);
          },
          child: Container(
            constraints: const BoxConstraints(minHeight: 28),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: Text(
              unit == WeightUnit.tonne ? 'Tonnes' : 'kg',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Step 3: vehicle, fare, contact

class _VehicleStep extends ConsumerStatefulWidget {
  const _VehicleStep();

  @override
  ConsumerState<_VehicleStep> createState() => _VehicleStepState();
}

class _VehicleStepState extends ConsumerState<_VehicleStep> {
  late final TextEditingController _fare;
  late final TextEditingController _contactName;
  late final TextEditingController _contactPhone;
  late final TextEditingController _notes;

  @override
  void initState() {
    super.initState();
    final d = ref.read(createShipmentProvider).draft;
    _fare = TextEditingController(text: d.fareText);
    _contactName = TextEditingController(text: d.contactName);
    _contactPhone = TextEditingController(text: d.contactPhone);
    _notes = TextEditingController(text: d.notes);
  }

  @override
  void dispose() {
    _fare.dispose();
    _contactName.dispose();
    _contactPhone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(createShipmentProvider.select((s) => s.draft));
    ref.watch(createShipmentProvider.select((s) => s.revealed));
    final controller = ref.read(createShipmentProvider.notifier);
    final errors = controller.visibleErrors(DraftStep.vehicle);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FieldLabel('Vehicle type'),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: Gap.sm,
          crossAxisSpacing: Gap.sm,
          childAspectRatio: 1.15,
          children: [
            for (final v in VehicleType.values)
              _VehicleOption(
                type: v,
                selected: draft.vehicleType == v,
                onTap: () {
                  HapticFeedback.selectionClick();
                  controller.edit((d) => d.copyWith(vehicleType: v));
                },
              ),
          ],
        ),
        FieldErrorText(errors[DraftField.vehicle]),
        Space.v20,
        const FieldLabel('Your budget', isRequired: false),
        TextField(
          controller: _fare,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(9),
          ],
          onChanged: (v) => controller.edit((d) => d.copyWith(fareText: v)),
          decoration: InputDecoration(
            hintText: 'e.g. 30000',
            prefixIcon: const FieldPrefix.rupees(),
            helperText:
                'Carriers see this as a guide and can bid above or below it.',
            helperMaxLines: 2,
            errorText: errors[DraftField.expectedFare],
          ),
        ),
        Space.v16,
        const FieldLabel('Pickup contact', isRequired: false),
        TextField(
          controller: _contactName,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          onChanged: (v) => controller.edit((d) => d.copyWith(contactName: v)),
          decoration: InputDecoration(
            hintText: 'Name at the pickup point',
            prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
            errorText: errors[DraftField.contactName],
          ),
        ),
        Space.v8,
        TextField(
          controller: _contactPhone,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
            LengthLimitingTextInputFormatter(16),
          ],
          onChanged: (v) => controller.edit((d) => d.copyWith(contactPhone: v)),
          decoration: InputDecoration(
            hintText: '98XXXXXXXX',
            prefixIcon: const FieldPrefix.phone(),
            errorText: errors[DraftField.contactPhone],
          ),
        ),
        Space.v16,
        const FieldLabel('Notes for carriers', isRequired: false),
        TextField(
          controller: _notes,
          minLines: 2,
          maxLines: 4,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (v) => controller.edit((d) => d.copyWith(notes: v)),
          decoration: InputDecoration(
            hintText: 'Loading instructions, packaging, gate timings…',
            errorText: errors[DraftField.notes],
          ),
        ),
      ],
    );
  }
}

class _VehicleOption extends StatelessWidget {
  const _VehicleOption({
    required this.type,
    required this.selected,
    required this.onTap,
  });
  final VehicleType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: type.label,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.input,
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  vehicleIcon(type),
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                ),
                Space.v4,
                Text(
                  type.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected
                        ? AppColors.onPrimarySoft
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
