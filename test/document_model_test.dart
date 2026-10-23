import 'package:flutter_test/flutter_test.dart';

import 'package:rizal_apps/models/document.dart';

void main() {
  group('Document', () {
    final DateTime createdAt = DateTime(2024, 6, 18, 10, 30);

    final Document document = Document(
      id: 1,
      title: 'Basis Data Relasional',
      category: 'Teknologi',
      author: 'Gusmayeni',
      year: 2022,
      description: 'Buku tentang basis data relasional.',
      image: 'assets/images/covers/cover_03.png',
      isFavorite: true,
      createdAt: createdAt,
      updatedAt: createdAt,
    );

    test('toMap dan fromMap menghasilkan data yang sama', () {
      final Map<String, Object?> map = document.toMap();
      final Document result = Document.fromMap(map);

      expect(map['is_favorite'], 1);
      expect(result.id, document.id);
      expect(result.title, document.title);
      expect(result.category, document.category);
      expect(result.author, document.author);
      expect(result.year, document.year);
      expect(result.description, document.description);
      expect(result.image, document.image);
      expect(result.isFavorite, isTrue);
      expect(result.createdAt, createdAt);
    });

    test('fromMap membaca is_favorite 0 sebagai false', () {
      final Map<String, Object?> map = document.toMap()..['is_favorite'] = 0;

      expect(Document.fromMap(map).isFavorite, isFalse);
    });

    test('copyWith hanya mengubah field yang diberikan', () {
      final Document updated = document.copyWith(
        title: 'Judul Baru',
        isFavorite: false,
      );

      expect(updated.title, 'Judul Baru');
      expect(updated.isFavorite, isFalse);
      expect(updated.author, document.author);
      expect(updated.createdAt, document.createdAt);
    });
  });
}
