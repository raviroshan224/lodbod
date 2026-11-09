import '../core/utils/validators.dart';
import '../data/models/shipment.dart';

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
  route('Route', 'Route & schedule'),
  cargo('Cargo', 'Cargo details'),
  vehicle('Vehicle', 'Vehicle & contact');

  const DraftStep(this.shortTitle, this.title);
  final String shortTitle;
  final String title;

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
      errors[DraftField.pickup] = 'Pickup location is required';
    } else if (from.length < 2) {
      errors[DraftField.pickup] = 'Enter a valid pickup location';
    }
    if (to.isEmpty) {
      errors[DraftField.destination] = 'Destination is required';
    } else if (to.length < 2) {
      errors[DraftField.destination] = 'Enter a valid destination';
    } else if (from.isNotEmpty && from.toLowerCase() == to.toLowerCase()) {
      errors[DraftField.destination] =
          'Destination must be different from the pickup location';
    }

    final today = DateTime(now.year, now.month, now.day);
    final date = pickupDate;
    if (date == null) {
      errors[DraftField.pickupDate] = 'Choose a pickup date';
    } else {
      final day = DateTime(date.year, date.month, date.day);
      if (day.isBefore(today)) {
        errors[DraftField.pickupDate] = "Pickup date can't be in the past";
      } else if (day.difference(today).inDays > maxDaysAhead) {
        errors[DraftField.pickupDate] =
            'Pickup must be within the next $maxDaysAhead days';
      }
    }
    if (pickupTime == null) {
      errors[DraftField.pickupTime] = 'Choose a pickup time';
    } else if (!errors.containsKey(DraftField.pickupDate)) {
      final at = pickupAt;
      if (at != null && !at.isAfter(now)) {
        errors[DraftField.pickupTime] = "Pickup time can't be in the past";
      }
    }

    if (category == null) {
      errors[DraftField.category] = 'Choose a cargo category';
    }
    final desc = description.trim();
    if (desc.isEmpty) {
      errors[DraftField.description] = 'Describe the cargo, e.g. "Steel pipes"';
    } else if (desc.length > 80) {
      errors[DraftField.description] =
          'Keep the description under 80 characters';
    }

    final w = weight;
    if (weightText.trim().isEmpty) {
      errors[DraftField.weight] = 'Weight is required';
    } else if (w == null || w.isNaN) {
      errors[DraftField.weight] = 'Enter weight as a number';
    } else if (w <= 0) {
      errors[DraftField.weight] = 'Weight must be greater than 0';
    } else if (weightUnit.toTonnes(w) > maxWeightTonnes) {
      errors[DraftField.weight] =
          'Maximum ${maxWeightTonnes.toInt()} t per request';
    }

    if (vehicleType == null) {
      errors[DraftField.vehicle] = 'Choose a vehicle type';
    }

    if (fareText.trim().isNotEmpty) {
      final fare = expectedFare;
      if (fare == null) {
        errors[DraftField.expectedFare] = 'Enter the fare in whole rupees';
      } else if (fare <= 0) {
        errors[DraftField.expectedFare] = 'Fare must be greater than 0';
      } else if (fare > maxFare) {
        errors[DraftField.expectedFare] = 'That fare looks too high';
      }
    }

    if (contactName.trim().length > 60) {
      errors[DraftField.contactName] = 'Keep the name under 60 characters';
    }
    final phoneError = Validators.phone(contactPhone, isRequired: false);
    if (phoneError != null) errors[DraftField.contactPhone] = phoneError;
    if (notes.trim().length > 300) {
      errors[DraftField.notes] = 'Keep notes under 300 characters';
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
