import 'package:flutter_test/flutter_test.dart';
import 'package:track_pe/utils/money.dart';

void main() {
  group('Money.rupeesToPaise', () {
    test('rounds to nearest paise, absorbing float error', () {
      expect(Money.rupeesToPaise(19.99), 1999);
      expect(Money.rupeesToPaise(2000), 200000);
      expect(Money.rupeesToPaise(0.1), 10);
      expect(
        Money.rupeesToPaise(1234.565),
        123457,
      ); // .565 -> 123456.5 -> 123457
    });
  });

  group('Money.tryParsePaise', () {
    test('parses plain and formatted input', () {
      expect(Money.tryParsePaise('6800'), 680000);
      expect(Money.tryParsePaise('1,999.50'), 199950);
      expect(Money.tryParsePaise('₹250'), 25000);
    });

    test('returns null for invalid input', () {
      expect(Money.tryParsePaise(''), isNull);
      expect(Money.tryParsePaise('abc'), isNull);
    });
  });

  group('Money.amountString', () {
    test('formats paise with exact two decimals (no float)', () {
      expect(Money.amountString(199900), '1999.00');
      expect(Money.amountString(5), '0.05');
      expect(Money.amountString(100000), '1000.00');
      expect(Money.amountString(123456), '1234.56');
    });
  });

  group('Money.wholeRupees', () {
    test('rounds to nearest whole rupee', () {
      expect(Money.wholeRupees(680000), '6800');
      expect(Money.wholeRupees(680050), '6801');
    });
  });
}
