/// Model data dokumen pada repositori Rizal Docs.
class Document {
  const Document({
    this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.year,
    required this.description,
    required this.image,
    this.isFavorite = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final int? id;
  final String title;
  final String category;
  final String author;
  final int year;
  final String description;

  /// Path aset lokal, mis. `assets/images/covers/cover_01.png`.
  final String image;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Document.fromMap(Map<String, Object?> map) {
    return Document(
      id: map['id'] as int?,
      title: map['title'] as String,
      category: map['category'] as String,
      author: map['author'] as String,
      year: map['year'] as int,
      description: map['description'] as String,
      image: map['image'] as String,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'author': author,
      'year': year,
      'description': description,
      'image': image,
      'is_favorite': isFavorite ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Document copyWith({
    int? id,
    String? title,
    String? category,
    String? author,
    int? year,
    String? description,
    String? image,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      author: author ?? this.author,
      year: year ?? this.year,
      description: description ?? this.description,
      image: image ?? this.image,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
