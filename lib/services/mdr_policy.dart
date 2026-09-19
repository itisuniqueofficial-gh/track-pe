/// Illustrative MDR / GST policy used by Track Pe's calculators.
///
/// IMPORTANT: These rates and thresholds are **illustrative educational
/// assumptions only**. They are NOT an authoritative or current statement of
/// NPCI, RBI, or CBIC policy. Merchant Discount Rate (MDR) rules, GST rates,
/// and exemption thresholds change over time and vary by transaction type.
/// Users must verify current figures with official sources before relying on
/// any number produced by this app.
///
/// All computation is performed in integer paise to avoid floating-point
/// rounding errors.
class MdrPolicy {
  const MdrPolicy._();

  /// Illustrative threshold at/under which the app assumes 0% MDR (₹2,000).
  static const int mdrThresholdPaise = 200000;

  /// Illustrative base MDR rate applied above the threshold (0.4%).
  static const double baseMdrRate = 0.004;

  /// Illustrative cap on base MDR (₹300).
  static const int mdrCapPaise = 30000;

  /// Illustrative GST rate levied on the MDR service fee (18%).
  static const double gstRate = 0.18;

  /// Base MDR (in paise) for a single transaction of [amountPaise].
  ///
  /// Returns 0 when the amount is at or below the illustrative threshold.
  static int baseMdrOnAmount(int amountPaise) {
    if (amountPaise <= mdrThresholdPaise) return 0;
    final fee = (amountPaise * baseMdrRate).round();
    return fee > mdrCapPaise ? mdrCapPaise : fee;
  }

  /// GST (in paise) levied on a given MDR amount.
  static int gstOnMdr(int mdrPaise) => (mdrPaise * gstRate).round();

  /// Total illustrative surcharge (base MDR + GST) for [amountPaise].
  static int totalFeeOnAmount(int amountPaise) {
    final mdr = baseMdrOnAmount(amountPaise);
    return mdr + gstOnMdr(mdr);
  }

  /// Base MDR (in paise) on a monthly turnover, assuming the average bill size
  /// is above the exemption threshold (otherwise 0). Used by the estimator.
  static int monthlyBaseMdr({
    required int turnoverPaise,
    required int avgBillPaise,
  }) {
    if (avgBillPaise <= mdrThresholdPaise) return 0;
    return (turnoverPaise * baseMdrRate).round();
  }
}
