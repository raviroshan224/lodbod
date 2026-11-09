import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod/core/utils/formatters.dart';
import 'package:lodbod/core/utils/validators.dart';

void main() {
  group('login validation', () {
    test('phone', () {
      expect(Validators.phone(''), 'Phone number is required');
      expect(Validators.phone('12345'), isNotNull);
      expect(Validators.phone('9600000001'), isNotNull); // must start 97/98
      expect(Validators.phone('9800000001'), isNull);
      expect(Validators.phone('+977 98-0000-0001'), isNull);
    });

    test('email', () {
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('aarav@'), isNotNull);
      expect(Validators.email('aarav@example'), isNotNull);
      expect(Validators.email(' aarav@example.com '), isNull);
    });

    test('password', () {
      expect(Validators.password(''), 'Password is required');
      expect(
        Validators.password('short'),
        'Password must be at least 8 characters',
      );
      expect(Validators.password('Lodbod@123'), isNull);
    });

    test('phone numbers normalise for comparison', () {
      expect(Validators.normalizePhone('+977 9800000001'), '9800000001');
      expect(Validators.normalizePhone('977-980-000-0001'), '9800000001');
    });
  });

  group('formatting', () {
    test('sentence adds a full stop only when one is missing', () {
      expect(
        Fmt.sentence('Booked with Swift Transport'),
        'Booked with Swift Transport.',
      );
      expect(
        Fmt.sentence('Booked with Gandaki Transport Co.'),
        'Booked with Gandaki Transport Co.',
      );
      expect(Fmt.sentence('Done!'), 'Done!');
    });

    test('NPR uses South Asian digit grouping', () {
      expect(Fmt.npr(0), 'Rs. 0');
      expect(Fmt.npr(18000), 'Rs. 18,000');
      expect(Fmt.npr(750000), 'Rs. 7,50,000');
      expect(Fmt.npr(12500000), 'Rs. 1,25,00,000');
    });

    test('dates and weights', () {
      final d = DateTime(2026, 10, 14, 7, 5);
      expect(Fmt.dayMonth(d), '14 Oct');
      expect(Fmt.dateTime(d), '14 Oct 2026, 07:05');
      expect(Fmt.number(10), '10');
      expect(Fmt.number(2.5), '2.5');
    });
  });
}
