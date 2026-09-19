import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_pe/main.dart';

void main() {
  testWidgets('TrackPeApp starts and renders the wordmark', (tester) async {
    await tester.pumpWidget(const TrackPeApp());
    await tester.pump();

    // The app builds a MaterialApp titled "Track Pe".
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'Track Pe');

    // The logo wordmark splits into TRACK + PE.
    expect(find.text('TRACK'), findsWidgets);
    expect(find.text('PE'), findsWidgets);
  });

  testWidgets('Bottom navigation exposes the three primary tabs', (
    tester,
  ) async {
    await tester.pumpWidget(const TrackPeApp());
    await tester.pump();

    expect(find.text('POS Split'), findsOneWidget);
    expect(find.text('Group Split'), findsOneWidget);
    expect(find.text('MDR Roast'), findsOneWidget);
  });

  testWidgets('/privacy route renders the Privacy Policy page', (tester) async {
    await tester.pumpWidget(const TrackPeApp());
    await tester.pump();

    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.pushNamed('/privacy');
    await tester.pumpAndSettle();

    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Last Updated: September 2026'), findsOneWidget);
    expect(find.text('Contact'), findsWidgets);
  });
}
