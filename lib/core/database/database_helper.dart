import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../../data/document_seed.dart';
import '../../models/document.dart';
import '../constants/app_constants.dart';

/// Pengelola koneksi database SQLite aplikasi.
///
/// Menggunakan pola singleton agar hanya ada satu koneksi database selama
/// aplikasi berjalan.
class DatabaseHelper {
  DatabaseHelper._();

  static final DatabaseHelper instance = DatabaseHelper._();

  static Database? _database;

  Future<Database> get database async {
    return _database ??= await _openDatabase();
  }

  Future<Database> _openDatabase() async {
    final String databasePath = join(
      await getDatabasesPath(),
      AppConstants.databaseName,
    );

    return openDatabase(
      databasePath,
      version: AppConstants.databaseVersion,
      onConfigure: (Database db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createUsersTable(db);
    await _createDocumentsTable(db);
    await _seedDocuments(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Versi 2: menambahkan tabel dokumen beserta data awal dari aset lokal.
    if (oldVersion < 2) {
      await _createDocumentsTable(db);
      await _seedDocuments(db);
    }
  }

  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.usersTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDocumentsTable(Database db) async {
    await db.execute('''
      CREATE TABLE ${AppConstants.documentsTable} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        category TEXT NOT NULL,
        author TEXT NOT NULL,
        year INTEGER NOT NULL,
        description TEXT NOT NULL,
        image TEXT NOT NULL,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _seedDocuments(Database db) async {
    final int count =
        Sqflite.firstIntValue(
          await db.rawQuery(
            'SELECT COUNT(*) FROM ${AppConstants.documentsTable}',
          ),
        ) ??
        0;

    if (count > 0) return;

    final Batch batch = db.batch();
    for (final Document document in DocumentSeed.items) {
      batch.insert('documents', document.toMap()..remove('id'));
    }
    await batch.commit(noResult: true);
  }

  /// Menutup koneksi database. Dipakai oleh pengujian.
  Future<void> close() async {
    final Database? db = _database;
    if (db != null && db.isOpen) {
      await db.close();
    }
    _database = null;
  }
}
