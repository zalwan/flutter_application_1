class Todo {
  const Todo({
    required this.id,
    required this.title,
    required this.isDone,
    required this.createdAt,
    this.description,
    this.photoUrl,
    this.latitude,
    this.longitude,
  });

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'] as String,
      title: map['title'] as String,
      isDone: map['is_done'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(map['created_at'] as String? ?? '')?.toLocal() ??
          DateTime.now(),
      description: map['description'] as String?,
      photoUrl: map['photo_url'] as String?,
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String title;
  final bool isDone;
  final DateTime createdAt;

  /// Kolom baru Praktikum 10 (boleh null agar baris lama tetap valid).
  final String? description;
  final String? photoUrl;
  final double? latitude;
  final double? longitude;

  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get hasLocation => latitude != null && longitude != null;

  String get formattedDate {
    final day = createdAt.day.toString().padLeft(2, '0');
    final month = createdAt.month.toString().padLeft(2, '0');
    return '$day/$month/${createdAt.year}';
  }
}
