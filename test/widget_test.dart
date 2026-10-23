import 'package:flutter_test/flutter_test.dart';

import 'package:rizal_apps/app.dart';

void main() {
  testWidgets('halaman pembuka menampilkan identitas aplikasi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const RizalDocsApp());
    await tester.pump();

    expect(find.text('Rizal Docs'), findsOneWidget);
    expect(find.text('Repositori & Koleksi Dokumen'), findsOneWidget);
  });
}
