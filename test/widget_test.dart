import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/todo.dart';
import 'package:flutter_application_1/providers/task_draft_provider.dart';
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

    test('membaca kolom baru Praktikum 10 (foto, lokasi, deskripsi)', () {
      final todo = Todo.fromMap({
        'id': 'x1',
        'title': 'Tugas bersensor',
        'is_done': false,
        'created_at': '2026-11-13T01:00:00.000Z',
        'description': 'Integrasi kamera dan GPS',
        'photo_url': 'https://example.supabase.co/storage/v1/object/public/todo-photos/u/1.jpg',
        'latitude': -6.2,
        'longitude': 106.816666,
      });

      expect(todo.description, 'Integrasi kamera dan GPS');
      expect(todo.hasPhoto, isTrue);
      expect(todo.hasLocation, isTrue);
      expect(todo.latitude, -6.2);
      expect(todo.longitude, closeTo(106.8167, 0.001));
    });

    test('baris lama tanpa kolom baru tetap valid (backward compatible)', () {
      final todo = Todo.fromMap({
        'id': 'x2',
        'title': 'Tugas lama',
        'is_done': false,
        'created_at': '2026-11-06T01:00:00.000Z',
      });

      expect(todo.hasPhoto, isFalse);
      expect(todo.hasLocation, isFalse);
      expect(todo.description, isNull);
    });
  });

  group('TaskDraftProvider', () {
    test('menolak submit tanpa judul tanpa menyentuh jaringan', () async {
      final draft = TaskDraftProvider();

      final error = await draft.submit(title: '   ');

      expect(error, 'Judul tugas wajib diisi.');
      expect(draft.submitting, isFalse);
      expect(draft.hasPhoto, isFalse);
      expect(draft.hasLocation, isFalse);
    });

    test('menolak judul lebih dari 200 karakter', () async {
      final draft = TaskDraftProvider();

      final error = await draft.submit(title: 'a' * 201);

      expect(error, 'Judul tugas maksimal 200 karakter.');
    });

    test('reset mengosongkan draft', () {
      final draft = TaskDraftProvider();

      draft.reset();

      expect(draft.hasPhoto, isFalse);
      expect(draft.hasLocation, isFalse);
      expect(draft.capturingPhoto, isFalse);
      expect(draft.locating, isFalse);
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
