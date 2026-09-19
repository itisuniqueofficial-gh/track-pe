import '../services/mdr_policy.dart';
import 'tranche.dart';

/// An order that has been divided into one or more [Tranche]s.
///
/// Monetary values are stored as integer paise ([totalAmountPaise]); the
/// `double` getters ([totalAmount], [mdrSavings], ...) are display-only
/// conveniences derived at the presentation boundary.
class SplitOrder {
  final String orderId;
  final String merchantVpa;
  final String merchantName;
  final int totalAmountPaise;
  final String note;
  final List<Tranche> tranches;
  final DateTime createdAt;

  SplitOrder({
    required this.orderId,
    required this.merchantVpa,
    required this.merchantName,
    required this.totalAmountPaise,
    required this.note,
    required this.tranches,
    required this.createdAt,
  });

  double get totalAmount => totalAmountPaise / 100.0;

  int get paidAmountPaise =>
      tranches.where((t) => t.isPaid).fold(0, (sum, t) => sum + t.amountPaise);

  double get paidAmount => paidAmountPaise / 100.0;

  int get remainingAmountPaise =>
      (totalAmountPaise - paidAmountPaise).clamp(0, totalAmountPaise);

  double get remainingAmount => remainingAmountPaise / 100.0;

  double get progress =>
      totalAmountPaise == 0 ? 0.0 : paidAmountPaise / totalAmountPaise;

  bool get isFullyPaid =>
      tranches.isNotEmpty && tranches.every((t) => t.isPaid);

  // --- Illustrative MDR / GST figures (see [MdrPolicy] for disclaimer) ---

  /// Illustrative base MDR (paise) if the full amount were paid in one go.
  int get mdrStandardPaise => MdrPolicy.baseMdrOnAmount(totalAmountPaise);
  double get mdrStandard => mdrStandardPaise / 100.0;

  /// Illustrative 18% GST (paise) on the base MDR.
  int get gstOnMdrPaise => MdrPolicy.gstOnMdr(mdrStandardPaise);
  double get gstOnMdr => gstOnMdrPaise / 100.0;

  /// Illustrative total surcharge (paise): base MDR + GST.
  int get totalStandardFeePaise => mdrStandardPaise + gstOnMdrPaise;
  double get totalStandardFee => totalStandardFeePaise / 100.0;

  /// With per-tranche amounts kept at/under the threshold, the illustrative
  /// MDR is zero.
  int get mdrWithTrackPePaise => 0;
  double get mdrWithTrackPe => 0.0;

  /// Illustrative surcharge avoided (paise).
  int get mdrSavingsPaise => totalStandardFeePaise - mdrWithTrackPePaise;
  double get mdrSavings => mdrSavingsPaise / 100.0;

  Tranche? get currentPendingTranche {
    try {
      return tranches.firstWhere((t) => !t.isPaid);
    } catch (_) {
      return null;
    }
  }
}
