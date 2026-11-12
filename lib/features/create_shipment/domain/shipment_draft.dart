import '../../../core/l10n/strings.dart';
import '../../../core/utils/validators.dart';
import '../../shipments/domain/shipment.dart';

/// Every field on the Post Load form, so errors can be keyed per field.
enum DraftField {
  pickup,
  destination,
  pickupDate,
  pickupTime,
  category,
  description,
  weight,
  vehicle,
  expectedFare,
  contactName,
  contactPhone,
  notes,
}

/// The three input steps of Post Load. Review is a separate screen.
enum DraftStep {
  route,
  cargo,
  vehicle;

  String get shortTitle => switch (this) {
    route => l10n.stepRoute,
    cargo => l10n.stepCargo,
    vehicle => l10n.stepVehicle,
  };
  String get title => switch (this) {
    route => l10n.stepRouteTitle,
    cargo => l10n.stepCargoTitle,
    vehicle => l10n.stepVehicleTitle,
  };

  Set<DraftField> get fields => switch (this) {
    route => const {
      DraftField.pickup,
      DraftField.destination,
      DraftField.pickupDate,
      DraftField.pickupTime,
    },
    cargo => const {
      DraftField.category,
      DraftField.description,
      DraftField.weight,
    },
    vehicle => const {
      DraftField.vehicle,
      DraftField.expectedFare,
      DraftField.contactName,
      DraftField.contactPhone,
      DraftField.notes,
    },
  };
}

/// Hour and minute without a date or a Flutter dependency.
class PickupTime {
  const PickupTime(this.hour, this.minute);
  final int hour;
  final int minute;

  @override
  bool operator ==(Object other) =>
      other is PickupTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

const _unset = Object();

/// What the user has typed so far on Post Load, kept as raw text so nothing
/// they entered is lost or reformatted, including when submission is
/// rejected by the request limit.
class ShipmentDraft {
  const ShipmentDraft({
    this.pickup = '',
    this.destination = '',
    this.pickupDate,
    this.pickupTime,
    this.category,
    this.description = '',
    this.weightText = '',
    this.weightUnit = WeightUnit.tonne,
    this.vehicleType,
    this.fareText = '',
    this.contactName = '',
    this.contactPhone = '',
    this.notes = '',
  });

  static const maxWeightTonnes = 100.0;
  static const maxFare = 10000000;
  static const maxDaysAhead = 90;

  final String pickup;
  final String destination;

  /// Date part only (time of day is ignored).
  final DateTime? pickupDate;
  final PickupTime? pickupTime;
  final CargoCategory? category;
  final String description;
  final String weightText;
  final WeightUnit weightUnit;
  final VehicleType? vehicleType;
  final String fareText;
  final String contactName;
  final String contactPhone;
  final String notes;

  ShipmentDraft copyWith({
    String? pickup,
    String? destination,
    Object? pickupDate = _unset,
    Object? pickupTime = _unset,
    Object? category = _unset,
    String? description,
    String? weightText,
    WeightUnit? weightUnit,
    Object? vehicleType = _unset,
    String? fareText,
    String? contactName,
    String? contactPhone,
    String? notes,
  }) {
    return ShipmentDraft(
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      pickupDate: identical(pickupDate, _unset)
          ? this.pickupDate
          : pickupDate as DateTime?,
      pickupTime: identical(pickupTime, _unset)
          ? this.pickupTime
          : pickupTime as PickupTime?,
      category: identical(category, _unset)
          ? this.category
          : category as CargoCategory?,
      description: description ?? this.description,
      weightText: weightText ?? this.weightText,
      weightUnit: weightUnit ?? this.weightUnit,
      vehicleType: identical(vehicleType, _unset)
          ? this.vehicleType
          : vehicleType as VehicleType?,
      fareText: fareText ?? this.fareText,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      notes: notes ?? this.notes,
    );
  }

  DateTime? get pickupAt {
    final d = pickupDate;
    final t = pickupTime;
    if (d == null || t == null) return null;
    return DateTime(d.year, d.month, d.day, t.hour, t.minute);
  }

  /// Whether a pickup at [time] on [day] is still in the future. The form
  /// uses this to disable time slots that have already passed, and
  /// [validate] applies the same rule.
  static bool isOpen(DateTime day, PickupTime time, {required DateTime now}) =>
      DateTime(
        day.year,
        day.month,
        day.day,
        time.hour,
        time.minute,
      ).isAfter(now);

  /// Sets the pickup date and drops the time if it would be in the past on
  /// that date, so the form never holds a schedule it will reject.
  ShipmentDraft withPickupDate(DateTime day, {required DateTime now}) {
    final t = pickupTime;
    final keepTime = t != null && isOpen(day, t, now: now);
    return copyWith(pickupDate: day, pickupTime: keepTime ? t : null);
  }

  /// Clears a schedule that is no longer in the future, e.g. a saved draft
  /// reopened on a later day. Everything else is kept.
  ShipmentDraft withoutPastSchedule({required DateTime now}) {
    final d = pickupDate;
    if (d == null) return this;
    final today = DateTime(now.year, now.month, now.day);
    if (DateTime(d.year, d.month, d.day).isBefore(today)) {
      return copyWith(pickupDate: null, pickupTime: null);
    }
    return withPickupDate(d, now: now);
  }

  double? get weight => double.tryParse(weightText.trim().replaceAll(',', ''));

  int? get expectedFare {
    final digits = fareText.replaceAll(RegExp(r'[,\s]'), '');
    if (digits.isEmpty) return null;
    return int.tryParse(digits);
  }

  /// Errors for the fields of one step. Empty map means the step is valid.
  Map<DraftField, String> validateStep(
    DraftStep step, {
    required DateTime now,
  }) {
    final all = validate(now: now);
    return {
      for (final e in all.entries)
        if (step.fields.contains(e.key)) e.key: e.value,
    };
  }

  /// Every validation rule for the form, in one place.
  Map<DraftField, String> validate({required DateTime now}) {
    final errors = <DraftField, String>{};

    final from = pickup.trim();
    final to = destination.trim();
    if (from.isEmpty) {
      errors[DraftField.pickup] = l10n.vPickupRequired;
    } else if (from.length < 2) {
      errors[DraftField.pickup] = l10n.vPickupInvalid;
    }
    if (to.isEmpty) {
      errors[DraftField.destination] = l10n.vDestinationRequired;
    } else if (to.length < 2) {
      errors[DraftField.destination] = l10n.vDestinationInvalid;
    } else if (from.isNotEmpty && from.toLowerCase() == to.toLowerCase()) {
      errors[DraftField.destination] = l10n.vDestinationSame;
    }

    final today = DateTime(now.year, now.month, now.day);
    final date = pickupDate;
    if (date == null) {
      errors[DraftField.pickupDate] = l10n.vPickupDateRequired;
    } else {
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(today)) {
        errors[DraftField.pickupDate] = l10n.vPickupDatePast;
      } else if (day.difference(today).inDays > maxDaysAhead) {
        errors[DraftField.pickupDate] = l10n.vPickupDateTooFar(maxDaysAhead);
      }
    }
    if (pickupTime == null) {
      errors[DraftField.pickupTime] = l10n.vPickupTimeRequired;
    } else if (date != null &&
        !errors.containsKey(DraftField.pickupDate) &&
        !isOpen(date, pickupTime!, now: now)) {
      errors[DraftField.pickupTime] = l10n.vPickupTimePast;
    }

    if (category == null) {
      errors[DraftField.category] = l10n.vCategoryRequired;
    }
    final desc = description.trim();
    if (desc.isEmpty) {
      errors[DraftField.description] = l10n.vDescriptionRequired;
    } else if (desc.length > 80) {
      errors[DraftField.description] = l10n.vDescriptionTooLong;
    }

    final w = weight;
    if (weightText.trim().isEmpty) {
      errors[DraftField.weight] = l10n.vWeightRequired;
    } else if (w == null || w.isNaN) {
      errors[DraftField.weight] = l10n.vWeightNumber;
    } else if (w <= 0) {
      errors[DraftField.weight] = l10n.vWeightPositive;
    } else if (weightUnit.toTonnes(w) > maxWeightTonnes) {
      errors[DraftField.weight] = l10n.vWeightMax(maxWeightTonnes.toInt());
    }

    if (vehicleType == null) {
      errors[DraftField.vehicle] = l10n.vVehicleRequired;
    }

    if (fareText.trim().isNotEmpty) {
      final fare = expectedFare;
      if (fare == null) {
        errors[DraftField.expectedFare] = l10n.vFareWhole;
      } else if (fare <= 0) {
        errors[DraftField.expectedFare] = l10n.vFarePositive;
      } else if (fare > maxFare) {
        errors[DraftField.expectedFare] = l10n.vFareTooHigh;
      }
    }

    if (contactName.trim().length > 60) {
      errors[DraftField.contactName] = l10n.vContactNameTooLong;
    }
    final phoneError = Validators.phone(contactPhone, isRequired: false);
    if (phoneError != null) errors[DraftField.contactPhone] = phoneError;
    if (notes.trim().length > 300) {
      errors[DraftField.notes] = l10n.vNotesTooLong;
    }

    return errors;
  }

  /// Converts a valid draft into create input. Call [validate] first.
  NewShipment toNewShipment() {
    final at = pickupAt;
    final w = weight;
    if (at == null || w == null || category == null || vehicleType == null) {
      throw StateError('toNewShipment() called on an incomplete draft');
    }
    final phone = contactPhone.trim();
    return NewShipment(
      pickup: _titleCase(pickup.trim()),
      destination: _titleCase(destination.trim()),
      cargoCategory: category!,
      cargoDescription: description.trim(),
      weight: w,
      weightUnit: weightUnit,
      vehicleType: vehicleType!,
      pickupAt: at,
      expectedFare: expectedFare,
      contactName: contactName.trim(),
      contactPhone: phone.isEmpty ? '' : Validators.normalizePhone(phone),
      notes: notes.trim(),
    );
  }

  static String _titleCase(String value) => value
      .split(RegExp(r'\s+'))
      .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}
