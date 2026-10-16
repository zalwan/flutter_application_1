import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/user_model.dart';

/// Repository / Database Helper untuk Tugas 6.
///
/// v2: login pakai NIM + data kemahasiswaan.
/// Menyimpan tabel `users` (registrasi) dan tabel `active_session`
/// (single-row `id = 1`: userId + nim + timestamp expiry).
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'tugas6_auth.db';
  static const int _dbVersion = 2;

  /// Durasi session default. Ubah sesuai ketentuan dosen.
  static const Duration sessionDuration = Duration(days: 7);

  Database? _database;

  Future<Database> get database async {
    _database ??= await _open();
    return _database!;
  }

  Future<Database> _open() async {
    // sqflite hanya jalan native di Android/iOS.
    // Di desktop (Linux/Windows/macOS) + test harus pakai FFI,
    // kalau tidak akan error "databaseFactory not initialized".
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dbPath = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      dbPath,
      version: _dbVersion,
      onCreate: (db, version) async => _createV2(db),
      onUpgrade: (db, oldVersion, newVersion) async {
        // Tugas kampus: data lama boleh di-reset agar skema NIM langsung rapi.
        if (oldVersion < 2) {
          await db.execute('DROP TABLE IF EXISTS active_session');
          await db.execute('DROP TABLE IF EXISTS users');
          await _createV2(db);
        }
      },
    );
  }

  Future<void> _createV2(Database db) async {
    await db.execute(
      'CREATE TABLE users('
      'id INTEGER PRIMARY KEY AUTOINCREMENT, '
      'name TEXT NOT NULL, '
      'nim TEXT NOT NULL UNIQUE, '
      'password_hash TEXT NOT NULL, '
      'prodi TEXT NOT NULL, '
      'kelas TEXT NOT NULL, '
      'gender TEXT NOT NULL, '
      'semester INTEGER NOT NULL, '
      'created_at TEXT NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE active_session('
      'id INTEGER PRIMARY KEY CHECK(id = 1), '
      'user_id INTEGER NOT NULL, '
      'nim TEXT NOT NULL, '
      'login_at TEXT NOT NULL, '
      'expires_at TEXT NOT NULL, '
      'FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE)',
    );
  }

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap());
  }

  Future<UserModel?> getUserByNim(String nim) async {
    final db = await database;
    final rows = await db.query(
      'users',
      where: 'nim = ?',
      whereArgs: [nim.trim()],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return UserModel.fromMap(rows.first);
  }

  /// Dipanggil saat user sukses login / register.
  Future<void> saveSession({
    required int userId,
    required String nim,
    Duration duration = sessionDuration,
  }) async {
    final db = await database;
    final now = DateTime.now();
    await db.insert(
      'active_session',
      {
        'id': 1,
        'user_id': userId,
        'nim': nim,
        'login_at': now.toIso8601String(),
        'expires_at': now.add(duration).toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<ActiveSession?> getSession() async {
    final db = await database;
    final rows = await db.query(
      'active_session',
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return ActiveSession.fromMap(rows.first);
  }

  Future<void> clearSession() async {
    final db = await database;
    await db.delete('active_session', where: 'id = 1');
  }

  /// Dibaca saat app start untuk menentukan apakah user masih logged in.
  ///
  /// Return `User` jika session valid, `null` jika tidak ada / expired /
  /// user sudah dihapus (sekaligus membersihkan session basi).
  Future<UserModel?> checkSession() async {
    final db = await database;
    final sessionRows = await db.query(
      'active_session',
      where: 'id = 1',
      limit: 1,
    );
    if (sessionRows.isEmpty) return null;

    final session = ActiveSession.fromMap(sessionRows.first);
    if (session.isExpired) {
      await clearSession();
      return null;
    }

    final userRows = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [session.userId],
      limit: 1,
    );
    if (userRows.isEmpty) {
      await clearSession();
      return null;
    }
    return UserModel.fromMap(userRows.first);
  }

  /// Untuk testing: tutup koneksi agar bisa dibuka ulang.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
