import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rizal_apps/app.dart';

void main() {
  testWidgets('splash screen berlanjut ke halaman login', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RizalDocsApp());

    expect(find.text('Repositori & Koleksi Dokumen'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1700));
    await tester.pumpAndSettle();

    expect(find.text('Masuk ke Akun'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Masuk'), findsOneWidget);
  });
}
