import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rizal_apps/app.dart';
import 'package:rizal_apps/features/auth/login_page.dart';

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

  testWidgets('form login menampilkan pesan validasi saat kosong', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    final Finder submitButton = find.widgetWithText(FilledButton, 'Masuk');
    await tester.ensureVisible(submitButton);
    await tester.pumpAndSettle();

    // Memanggil aksi tombol secara langsung agar pengujian tidak bergantung
    // pada posisi scroll halaman.
    final FilledButton button = tester.widget<FilledButton>(submitButton);
    button.onPressed!();
    await tester.pump();

    expect(find.text('Username tidak boleh kosong'), findsOneWidget);
    expect(find.text('Password tidak boleh kosong'), findsOneWidget);
  });
}
