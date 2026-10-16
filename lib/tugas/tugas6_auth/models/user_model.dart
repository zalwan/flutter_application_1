/// Model untuk Tugas 6: Login NIM & Registration mahasiswa + SQLite session.
class UserModel {
  const UserModel({
    this.id,
    required this.name,
    required this.nim,
    required this.passwordHash,
    required this.prodi,
    required this.kelas,
    required this.gender,
    required this.semester,
    required this.createdAt,
  });

  final int? id;
  final String name;
  final String nim;
  final String passwordHash;
  final String prodi;
  final String kelas;
  final String gender;
  final int semester;
  final DateTime createdAt;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'nim': nim,
      'password_hash': passwordHash,
      'prodi': prodi,
      'kelas': kelas,
      'gender': gender,
      'semester': semester,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, Object?> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      nim: map['nim'] as String,
      passwordHash: map['password_hash'] as String,
      prodi: (map['prodi'] as String?) ?? '-',
      kelas: (map['kelas'] as String?) ?? '-',
      gender: (map['gender'] as String?) ?? '-',
      semester: (map['semester'] as int?) ?? 1,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

/// Representasi baris tabel `active_session`.
class ActiveSession {
  const ActiveSession({
    required this.userId,
    required this.nim,
    required this.loginAt,
    required this.expiresAt,
  });

  final int userId;
  final String nim;
  final DateTime loginAt;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  factory ActiveSession.fromMap(Map<String, Object?> map) {
    // Kompatibel dengan DB lama (v1 pakai kolom `email`).
    final nim = (map['nim'] ?? map['email']) as String;
    return ActiveSession(
      userId: map['user_id'] as int,
      nim: nim,
      loginAt: DateTime.parse(map['login_at'] as String),
      expiresAt: DateTime.parse(map['expires_at'] as String),
    );
  }
}
