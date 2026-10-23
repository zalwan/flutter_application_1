/// Model data pengguna aplikasi.
class User {
  const User({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  final int? id;
  final String nama;
  final String username;
  final String password;
  final DateTime createdAt;

  factory User.fromMap(Map<String, Object?> map) {
    return User(
      id: map['id'] as int?,
      nama: map['nama'] as String,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'username': username,
      'password': password,
      'created_at': createdAt.toIso8601String(),
    };
  }

  User copyWith({int? id, String? nama, String? username, String? password}) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      password: password ?? this.password,
      createdAt: createdAt,
    );
  }
}
