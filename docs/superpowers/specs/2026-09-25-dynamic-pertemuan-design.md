# Desain Daftar Pertemuan Dinamis

## Tujuan

Mengubah halaman Home agar menampilkan tombol untuk setiap pertemuan. Isi setiap pertemuan dipisahkan dalam folder sendiri, dimulai dengan `ptm_2` dan `ptm_3`. Penambahan pertemuan berikutnya dilakukan melalui generator ringan tanpa dependency pihak ketiga.

Konten Home, Materi, dan Profile yang sudah ada tidak dipindahkan ke dalam folder pertemuan. Tab Materi dan Profile tetap tersedia, sementara isi Home diganti dengan daftar pertemuan.

## Struktur

Setiap pertemuan memakai kontrak folder berikut:

```text
lib/pertemuan/
  ptm_2/
    page.dart
  ptm_3/
    page.dart
  generated/
    pertemuan_registry.g.dart
```

Folder harus bernama `ptm_<nomor>` dengan nomor bulat positif tanpa nol di depan dan memiliki `page.dart`. Setiap `page.dart` menyediakan fungsi top-level `Widget buildPertemuanPage()` dengan antarmuka yang sama. Isi awalnya adalah template sederhana yang menampilkan nama pertemuan. Registry mengimpor setiap halaman dengan alias unik sehingga nama fungsi tersebut dapat sama di semua folder.

File `pertemuan_registry.g.dart` dihasilkan oleh generator dan tidak diedit secara manual. Registry memuat nomor, judul, dan pembuat halaman untuk setiap folder yang valid.

## Alur Penggunaan

Cara utama menambah pertemuan adalah:

```text
dart run tool/create_pertemuan.dart 4
```

Perintah tersebut:

1. Memvalidasi nomor pertemuan.
2. Membuat `lib/pertemuan/ptm_4/page.dart` dari template sederhana.
3. Menjalankan generator registry.
4. Menampilkan ringkasan file yang dibuat.

Jika folder dibuat atau diubah secara manual, registry dapat diperbarui dengan:

```text
dart run tool/generate_pertemuan.dart
```

Generator memindai folder `lib/pertemuan/ptm_*`, mengurutkannya berdasarkan nomor, lalu menghasilkan import dan daftar pertemuan yang aman pada waktu compile.

## Tampilan dan Navigasi

Home membaca daftar dari registry dan membuat tombol atau kartu yang dapat diklik untuk setiap pertemuan. Label tombol menggunakan format `Pertemuan <nomor>` dan selalu diurutkan secara numerik.

Ketika tombol ditekan, aplikasi membuka halaman pertemuan menggunakan `Navigator.push` dan `MaterialPageRoute`. Halaman template memiliki AppBar, judul pertemuan, dan teks penanda bahwa konten dapat dikembangkan di file folder tersebut.

Navigasi bawah yang sudah ada tetap memuat Home, Materi, dan Profile.

## Validasi dan Penanganan Kesalahan

Generator berhenti tanpa menimpa registry yang valid ketika menemukan kondisi berikut:

- nama folder yang diawali `ptm` tidak mengikuti pola kanonis `ptm_<nomor>`;
- nomor pertemuan duplikat;
- folder pertemuan tidak memiliki `page.dart`;
- argumen pembuat pertemuan bukan bilangan bulat positif;
- folder tujuan sudah ada.

Pesan kesalahan menyebutkan penyebab dan lokasi yang harus diperbaiki. Penulisan registry dilakukan setelah seluruh input lolos validasi agar kegagalan tidak menghasilkan file setengah jadi.

## Berkas yang Berubah

- `lib/pages/home_page.dart`: menampilkan daftar tombol dari registry.
- `lib/pertemuan/pertemuan_item.dart`: model metadata dan pembuat halaman.
- `lib/pertemuan/ptm_2/page.dart`: halaman template Pertemuan 2.
- `lib/pertemuan/ptm_3/page.dart`: halaman template Pertemuan 3.
- `lib/pertemuan/generated/pertemuan_registry.g.dart`: registry hasil generator.
- `tool/generate_pertemuan.dart`: pemindai folder dan pembuat registry.
- `tool/create_pertemuan.dart`: pembuat folder/template yang kemudian memperbarui registry.
- `test/widget_test.dart`: pengujian daftar dan navigasi Home.
- `test/tool/generate_pertemuan_test.dart`: pengujian generator dan validasinya.
- `README.md`: petunjuk menambah pertemuan.

## Pengujian

Pengujian widget memastikan Home menampilkan Pertemuan 2 dan Pertemuan 3 dalam urutan yang benar, serta menekan tombol membuka halaman yang sesuai.

Pengujian generator menggunakan direktori sementara untuk memastikan folder valid menghasilkan registry terurut. Kasus nama tidak valid, `page.dart` yang hilang, nomor duplikat, dan folder tujuan yang sudah ada harus menghasilkan kegagalan yang dapat dipahami tanpa merusak keluaran sebelumnya.

Verifikasi akhir menjalankan formatter, analyzer, seluruh test Flutter, lalu generator sekali lagi untuk memastikan file hasil generate tetap konsisten.
