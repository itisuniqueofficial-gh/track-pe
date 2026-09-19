import 'package:flutter_test/flutter_test.dart';
import 'package:track_pe/models/split_order.dart';
import 'package:track_pe/models/tranche.dart';
import 'package:track_pe/services/mdr_policy.dart';

void main() {
  group('MdrPolicy (integer paise)', () {
    test('no MDR at or below the threshold', () {
      expect(MdrPolicy.baseMdrOnAmount(200000), 0); // ₹2,000
      expect(MdrPolicy.baseMdrOnAmount(50000), 0); // ₹500
    });

    test('0.4% base MDR above threshold', () {
      expect(MdrPolicy.baseMdrOnAmount(750000), 3000); // ₹30 on ₹7,500
    });

    test('base MDR is capped at ₹300', () {
      expect(
        MdrPolicy.baseMdrOnAmount(10000000),
        30000,
      ); // ₹100,000 -> cap ₹300
    });

    test('18% GST on MDR', () {
      expect(MdrPolicy.gstOnMdr(3000), 540); // ₹5.40 on ₹30
    });

    test('total fee = MDR + GST', () {
      expect(MdrPolicy.totalFeeOnAmount(750000), 3540); // ₹35.40
    });
  });

  group('SplitOrder getters & status transitions', () {
    SplitOrder buildOrder() => SplitOrder(
      orderId: 'ORD1',
      merchantVpa: 'store@okhdfcbank',
      merchantName: 'Store',
      totalAmountPaise: 750000,
      note: 'test',
      createdAt: DateTime(2024),
      tranches: [
        Tranche(
          id: 'a',
          index: 1,
          amountPaise: 250000,
          upiUri: 'upi://pay?pa=store@okhdfcbank&am=2500.00',
        ),
        Tranche(
          id: 'b',
          index: 2,
          amountPaise: 250000,
          upiUri: 'upi://pay?pa=store@okhdfcbank&am=2500.00',
        ),
        Tranche(
          id: 'c',
          index: 3,
          amountPaise: 250000,
          upiUri: 'upi://pay?pa=store@okhdfcbank&am=2500.00',
        ),
      ],
    );

    test('exposes illustrative MDR/GST/savings in both paise and rupees', () {
      final o = buildOrder();
      expect(o.mdrStandardPaise, 3000);
      expect(o.gstOnMdrPaise, 540);
      expect(o.totalStandardFeePaise, 3540);
      expect(o.mdrWithTrackPePaise, 0);
      expect(o.mdrSavingsPaise, 3540);
      expect(o.mdrSavings, closeTo(35.40, 1e-9));
      expect(o.totalAmount, 7500.0);
    });

    test('progress updates as tranches are paid; exact paise accounting', () {
      final o = buildOrder();
      expect(o.paidAmountPaise, 0);
      expect(o.progress, 0.0);
      expect(o.isFullyPaid, isFalse);
      expect(o.currentPendingTranche?.id, 'a');

      o.tranches[0].status = TrancheStatus.paid;
      expect(o.paidAmountPaise, 250000);
      expect(o.remainingAmountPaise, 500000);
      expect(o.progress, closeTo(1 / 3, 1e-9));
      expect(o.currentPendingTranche?.id, 'b');

      for (final t in o.tranches) {
        t.status = TrancheStatus.paid;
      }
      expect(o.isFullyPaid, isTrue);
      expect(o.remainingAmountPaise, 0);
      expect(o.currentPendingTranche, isNull);
    });
  });
}
