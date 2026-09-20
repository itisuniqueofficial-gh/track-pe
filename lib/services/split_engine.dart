import 'dart:convert';
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
        .map((e) => '${e.key}=${_encodeUpiValue(e.value)}')
        .join('&');

    return 'upi://pay?$query';
  }

  /// Percent-encodes a single UPI query-parameter **value** exactly once.
  ///
  /// UPI apps read parameters like `pa` (the VPA) literally and frequently do
  /// NOT percent-decode them. Encoding the VPA separator `@` as `%40` (which
  /// [Uri.encodeComponent] and `Uri(queryParameters:)` both do) causes some
  /// apps to treat the address as e.g. `jaydatt%40pingpay` — a broken payee.
  ///
  /// Per RFC 3986, `@` is allowed unencoded in the query component, so we keep
  /// it literal. Everything outside the unreserved set (`A-Z a-z 0-9 - . _ ~`)
  /// plus `@` is percent-encoded from its UTF-8 bytes. Spaces therefore become
  /// `%20` (never `+`, which some UPI apps render literally), and `&`, `=`,
  /// `#`, `%`, and Unicode are encoded correctly. This runs once at
  /// serialization time; do not pre-encode values before calling this.
  static String _encodeUpiValue(String value) {
    final bytes = utf8.encode(value);
    final sb = StringBuffer();
    for (final b in bytes) {
      final isUnreserved =
          (b >= 0x30 && b <= 0x39) || // 0-9
          (b >= 0x41 && b <= 0x5A) || // A-Z
          (b >= 0x61 && b <= 0x7A) || // a-z
          b == 0x2D || // -
          b == 0x2E || // .
          b == 0x5F || // _
          b == 0x7E; // ~
      if (isUnreserved || b == 0x40) {
        // Unreserved characters and the VPA separator '@' stay literal.
        sb.writeCharCode(b);
      } else {
        sb.write('%');
        sb.write(b.toRadixString(16).toUpperCase().padLeft(2, '0'));
      }
    }
    return sb.toString();
  }

  /// Parses and validates a raw scanned UPI QR string using [UpiValidator].
  static Map<String, String> parseUpiUri(String rawData) {
    return UpiValidator.validate(rawData).toLegacyMap();
  }
}
