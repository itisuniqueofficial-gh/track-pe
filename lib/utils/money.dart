import 'package:intl/intl.dart';

/// Money helpers for Track Pe.
///
/// All monetary values are handled internally as **integer paise**
/// (`₹1 = 100 paise`) to avoid floating-point precision errors in totals,
/// tranche distribution, and fee calculations. Conversion to decimal / string
/// happens only at presentation boundaries via the helpers below.
class Money {
  const Money._();

  /// Converts a rupee amount (user input / slider value) into integer paise.
  ///
  /// Rounds to the nearest paise to absorb floating-point representation error
  /// (e.g. `19.99 * 100 == 1998.9999...`).
  static int rupeesToPaise(num rupees) => (rupees * 100).round();

  /// Parses free-form user input (e.g. "6800", "1,999.50", "₹250") into paise.
  ///
  /// Returns `null` when the input does not contain a valid non-negative number.
  static int? tryParsePaise(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '').trim();
    if (cleaned.isEmpty) return null;
    final value = double.tryParse(cleaned);
    if (value == null || value.isNaN || value.isInfinite || value < 0) {
      return null;
    }
    return rupeesToPaise(value);
  }

  /// Exact 2-decimal string for a paise value, e.g. `199900 -> "1999.00"`.
  ///
  /// Built with pure integer arithmetic (no float) so it is safe for UPI
  /// `am=` parameters and precise displays.
  static String amountString(int paise) {
    final sign = paise < 0 ? '-' : '';
    final abs = paise.abs();
    final rupees = abs ~/ 100;
    final fraction = abs % 100;
    return '$sign$rupees.${fraction.toString().padLeft(2, '0')}';
  }

  /// Rounded whole-rupee string, e.g. `680050 -> "6801"`. Used for compact
  /// "settled ₹X" style messages.
  static String wholeRupees(int paise) {
    final sign = paise < 0 ? '-' : '';
    final rounded = (paise.abs() + 50) ~/ 100;
    return '$sign$rounded';
  }

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  /// Locale-grouped INR string with the ₹ symbol, e.g. `150000000 -> "₹15,00,000"`.
  /// Presentation boundary only.
  static String formatInr(int paise) => _inrFormat.format(paise / 100);
}
