/// Kumpulan validator form yang dipakai pada halaman login dan registrasi.
///
/// Dipisahkan dari widget agar mudah diuji dan dipakai ulang.
class AppValidators {
  const AppValidators._();

  static String? nama(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nama lengkap tidak boleh kosong';
    }
    if (value.trim().length < 3) {
      return 'Nama lengkap minimal 3 karakter';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username tidak boleh kosong';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password tidak boleh kosong';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? konfirmasiPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password tidak boleh kosong';
    }
    if (value != password) {
      return 'Konfirmasi password tidak sesuai';
    }
    return null;
  }

  /// Validator umum untuk field teks yang wajib diisi.
  static String? requiredField(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label tidak boleh kosong';
    }
    return null;
  }

  /// Validator tahun terbit dokumen (1900 - 2100).
  static String? tahun(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Tahun tidak boleh kosong';
    }
    final int? year = int.tryParse(value.trim());
    if (year == null) {
      return 'Tahun harus berupa angka';
    }
    if (year < 1900 || year > 2100) {
      return 'Tahun harus di antara 1900 dan 2100';
    }
    return null;
  }
}
