/// Konstanta global aplikasi: identitas mahasiswa, nama aplikasi, dan
/// konfigurasi database.
///
/// Nilai identitas dipakai pada halaman login, profil, dan header dashboard
/// sehingga cukup diubah di satu tempat.
class AppConstants {
  const AppConstants._();

  // Identitas aplikasi.
  static const String appName = 'Rizal Docs';
  static const String appTagline = 'Repositori & Koleksi Dokumen';
  static const String appVersion = '1.0.0';

  // Identitas mahasiswa (Soal 1 - identitas project).
  static const String studentName = 'RIZAL SURYAWAN';
  static const String studentNim = '241011750067';
  static const String studentClass = '04SIFE002';
  static const String studentProgram = 'Sistem Informasi S-1';
  static const String studentCampus = 'Universitas Pamulang';

  // Konfigurasi database SQLite.
  static const String databaseName = 'rizal_docs.db';
  static const int databaseVersion = 1;

  static const String usersTable = 'users';
  static const String documentsTable = 'documents';

  // Folder aset lokal.
  static const String profileImage = 'assets/images/profile/profile_rizal.png';
  static const String logoImage = 'assets/images/brand/logo_rizal_docs.png';
}
