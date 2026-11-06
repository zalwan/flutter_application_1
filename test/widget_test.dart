import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/utils/validators.dart';

void main() {
  group('validateEmail', () {
    test('menolak email kosong', () {
      expect(validateEmail(''), 'Email wajib diisi.');
      expect(validateEmail('   '), 'Email wajib diisi.');
    });

    test('menolak format email yang salah', () {
      expect(validateEmail('bukan-email'), 'Format email tidak valid.');
      expect(validateEmail('user@'), 'Format email tidak valid.');
    });

    test('menerima email yang valid', () {
      expect(validateEmail('user@example.com'), isNull);
      expect(validateEmail('user.name+todo@example.co.id'), isNull);
    });
  });

  group('validatePassword', () {
    test('menolak password kosong', () {
      expect(validatePassword(''), 'Password wajib diisi.');
    });

    test('menolak password kurang dari 6 karakter', () {
      expect(validatePassword('12345'), 'Password minimal 6 karakter.');
    });

    test('menerima password minimal 6 karakter', () {
      expect(validatePassword('123456'), isNull);
    });
  });

  group('Todo.fromMap', () {
    test('membaca baris tabel todos dari Supabase', () {
      final todo = Todo.fromMap({
        'id': 'a1b2c3',
        'title': 'Belajar Flutter',
        'is_done': true,
        'created_at': '2026-11-06T01:30:00.000Z',
      });

      expect(todo.id, 'a1b2c3');
      expect(todo.title, 'Belajar Flutter');
      expect(todo.isDone, isTrue);
      expect(todo.formattedDate, '06/11/2026');
    });
  });

  testWidgets('LoginScreen menampilkan pesan validasi saat form kosong', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    await tester.ensureVisible(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi.'), findsOneWidget);
    expect(find.text('Password wajib diisi.'), findsOneWidget);
  });

  testWidgets('LoginScreen dapat membuka halaman daftar akun', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));

    final registerLink = find.text('Belum punya akun? Daftar di sini');
    await tester.ensureVisible(registerLink);
    await tester.tap(registerLink);
    await tester.pumpAndSettle();

    expect(find.byType(RegisterScreen), findsOneWidget);
    expect(find.text('Daftar Akun'), findsOneWidget);
  });
}
