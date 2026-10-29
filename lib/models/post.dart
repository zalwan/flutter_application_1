/// Model gambar sampul sebuah artikel.
class PostImage {
  const PostImage({
    required this.url,
    required this.alt,
    this.width,
    this.height,
  });

  final String url;
  final String alt;
  final int? width;
  final int? height;

  factory PostImage.fromJson(Map<String, dynamic> json) {
    return PostImage(
      url: json['url'] as String? ?? '',
      alt: json['alt'] as String? ?? '',
      width: json['width'] as int?,
      height: json['height'] as int?,
    );
  }
}

/// Model artikel hasil parsing JSON `GET /api/v1/posts.json`.
class Post {
  const Post({
    required this.slug,
    required this.title,
    required this.description,
    this.publishedAt,
    this.updatedAt,
    this.tags = const [],
    this.readingMinutes = 1,
    this.image,
    required this.url,
  });

  final String slug;
  final String title;
  final String description;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final List<String> tags;
  final int readingMinutes;
  final PostImage? image;
  final String url;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      slug: json['slug'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      publishedAt: _parseDate(json['publishedAt']),
      updatedAt: _parseDate(json['updatedAt']),
      tags: (json['tags'] as List?)?.cast<String>() ?? const [],
      readingMinutes: json['readingMinutes'] as int? ?? 1,
      image: json['image'] == null
          ? null
          : PostImage.fromJson(json['image'] as Map<String, dynamic>),
      url: json['url'] as String? ?? '',
    );
  }

  static DateTime? _parseDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }

  static const _bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Label tanggal terbit, misal "14 Agu 2026".
  String get publishedLabel {
    final d = publishedAt;
    if (d == null) return '';
    return '${d.day} ${_bulan[d.month - 1]} ${d.year}';
  }
}