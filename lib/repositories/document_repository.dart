import 'package:sqflite/sqflite.dart';

import '../core/database/database_helper.dart';
import '../models/document.dart';

/// Repository untuk operasi CRUD dokumen pada database SQLite.
class DocumentRepository {
  DocumentRepository._();

  static final DocumentRepository instance = DocumentRepository._();

  Future<List<Document>> getAll() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      'documents',
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(Document.fromMap).toList();
  }

  Future<List<Document>> getFavorites() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      'documents',
      where: 'is_favorite = ?',
      whereArgs: [1],
      orderBy: 'created_at DESC, id DESC',
    );
    return rows.map(Document.fromMap).toList();
  }

  Future<Document?> getById(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, Object?>> rows = await db.query(
      'documents',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return Document.fromMap(rows.first);
  }

  Future<Document> create(Document document) async {
    final Database db = await DatabaseHelper.instance.database;
    final DateTime now = DateTime.now();
    final Document newDocument = document.copyWith(
      createdAt: now,
      updatedAt: now,
    );

    final int id = await db.insert(
      'documents',
      newDocument.toMap()..remove('id'),
    );
    return newDocument.copyWith(id: id);
  }

  Future<void> update(Document document) async {
    final int? id = document.id;
    if (id == null) {
      throw ArgumentError('Dokumen harus memiliki id untuk diperbarui.');
    }

    final Database db = await DatabaseHelper.instance.database;
    await db.update(
      'documents',
      document.copyWith(updatedAt: DateTime.now()).toMap(),
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setFavorite(int id, bool isFavorite) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.update(
      'documents',
      {
        'is_favorite': isFavorite ? 1 : 0,
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
