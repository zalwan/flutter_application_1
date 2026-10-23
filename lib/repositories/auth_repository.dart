import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../models/user.dart';

/// Repository untuk operasi data pengguna pada database SQLite.
class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  /// Memeriksa kecocokan username dan password.
  ///
  /// Mengembalikan [User] jika cocok, atau `null` jika tidak ditemukan.
  Future<User?> login(String username, String password) async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username.trim().toLowerCase(), password],
      limit: 1,
    );

    if (rows.isEmpty) return null;
    return User.fromMap(rows.first);
  }

  /// Mengecek apakah username sudah dipakai.
  Future<bool> isUsernameTaken(String username) async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      'users',
      columns: ['id'],
      where: 'username = ?',
      whereArgs: [username.trim().toLowerCase()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }

  /// Menyimpan pengguna baru dan mengembalikan data yang tersimpan.
  Future<User> register({
    required String nama,
    required String username,
    required String password,
  }) async {
    final Database db = await DatabaseHelper.instance.database;
    final User user = User(
      nama: nama.trim(),
      username: username.trim().toLowerCase(),
      // Catatan: password disimpan apa adanya untuk kebutuhan pembelajaran.
      // Pada aplikasi produksi gunakan hashing (mis. bcrypt/argon2).
      password: password,
      createdAt: DateTime.now(),
    );

    final int id = await db.insert('users', user.toMap()..remove('id'));
    return user.copyWith(id: id);
  }
}
