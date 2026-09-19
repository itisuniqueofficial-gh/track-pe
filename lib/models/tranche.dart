enum TrancheStatus { pending, inProgress, paid, failed }

/// A single sub-payment ("tranche") within a [SplitOrder].
///
/// The monetary value is stored as integer paise ([amountPaise]) to guarantee
/// exact sums; [amount] is a display-only convenience getter.
class Tranche {
  final String id;
  final int index;
  final int amountPaise;
  final String upiUri;
  final String? payerName;
  TrancheStatus status;
  DateTime? paidAt;
  String? txnRef;

  Tranche({
    required this.id,
    required this.index,
    required this.amountPaise,
    required this.upiUri,
    this.payerName,
    this.status = TrancheStatus.pending,
    this.paidAt,
    this.txnRef,
  });

  /// Display-only rupee value. Do not use for arithmetic; use [amountPaise].
  double get amount => amountPaise / 100.0;

  bool get isPaid => status == TrancheStatus.paid;

  Tranche copyWith({
    String? id,
    int? index,
    int? amountPaise,
    String? upiUri,
    String? payerName,
    TrancheStatus? status,
    DateTime? paidAt,
    String? txnRef,
  }) {
    return Tranche(
      id: id ?? this.id,
      index: index ?? this.index,
      amountPaise: amountPaise ?? this.amountPaise,
      upiUri: upiUri ?? this.upiUri,
      payerName: payerName ?? this.payerName,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      txnRef: txnRef ?? this.txnRef,
    );
  }
}
