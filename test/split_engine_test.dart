import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_pe/services/split_engine.dart';

void main() {
  int sum(List<int> xs) => xs.fold(0, (a, b) => a + b);

  group('SplitEngine.calculateTranchePaise', () {
    test('returns empty for zero / negative totals', () {
      expect(SplitEngine.calculateTranchePaise(totalPaise: 0), isEmpty);
      expect(SplitEngine.calculateTranchePaise(totalPaise: -100), isEmpty);
    });

    test('small amount below cap yields a single tranche', () {
      final r = SplitEngine.calculateTranchePaise(totalPaise: 50000); // ₹500
      expect(r, [50000]);
    });

    test('exactly ₹1,999 stays a single tranche', () {
      final r = SplitEngine.calculateTranchePaise(totalPaise: 199900);
      expect(r, [199900]);
    });

    test('₹2,000 splits into two sub-cap tranches summing exactly', () {
      final r = SplitEngine.calculateTranchePaise(totalPaise: 200000);
      expect(r.length, greaterThanOrEqualTo(2));
      expect(sum(r), 200000);
      expect(r.every((p) => p <= SplitEngine.safeTrancheCapPaise), isTrue);
      expect(r.every((p) => p > 0), isTrue);
    });

    test(
      'large amount preserves exact sum, respects cap, no zero/negative',
      () {
        // Deterministic RNG for reproducibility.
        final rng = Random(42);
        for (final total in [680000, 750000, 1234567, 9999999, 5000000]) {
          final r = SplitEngine.calculateTranchePaise(
            totalPaise: total,
            random: rng,
          );
          expect(sum(r), total, reason: 'sum must equal total for $total');
          expect(
            r.every((p) => p <= SplitEngine.safeTrancheCapPaise),
            isTrue,
            reason: 'no tranche may exceed cap for $total',
          );
          expect(
            r.every((p) => p > 0),
            isTrue,
            reason: 'no zero/negative tranche for $total',
          );
          final expectedCount =
              (total + SplitEngine.safeTrancheCapPaise - 1) ~/
              SplitEngine.safeTrancheCapPaise;
          expect(r.length, expectedCount);
        }
      },
    );

    test('deterministic (non-random) mode preserves exact sum and cap', () {
      final r = SplitEngine.calculateTranchePaise(
        totalPaise: 680000,
        randomize: false,
      );
      expect(sum(r), 680000);
      expect(r.every((p) => p <= SplitEngine.safeTrancheCapPaise), isTrue);
      expect(r.every((p) => p > 0), isTrue);
    });
  });

  group('SplitEngine.createTrancheOrder', () {
    test('converts rupees at boundary; tranches sum exactly in paise', () {
      final order = SplitEngine.createTrancheOrder(
        totalAmount: 7500,
        merchantVpa: 'store@okhdfcbank',
        merchantName: 'Test Store',
        randomize: false,
      );
      expect(order.totalAmountPaise, 750000);
      expect(order.tranches.fold(0, (s, t) => s + t.amountPaise), 750000);
      expect(order.tranches.every((t) => t.amountPaise <= 199900), isTrue);
      // Each tranche encodes a well-formed UPI URI with an exact am= value.
      for (final t in order.tranches) {
        expect(t.upiUri.startsWith('upi://pay?'), isTrue);
        expect(t.upiUri.contains('cu=INR'), isTrue);
      }
    });

    test('handles fractional rupee totals without float drift', () {
      final order = SplitEngine.createTrancheOrder(
        totalAmount: 2000.05,
        merchantVpa: 'store@okhdfcbank',
        merchantName: 'Test Store',
      );
      expect(order.totalAmountPaise, 200005);
      expect(order.tranches.fold(0, (s, t) => s + t.amountPaise), 200005);
    });

    test('zero total produces an empty order', () {
      final order = SplitEngine.createTrancheOrder(
        totalAmount: 0,
        merchantVpa: 'store@okhdfcbank',
        merchantName: 'Test Store',
      );
      expect(order.tranches, isEmpty);
      expect(order.totalAmountPaise, 0);
    });
  });

  group('SplitEngine.createGroupSplitOrder', () {
    test('splits evenly with exact remainder on the last share', () {
      final order = SplitEngine.createGroupSplitOrder(
        totalAmount: 100,
        numberOfPeople: 3,
        merchantVpa: 'restaurant@okhdfcbank',
        merchantName: 'Bistro',
      );
      expect(order.tranches.length, 3);
      expect(order.tranches.fold(0, (s, t) => s + t.amountPaise), 10000);
      // 10000 / 3 -> 3333, 3333, 3334
      expect(order.tranches[0].amountPaise, 3333);
      expect(order.tranches[2].amountPaise, 3334);
    });
  });

  group('SplitEngine.buildUpiUri', () {
    test('formats amount exactly and encodes params', () {
      final uri = SplitEngine.buildUpiUri(
        vpa: 'store@okhdfcbank',
        name: 'Corner Shop',
        amountPaise: 199900,
        note: 'Bill 1/2',
      );
      expect(uri.contains('pa=store@okhdfcbank'), isTrue);
      expect(uri.contains('%40'), isFalse);
      expect(uri.contains('am=1999.00'), isTrue);
      expect(uri.contains('cu=INR'), isTrue);
    });
  });
}
