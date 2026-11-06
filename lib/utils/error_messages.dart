import 'package:supabase_flutter/supabase_flutter.dart';

String messageForError(Object error) {
  if (error is AuthException) {
    final message = error.message.toLowerCase();
    if (message.contains('invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (message.contains('email not confirmed')) {
      return 'Email belum dikonfirmasi. Silakan cek inbox email kamu.';
    }
    if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Email ini sudah terdaftar. Silakan masuk.';
    }
    if (message.contains('rate limit') || message.contains('too many')) {
      return 'Terlalu banyak percobaan. Coba lagi beberapa saat lagi.';
    }
    if (message.contains('password')) {
      return 'Password tidak memenuhi syarat (minimal 6 karakter).';
    }
    if (message.contains('email')) {
      return 'Email tidak valid atau tidak dapat digunakan.';
    }
    return error.message;
  }
  if (error is PostgrestException) {
    return 'Gagal mengakses data To-Do: ${error.message}';
  }
  return 'Koneksi ke server gagal. Periksa internet kamu lalu coba lagi.';
}
