import '../models/document.dart';

/// Data awal dokumen yang disimpan ke SQLite saat aplikasi pertama kali
/// dijalankan. Gambar diambil dari folder `assets/images/covers/`.
class DocumentSeed {
  const DocumentSeed._();

  static List<Document> get items => [
    Document(
      title: 'Dasar-Dasar Pemrograman Mobile',
      category: 'Teknologi',
      author: 'Samso Supriyatna',
      year: 2024,
      description:
          'Panduan pengantar pengembangan aplikasi mobile menggunakan '
          'Flutter. Membahas struktur project, widget dasar, layout, '
          'serta pengelolaan state untuk pemula.',
      image: 'assets/images/covers/cover_01.png',
      createdAt: DateTime(2024, 1, 10),
      updatedAt: DateTime(2024, 1, 10),
    ),
    Document(
      title: 'Metodologi Penelitian Sistem Informasi',
      category: 'Akademik',
      author: 'Meta Susanti',
      year: 2023,
      description:
          'Buku ajar yang menjelaskan tahapan penelitian sistem informasi, '
          'mulai dari perumusan masalah, pengumpulan data, hingga penyusunan '
          'laporan penelitian yang baik.',
      image: 'assets/images/covers/cover_02.png',
      createdAt: DateTime(2024, 2, 14),
      updatedAt: DateTime(2024, 2, 14),
    ),
    Document(
      title: 'Basis Data Relasional',
      category: 'Teknologi',
      author: 'Gusmayeni',
      year: 2022,
      description:
          'Membahas konsep basis data relasional, normalisasi, perancangan '
          'tabel, serta penerapan query SQL untuk kebutuhan aplikasi '
          'berbasis data.',
      image: 'assets/images/covers/cover_03.png',
      createdAt: DateTime(2024, 3, 8),
      updatedAt: DateTime(2024, 3, 8),
    ),
    Document(
      title: 'Manajemen Proyek Perangkat Lunak',
      category: 'Manajemen',
      author: 'Rizal Suryawan',
      year: 2024,
      description:
          'Ringkasan praktik manajemen proyek perangkat lunak: penyusunan '
          'kebutuhan, estimasi waktu, pembagian tugas tim, serta pemantauan '
          'progres pengembangan.',
      image: 'assets/images/covers/cover_04.png',
      createdAt: DateTime(2024, 4, 21),
      updatedAt: DateTime(2024, 4, 21),
    ),
    Document(
      title: 'Kecerdasan Buatan Terapan',
      category: 'Sains',
      author: 'Ade Haerudin',
      year: 2025,
      description:
          'Pengantar penerapan kecerdasan buatan pada aplikasi sehari-hari, '
          'meliputi pengenalan pola, rekomendasi, dan pemanfaatan model '
          'machine learning secara sederhana.',
      image: 'assets/images/covers/cover_05.png',
      createdAt: DateTime(2024, 5, 30),
      updatedAt: DateTime(2024, 5, 30),
    ),
    Document(
      title: 'Bisnis Digital dan Kewirausahaan',
      category: 'Bisnis',
      author: 'Tim Dosen UNPAM',
      year: 2023,
      description:
          'Materi tentang peluang usaha digital, penyusunan model bisnis, '
          'strategi pemasaran daring, dan pengelolaan keuangan usaha kecil '
          'berbasis teknologi.',
      image: 'assets/images/covers/cover_06.png',
      createdAt: DateTime(2024, 6, 18),
      updatedAt: DateTime(2024, 6, 18),
    ),
  ];
}
