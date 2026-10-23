import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:rizal_apps/features/documents/widgets/document_card.dart';
import 'package:rizal_apps/main.dart' as app;

/// Pengujian end-to-end alur utama aplikasi:
/// registrasi -> login -> detail & favorit -> tab favorit -> tambah dokumen
/// -> ubah dokumen -> hapus dokumen.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Menjalankan aksi tombol FilledButton secara langsung.
  ///
  /// Dipakai untuk tombol yang berada di dalam area scroll agar pengujian tidak
  /// bergantung pada posisi scroll maupun hit-testing pada perangkat.
  Future<void> pressFilledButton(WidgetTester tester, String label) async {
    final Finder finder = find.widgetWithText(FilledButton, label);
    final FilledButton button = tester.widget<FilledButton>(finder);
    expect(button.onPressed, isNotNull);
    button.onPressed!();
    await tester.pumpAndSettle();
  }

  testWidgets('alur registrasi, login, favorit, dan CRUD dokumen', (
    WidgetTester tester,
  ) async {
    final String unique = DateTime.now().millisecondsSinceEpoch.toString();
    final String username = 'rizal$unique';

    await app.main();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // --- Registrasi ---------------------------------------------------------
    await tester.tap(find.text('Registrasi Akun Baru'));
    await tester.pumpAndSettle();

    final Finder registerFields = find.byType(TextFormField);
    await tester.enterText(registerFields.at(0), 'Rizal Suryawan');
    await tester.enterText(registerFields.at(1), username);
    await tester.enterText(registerFields.at(2), 'rizal123');
    await tester.enterText(registerFields.at(3), 'rizal123');
    await pressFilledButton(tester, 'Daftar');

    // Kembali ke halaman login setelah registrasi berhasil.
    expect(find.text('Masuk ke Akun'), findsOneWidget);

    // --- Login --------------------------------------------------------------
    final Finder loginFields = find.byType(TextFormField);
    await tester.enterText(loginFields.at(0), username);
    await tester.enterText(loginFields.at(1), 'rizal123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('Login berhasil'), findsOneWidget);

    await tester.pumpAndSettle();

    // --- Dashboard ----------------------------------------------------------
    expect(find.text('Koleksi Dokumen'), findsOneWidget);
    expect(find.text('Halo, Rizal Suryawan'), findsOneWidget);

    // --- Detail & favorit ---------------------------------------------------
    await tester.tap(find.byType(DocumentCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Deskripsi'), findsOneWidget);

    await tester.tap(find.text('Tambah ke Favorit'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('Ya')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(
      find.text('Dokumen berhasil ditambahkan ke favorit'),
      findsOneWidget,
    );
    expect(find.text('Hapus dari Favorit'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    // --- Tab favorit --------------------------------------------------------
    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.favorite_border_rounded),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Favorit Saya'), findsOneWidget);
    expect(find.byType(DocumentCard), findsWidgets);

    // --- Menu pengaturan: create -------------------------------------------
    await tester.tap(
      find.descendant(
        of: find.byType(BottomNavigationBar),
        matching: find.byIcon(Icons.settings_outlined),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Dokumen'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, 'Tambah Dokumen'));
    await tester.pumpAndSettle();

    final Finder formFields = find.byType(TextFormField);
    await tester.enterText(formFields.at(0), 'Dokumen Uji Otomatis');
    await tester.enterText(formFields.at(1), 'Rizal Suryawan');
    await tester.enterText(formFields.at(2), '2025');
    await tester.enterText(
      formFields.at(3),
      'Dokumen ini dibuat otomatis oleh integration test.',
    );

    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Dokumen Uji Otomatis'), findsOneWidget);

    // --- Menu pengaturan: update -------------------------------------------
    await tester.tap(find.text('Dokumen Uji Otomatis'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Dokumen'), findsOneWidget);

    final Finder editFields = find.byType(TextFormField);
    await tester.enterText(editFields.at(0), 'Dokumen Uji Diperbarui');
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();

    expect(find.text('Dokumen Uji Diperbarui'), findsOneWidget);
    expect(find.text('Dokumen Uji Otomatis'), findsNothing);

    // --- Menu pengaturan: delete -------------------------------------------
    final Finder updatedTile = find.ancestor(
      of: find.text('Dokumen Uji Diperbarui'),
      matching: find.byType(ListTile),
    );

    await tester.tap(
      find.descendant(
        of: updatedTile,
        matching: find.byType(PopupMenuButton<String>),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(AlertDialog), matching: find.text('Ya')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Dokumen Uji Diperbarui'), findsNothing);
  });
}
