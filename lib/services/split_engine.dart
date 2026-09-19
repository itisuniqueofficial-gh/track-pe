import 'dart:math';
import '../models/split_order.dart';
import '../models/tranche.dart';
import '../utils/money.dart';
import 'upi_validator.dart';

/// Splits a bill into sub-threshold tranches.
///
/// All arithmetic is performed in integer paise so that the tranche amounts
/// always sum exactly to the requested total (no floating-point drift), and no
/// tranche can exceed the configured cap.
class SplitEngine {
  /// Default safe per-tranche cap: ₹1,999.00 (kept under the ₹2,000 threshold).
  static const int safeTrancheCapPaise = 199900;

  /// Minimum sensible tranche size: ₹10.00.
  static const int minTranchePaise = 1000;

  /// Distributes [totalPaise] across tranches, each `<= maxTranchePaise`,
  /// summing exactly to [totalPaise].
  ///
  /// When [randomize] is true and the total is a whole-rupee amount, interior
  /// tranches are chosen at random whole-rupee values for a natural look; the
  /// final tranche always absorbs the exact remainder.
  static List<int> calculateTranchePaise({
    required int totalPaise,
    int maxTranchePaise = safeTrancheCapPaise,
    bool randomize = true,
    Random? random,
  }) {
    if (totalPaise <= 0) return [];
    if (totalPaise <= maxTranchePaise) return [totalPaise];

    final rng = random ?? Random();
    final int count = (totalPaise + maxTranchePaise - 1) ~/ maxTranchePaise;
    final List<int> amounts = [];
    int remaining = totalPaise;

    for (int i = 0; i < count - 1; i++) {
      final remainingCount = count - 1 - i;

      // Bounds that keep every subsequent tranche within [min, max].
      final int minAllowed = max(
        minTranchePaise,
        remaining - remainingCount * maxTranchePaise,
      );
      final int maxAllowed = min(
        maxTranchePaise,
        remaining - remainingCount * minTranchePaise,
      );

      int picked;
      if (maxAllowed <= minAllowed) {
        picked = minAllowed;
      } else if (randomize) {
        // Prefer random whole-rupee values within the allowed band.
        final int minRupee = (minAllowed + 99) ~/ 100; // ceil to whole rupee
        final int maxRupee = maxAllowed ~/ 100; // floor to whole rupee
        if (maxRupee > minRupee) {
          picked = (minRupee + rng.nextInt(maxRupee - minRupee + 1)) * 100;
        } else {
          picked = minAllowed + rng.nextInt(maxAllowed - minAllowed + 1);
        }
      } else {
        // Deterministic: fill earlier tranches to the maximum allowed.
        picked = maxAllowed;
      }

      amounts.add(picked);
      remaining -= picked;
    }

    amounts.add(remaining); // exact remainder

    // Safety net: if any invariant was violated, fall back to a balanced split.
    final bool invalid =
        amounts.any((a) => a > maxTranchePaise || a <= 0) ||
        amounts.fold(0, (s, a) => s + a) != totalPaise;
    if (invalid) {
      amounts.clear();
      final int base = totalPaise ~/ count;
      int distributed = 0;
      for (int i = 0; i < count - 1; i++) {
        amounts.add(base);
        distributed += base;
      }
      amounts.add(totalPaise - distributed);
    }

    return amounts;
  }

  /// Creates a [SplitOrder] dividing [totalAmount] rupees into sub-threshold
  /// tranches. [totalAmount] is the input boundary and is converted to paise.
  static SplitOrder createTrancheOrder({
    required double totalAmount,
    required String merchantVpa,
    required String merchantName,
    String note = 'Track Pe Checkout',
    int maxTranchePaise = safeTrancheCapPaise,
    bool randomize = true,
  }) {
    final orderId =
        'ORD${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final int totalPaise = Money.rupeesToPaise(totalAmount);

    if (totalPaise <= 0) {
      return SplitOrder(
        orderId: orderId,
        merchantVpa: merchantVpa,
        merchantName: merchantName,
        totalAmountPaise: 0,
        note: note,
        tranches: const [],
        createdAt: DateTime.now(),
      );
    }

    final amounts = calculateTranchePaise(
      totalPaise: totalPaise,
      maxTranchePaise: maxTranchePaise,
      randomize: randomize,
    );

    final trancheCount = amounts.length;
    final tranches = <Tranche>[];
    for (int i = 0; i < trancheCount; i++) {
      final trancheAmt = amounts[i];
      final index = i + 1;
      final upiUri = buildUpiUri(
        vpa: merchantVpa,
        name: merchantName,
        amountPaise: trancheAmt,
        note: trancheCount == 1 ? note : '$note Tranche $index/$trancheCount',
      );
      tranches.add(
        Tranche(
          id: '${orderId}_$index',
          index: index,
          amountPaise: trancheAmt,
          upiUri: upiUri,
        ),
      );
    }

    return SplitOrder(
      orderId: orderId,
      merchantVpa: merchantVpa,
      merchantName: merchantName,
      totalAmountPaise: totalPaise,
      note: note,
      tranches: tranches,
      createdAt: DateTime.now(),
    );
  }

  /// Splits a bill evenly across [numberOfPeople], with the last share
  /// absorbing any rounding remainder so the shares sum exactly to the total.
  static SplitOrder createGroupSplitOrder({
    required double totalAmount,
    required int numberOfPeople,
    required String merchantVpa,
    required String merchantName,
    List<String>? friendNames,
    String note = 'Group Bill Split',
  }) {
    final orderId =
        'GRP${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';
    final int totalPaise = Money.rupeesToPaise(totalAmount);
    final int people = max(1, numberOfPeople);
    final int perPersonBase = totalPaise ~/ people;

    final tranches = <Tranche>[];
    int distributed = 0;
    for (int i = 0; i < people; i++) {
      final personName = (friendNames != null && i < friendNames.length)
          ? friendNames[i]
          : 'Friend #${i + 1}';

      final int amt = (i == people - 1)
          ? (totalPaise - distributed)
          : perPersonBase;
      distributed += amt;

      final upiUri = buildUpiUri(
        vpa: merchantVpa,
        name: merchantName,
        amountPaise: amt,
        note: '$note ($personName)',
      );

      tranches.add(
        Tranche(
          id: '${orderId}_${i + 1}',
          index: i + 1,
          amountPaise: amt,
          payerName: personName,
          upiUri: upiUri,
        ),
      );
    }

    return SplitOrder(
      orderId: orderId,
      merchantVpa: merchantVpa,
      merchantName: merchantName,
      totalAmountPaise: totalPaise,
      note: note,
      tranches: tranches,
      createdAt: DateTime.now(),
    );
  }

  /// Builds a standard NPCI UPI intent URI. [amountPaise] is formatted to an
  /// exact 2-decimal `am=` value with integer arithmetic.
  static String buildUpiUri({
    required String vpa,
    required String name,
    required int amountPaise,
    String? txnRef,
    required String note,
  }) {
    final params = <String, String>{
      'pa': vpa.trim(),
      if (name.trim().isNotEmpty) 'pn': name.trim(),
      'am': Money.amountString(amountPaise),
      'cu': 'INR',
      if (note.trim().isNotEmpty) 'tn': note.trim(),
    };

    if (txnRef != null && txnRef.trim().isNotEmpty) {
      params['tr'] = txnRef.trim();
    }

    final query = params.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');

    return 'upi://pay?$query';
  }

  /// Parses and validates a raw scanned UPI QR string using [UpiValidator].
  static Map<String, String> parseUpiUri(String rawData) {
    return UpiValidator.validate(rawData).toLegacyMap();
  }
}
