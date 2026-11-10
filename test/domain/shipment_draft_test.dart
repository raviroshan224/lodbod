import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/features/create_shipment/domain/shipment_draft.dart';
import 'package:lodbod/features/shipments/domain/shipment.dart';

void main() {
  final now = DateTime(2026, 11, 7, 10, 30);
  final tomorrow = DateTime(2026, 11, 8);

  final valid = ShipmentDraft(
    pickup: 'kathmandu',
    destination: 'Pokhara',
    pickupDate: tomorrow,
    pickupTime: const PickupTime(8, 0),
    category: CargoCategory.steel,
    description: 'Steel pipes',
    weightText: '10',
    vehicleType: VehicleType.openTruck,
    fareText: '18000',
    contactPhone: '+977 9841000001',
  );

  Map<DraftField, String> errorsOf(ShipmentDraft d) => d.validate(now: now);

  test('a complete draft is valid and converts to create input', () {
    expect(errorsOf(valid), isEmpty);
    final input = valid.toNewShipment();
    expect(input.pickup, 'Kathmandu');
    expect(input.pickupAt, DateTime(2026, 11, 8, 8));
    expect(input.weight, 10);
    expect(input.expectedFare, 18000);
    expect(input.contactPhone, '9841000001');
  });

  test('an empty draft reports every required field', () {
    expect(
      errorsOf(const ShipmentDraft()).keys,
      containsAll([
        DraftField.pickup,
        DraftField.destination,
        DraftField.pickupDate,
        DraftField.pickupTime,
        DraftField.category,
        DraftField.description,
        DraftField.weight,
        DraftField.vehicle,
      ]),
    );
  });

  test('optional fields (fare, contact, notes) may be blank', () {
    final d = valid.copyWith(
      fareText: '',
      contactName: '',
      contactPhone: '',
      notes: '',
    );
    expect(errorsOf(d), isEmpty);
    expect(d.toNewShipment().expectedFare, isNull);
  });

  group('route', () {
    test('pickup and destination cannot be blank', () {
      final e = errorsOf(valid.copyWith(pickup: '   ', destination: ''));
      expect(e[DraftField.pickup], 'Pickup location is required');
      expect(e[DraftField.destination], 'Destination is required');
    });

    test(
      'pickup and destination cannot be identical (ignoring case and spaces)',
      () {
        final e = errorsOf(
          valid.copyWith(pickup: ' Pokhara ', destination: 'pokhara'),
        );
        expect(e[DraftField.destination], contains('different'));
      },
    );
  });

  group('pickup date and time', () {
    test('a past date is rejected', () {
      final e = errorsOf(valid.copyWith(pickupDate: DateTime(2026, 11, 6)));
      expect(e[DraftField.pickupDate], "Pickup date can't be in the past");
    });

    test('today is allowed only for a time that has not passed', () {
      final today = DateTime(2026, 11, 7);
      expect(
        errorsOf(
          valid.copyWith(pickupDate: today, pickupTime: const PickupTime(9, 0)),
        )[DraftField.pickupTime],
        "Pickup time can't be in the past",
      );
      expect(
        errorsOf(
          valid.copyWith(
            pickupDate: today,
            pickupTime: const PickupTime(15, 0),
          ),
        ),
        isEmpty,
      );
    });

    test('a slot is open only if it is still ahead of now', () {
      final today = DateTime(2026, 11, 7); // now is 10:30
      expect(
        ShipmentDraft.isOpen(today, const PickupTime(8, 0), now: now),
        isFalse,
      );
      expect(
        ShipmentDraft.isOpen(today, const PickupTime(10, 30), now: now),
        isFalse,
      );
      expect(
        ShipmentDraft.isOpen(today, const PickupTime(12, 0), now: now),
        isTrue,
      );
      expect(
        ShipmentDraft.isOpen(tomorrow, const PickupTime(8, 0), now: now),
        isTrue,
      );
    });

    test('switching to today drops a time that has already passed', () {
      final today = DateTime(2026, 11, 7);
      final morning = valid.withPickupDate(today, now: now); // was 08:00
      expect(morning.pickupDate, today);
      expect(morning.pickupTime, isNull);

      final afternoon = valid
          .copyWith(pickupTime: const PickupTime(15, 0))
          .withPickupDate(today, now: now);
      expect(afternoon.pickupTime, const PickupTime(15, 0));
    });

    test('a reopened draft loses a schedule that is now in the past', () {
      final stale = valid.copyWith(pickupDate: DateTime(2026, 11, 5));
      final cleaned = stale.withoutPastSchedule(now: now);
      expect(cleaned.pickupDate, isNull);
      expect(cleaned.pickupTime, isNull);
      expect(cleaned.description, valid.description);

      expect(valid.withoutPastSchedule(now: now).pickupAt, valid.pickupAt);
    });

    test('pickup more than 90 days ahead is rejected', () {
      final e = errorsOf(valid.copyWith(pickupDate: DateTime(2027, 3, 1)));
      expect(e[DraftField.pickupDate], contains('90 days'));
    });
  });

  group('weight', () {
    for (final (text, message) in [
      ('', 'Weight is required'),
      ('0', 'Weight must be greater than 0'),
      ('0.0', 'Weight must be greater than 0'),
      ('abc', 'Enter weight as a number'),
      ('1.2.3', 'Enter weight as a number'),
      ('150', 'Maximum 100 t per request'),
    ]) {
      test('"$text" → $message', () {
        expect(
          errorsOf(valid.copyWith(weightText: text))[DraftField.weight],
          message,
        );
      });
    }

    test('limits apply per unit (500 kg is fine, 150000 kg is not)', () {
      expect(
        errorsOf(valid.copyWith(weightText: '500', weightUnit: WeightUnit.kg)),
        isEmpty,
      );
      expect(
        errorsOf(
          valid.copyWith(weightText: '150000', weightUnit: WeightUnit.kg),
        )[DraftField.weight],
        isNotNull,
      );
    });
  });

  test('expected fare, when given, must be a positive amount', () {
    expect(
      errorsOf(valid.copyWith(fareText: '0'))[DraftField.expectedFare],
      isNotNull,
    );
    expect(errorsOf(valid.copyWith(fareText: '25,000')), isEmpty);
  });

  test('contact phone, when given, must be a Nepali mobile number', () {
    expect(
      errorsOf(valid.copyWith(contactPhone: '12345'))[DraftField.contactPhone],
      isNotNull,
    );
  });

  test('validateStep returns only that step\'s fields', () {
    const empty = ShipmentDraft();
    expect(empty.validateStep(DraftStep.cargo, now: now).keys.toSet(), {
      DraftField.category,
      DraftField.description,
      DraftField.weight,
    });
  });
}
