# Mobile Programming UNPAM

Aplikasi Flutter untuk menyimpan halaman tugas atau materi berdasarkan pertemuan. Halaman Home membaca registry hasil generator dan menampilkan setiap pertemuan sebagai tombol yang dapat dibuka.

## Menambah Pertemuan

Cara yang direkomendasikan adalah menggunakan pembuat template:

```bash
dart run tool/create_pertemuan.dart 4
```

Perintah tersebut membuat `lib/pertemuan/ptm_4/page.dart` dan langsung memperbarui registry. Ganti angka `4` dengan nomor pertemuan yang ingin ditambahkan.

Setiap `page.dart` harus menyediakan fungsi berikut:

```dart
Widget buildPertemuanPage();
```

Folder pertemuan harus memakai format `ptm_<nomor>`, misalnya `ptm_5`. Nomor harus berupa bilangan bulat positif tanpa nol di depan.

Jika folder dibuat atau diubah secara manual, perbarui registry dengan:

```bash
dart run tool/generate_pertemuan.dart
```

File `lib/pertemuan/generated/pertemuan_registry.g.dart` dibuat otomatis dan tidak boleh diedit secara manual.

## Menjalankan Aplikasi

```bash
flutter run
```

## Pemeriksaan Project

```bash
flutter analyze
flutter test
```
