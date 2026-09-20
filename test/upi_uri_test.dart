import 'package:flutter_test/flutter_test.dart';
import 'package:track_pe/services/split_engine.dart';

void main() {
  group('UPI URI encoding — buildUpiUri', () {
    test('REGRESSION: VPA @ stays literal (never %40 or %2540)', () {
      final uri = SplitEngine.buildUpiUri(
        vpa: 'jaydatt@pingpay',
        name: 'Jaydatt Khodave',
        amountPaise: 103500,
        note: 'Track Pe Checkout',
      );

      // The reported bug: pa must not become jaydatt%40pingpay.
      expect(uri.contains('pa=jaydatt@pingpay'), isTrue, reason: uri);
      expect(uri.contains('%40'), isFalse, reason: 'no percent-encoded @');
      expect(uri.contains('%2540'), isFalse, reason: 'no double-encoding');

      // And it must parse back to the exact semantic VPA.
      final parsed = Uri.parse(uri);
      expect(parsed.scheme, 'upi');
      expect(parsed.queryParameters['pa'], 'jaydatt@pingpay');
      expect(parsed.queryParameters['am'], '1035.00');
      expect(parsed.queryParameters['cu'], 'INR');
    });

    test('spaces encode as %20, never +', () {
      final uri = SplitEngine.buildUpiUri(
        vpa: 'store@okhdfcbank',
        name: 'Jaydatt Khodave',
        amountPaise: 100000,
        note: 'Bill 1/2',
      );
      expect(uri.contains('pn=Jaydatt%20Khodave'), isTrue, reason: uri);
      expect(uri.contains('+'), isFalse, reason: 'no + for space');
      expect(Uri.parse(uri).queryParameters['pn'], 'Jaydatt Khodave');
    });

    test('special characters in payee name encode once and round-trip', () {
      for (final name in <String>[
        'Jaydatt & Friends',
        "Jaydatt's Store",
        'A&B Store',
        'Store 100%',
        'मराठी दुकान',
        'हिंदी स्टोर',
      ]) {
        final uri = SplitEngine.buildUpiUri(
          vpa: 'store@okhdfcbank',
          name: name,
          amountPaise: 199900,
          note: 'x',
        );
        final parsed = Uri.parse(uri);
        expect(
          parsed.queryParameters['pn'],
          name,
          reason: 'name=$name uri=$uri',
        );
        expect(parsed.queryParameters['pa'], 'store@okhdfcbank');
        expect(uri.contains('%2540'), isFalse);
        // '&' inside the name must be encoded so it is not a param separator.
        if (name.contains('&')) {
          expect(uri.contains('%26'), isTrue, reason: uri);
        }
      }
    });

    test('various amounts serialize exactly', () {
      final expected = <int, String>{
        100: '1.00',
        1000: '10.00',
        9999: '99.99',
        103500: '1035.00',
        199900: '1999.00',
      };
      expected.forEach((paise, str) {
        final uri = SplitEngine.buildUpiUri(
          vpa: 'store@okhdfcbank',
          name: 'S',
          amountPaise: paise,
          note: 'x',
        );
        expect(Uri.parse(uri).queryParameters['am'], str);
      });
    });

    test('generated URI is a valid upi://pay intent that parses', () {
      final uri = SplitEngine.buildUpiUri(
        vpa: 'jaydatt@pingpay',
        name: 'Jaydatt Khodave',
        amountPaise: 103500,
        note: 'Track Pe',
      );
      final parsed = Uri.parse(uri);
      expect(parsed.scheme, 'upi');
      expect(parsed.host, 'pay');
      expect(uri.startsWith('upi://pay?'), isTrue);
    });
  });

  group('Canonical URI is shared by all consumers', () {
    test(
      'POS tranche order tranches carry literal-@ UPI URIs from buildUpiUri',
      () {
        final order = SplitEngine.createTrancheOrder(
          totalAmount: 3850,
          merchantVpa: 'jaydatt@pingpay',
          merchantName: 'Jaydatt Khodave',
          randomize: false,
        );
        expect(order.tranches, isNotEmpty);
        for (final t in order.tranches) {
          // Same builder → QR (renders t.upiUri), copy, share, and pay all use this.
          expect(
            t.upiUri.contains('pa=jaydatt@pingpay'),
            isTrue,
            reason: t.upiUri,
          );
          expect(t.upiUri.contains('%40'), isFalse);
          final p = Uri.parse(t.upiUri);
          expect(p.queryParameters['pa'], 'jaydatt@pingpay');
        }
      },
    );

    test('group split shares also use literal-@ canonical URIs', () {
      final order = SplitEngine.createGroupSplitOrder(
        totalAmount: 100,
        numberOfPeople: 3,
        merchantVpa: 'jaydatt@pingpay',
        merchantName: 'Jaydatt Khodave',
      );
      for (final t in order.tranches) {
        expect(Uri.parse(t.upiUri).queryParameters['pa'], 'jaydatt@pingpay');
        expect(t.upiUri.contains('%40'), isFalse);
      }
    });
  });
}
