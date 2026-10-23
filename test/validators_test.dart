import 'package:flutter_test/flutter_test.dart';

import 'package:rizal_apps/core/utils/validators.dart';

void main() {
  group('AppValidators', () {
    test('nama wajib diisi dan minimal 3 karakter', () {
      expect(AppValidators.nama(null), 'Nama lengkap tidak boleh kosong');
      expect(AppValidators.nama('   '), 'Nama lengkap tidak boleh kosong');
      expect(AppValidators.nama('Ri'), 'Nama lengkap minimal 3 karakter');
      expect(AppValidators.nama('Rizal Suryawan'), isNull);
    });

    test('username wajib diisi', () {
      expect(AppValidators.username(''), 'Username tidak boleh kosong');
      expect(AppValidators.username('   '), 'Username tidak boleh kosong');
      expect(AppValidators.username('rizal'), isNull);
    });

    test('password wajib diisi dan minimal 6 karakter', () {
      expect(AppValidators.password(''), 'Password tidak boleh kosong');
      expect(AppValidators.password('12345'), 'Password minimal 6 karakter');
      expect(AppValidators.password('123456'), isNull);
    });

    test('konfirmasi password harus sama', () {
      expect(
        AppValidators.konfirmasiPassword('', 'rizal123'),
        'Konfirmasi password tidak boleh kosong',
      );
      expect(
        AppValidators.konfirmasiPassword('salah', 'rizal123'),
        'Konfirmasi password tidak sesuai',
      );
      expect(AppValidators.konfirmasiPassword('rizal123', 'rizal123'), isNull);
    });

    test('tahun harus berupa angka yang masuk akal', () {
      expect(AppValidators.tahun(''), 'Tahun tidak boleh kosong');
      expect(AppValidators.tahun('dua ribu'), 'Tahun harus berupa angka');
      expect(
        AppValidators.tahun('1800'),
        'Tahun harus di antara 1900 dan 2100',
      );
      expect(AppValidators.tahun('2025'), isNull);
    });

    test('requiredField memakai label pada pesan error', () {
      expect(
        AppValidators.requiredField('', 'Judul'),
        'Judul tidak boleh kosong',
      );
      expect(AppValidators.requiredField('Basis Data', 'Judul'), isNull);
    });
  });
}
