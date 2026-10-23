$ErrorActionPreference = "Stop"

# ============================================================
# Generator laporan UTS Mobile Programming - Rizal Docs
# Menghasilkan laporan.html lalu mencetaknya menjadi PDF
# menggunakan Microsoft Edge (headless print-to-pdf).
# ============================================================

$root = (Resolve-Path (Join-Path $PSScriptRoot "..\..")).Path
$outDir = $PSScriptRoot
$htmlPath = Join-Path $outDir "laporan.html"
$pdfName = "UTS_04SIFE002_241011750067_Rizal_Suryawan.pdf"
$pdfPath = Join-Path $outDir $pdfName

function Enc([string]$text) {
  return [System.Net.WebUtility]::HtmlEncode($text)
}

function Fig([string]$src, [string]$caption, [string]$desc) {
  return '<figure><img class="shot" src="' + $src + '" alt="Screenshot aplikasi">' +
    '<figcaption><strong>' + $caption + '</strong><br>' + $desc + '</figcaption></figure>'
}

function Src([string]$relativePath, [int]$start, [int]$end, [string]$title) {
  $full = Join-Path $root $relativePath
  if (-not (Test-Path -LiteralPath $full)) {
    return '<p class="note">File ' + $relativePath + ' tidak ditemukan.</p>'
  }
  $lines = @(Get-Content -LiteralPath $full -Encoding UTF8)
  if ($end -le 0 -or $end -gt $lines.Count) { $end = $lines.Count }
  if ($start -lt 1) { $start = 1 }
  $body = ($lines[($start - 1)..($end - 1)]) -join "`n"
  return '<div class="srchead"><strong>' + $title + '</strong> &mdash; <code>' +
    $relativePath + '</code> (baris ' + $start + '&ndash;' + $end + ')</div>' +
    '<pre class="code"><code>' + (Enc $body) + '</code></pre>'
}

function FileListing([string]$relativePath) {
  $full = Join-Path $root $relativePath
  if (-not (Test-Path -LiteralPath $full)) { return "" }
  $text = Get-Content -LiteralPath $full -Raw -Encoding UTF8
  $count = @(Get-Content -LiteralPath $full -Encoding UTF8).Count
  return '<div class="filehead">' + $relativePath + ' <span class="muted">(' +
    $count + ' baris)</span></div><pre class="code small"><code>' +
    (Enc $text) + '</code></pre>'
}

$libFiles = @(Get-ChildItem -Path (Join-Path $root "lib") -Recurse -Filter *.dart | Sort-Object FullName)
$libCount = $libFiles.Count
$libLines = 0
foreach ($file in $libFiles) {
  $libLines += @(Get-Content -LiteralPath $file.FullName -Encoding UTF8).Count
}

$testFiles = @("test/validators_test.dart", "test/document_model_test.dart", "test/widget_test.dart", "integration_test/app_test.dart")
$testLines = 0
foreach ($rel in $testFiles) {
  $full = Join-Path $root $rel
  if (Test-Path -LiteralPath $full) {
    $testLines += @(Get-Content -LiteralPath $full -Encoding UTF8).Count
  }
}

$gitLog = ""
try {
  $gitLog = (& git -C $root log --format="%h  %s" -n 16) -join "`n"
} catch {
  $gitLog = "(riwayat commit tidak tersedia)"
}

$html = @'
<!DOCTYPE html>
<html lang="id">
<head>
<meta charset="utf-8">
<title>Laporan UTS Mobile Programming - Rizal Docs</title>
<style>
*{box-sizing:border-box;-webkit-print-color-adjust:exact;print-color-adjust:exact}
@page{size:A4;margin:16mm 14mm}
body{font-family:"Segoe UI",Arial,sans-serif;font-size:10.5pt;line-height:1.55;color:#1f2937;margin:0}
h1{font-size:22pt;margin:0 0 6mm}
h2.chapter{page-break-before:always;font-size:17pt;color:#1e3a8a;border-bottom:2px solid #1e3a8a;padding-bottom:3mm;margin:0 0 5mm}
h3{font-size:12.5pt;color:#1e3a8a;margin:6mm 0 2mm;page-break-after:avoid}
h4{font-size:11pt;color:#334155;margin:5mm 0 2mm;page-break-after:avoid}
p{margin:0 0 3mm;text-align:justify;orphans:2;widows:2}
ul,ol{margin:0 0 3mm 6mm;padding:0}
li{margin-bottom:1.5mm}
table{width:100%;border-collapse:collapse;margin:2mm 0 4mm;font-size:9.5pt;table-layout:fixed;page-break-inside:avoid}
th,td{border:1px solid #cbd5e1;padding:2mm 2.5mm;vertical-align:top;text-align:left;overflow-wrap:break-word}
td code,th code{font-size:8.6pt}
th{background:#e8eefb;color:#1e3a8a}
code{font-family:Consolas,"Courier New",monospace}
pre.code{font-family:Consolas,"Courier New",monospace;font-size:7.6pt;line-height:1.35;background:#f7f9fc;border:1px solid #dbe3ef;border-radius:2mm;padding:3mm 3.5mm;white-space:pre-wrap;word-break:break-word;margin:1mm 0 4mm}
pre.small{font-size:7.2pt}
.srchead{font-size:8.5pt;color:#475569;margin-top:4mm}
.filehead{font-family:Consolas,monospace;font-size:9pt;background:#1e3a8a;color:#fff;padding:2mm 3mm;border-radius:2mm 2mm 0 0;margin-top:5mm;page-break-after:avoid}
.filehead .muted{color:#c7d6f5}
.muted{color:#94a3b8}
figure{margin:2mm 0 6mm;text-align:center;page-break-inside:avoid}
img.shot{width:64mm;border:1px solid #cbd5e1;border-radius:3mm}
figcaption{font-size:8.8pt;color:#475569;margin-top:2mm;text-align:center}
.note{background:#eef4ff;border-left:4px solid #1e3a8a;padding:3mm 4mm;margin:3mm 0 4mm;font-size:9.5pt}
.flow{text-align:center;margin:4mm 0;page-break-inside:avoid}
.flow .box{display:inline-block;border:1px solid #1e3a8a;background:#eef3fb;color:#1e3a8a;font-weight:600;padding:2mm 7mm;border-radius:2mm}
.flow .arrow{color:#1e3a8a;font-size:12pt;line-height:1.2;margin:0.5mm 0}
.gallery{display:flex;gap:3mm;justify-content:center;align-items:flex-start;margin:3mm 0 4mm}
.gallery img{width:48mm;border:1px solid #cbd5e1;border-radius:3mm}
.cover{height:258mm;display:flex;flex-direction:column;justify-content:space-between;page-break-after:always}
.cover-band{background:linear-gradient(135deg,#132a66 0%,#1e3a8a 55%,#2b4bb0 100%);color:#fff;border-radius:4mm;padding:16mm 14mm 14mm;text-align:center}
.cover-logo{width:26mm;height:26mm;border-radius:6mm;background:#fff;padding:2mm}
.kicker{font-size:9.5pt;letter-spacing:2px;opacity:.9;margin-top:5mm}
.cover-band h1{font-size:24pt;margin:2mm 0 1mm;color:#fff}
.cover-line{width:34mm;height:1.2mm;background:#f59e0b;margin:4mm auto}
.app{font-size:26pt;font-weight:700}
.appsub{font-size:12.5pt;opacity:.92;margin-top:1mm}
.cover-body{display:flex;gap:8mm;align-items:center;margin-top:6mm}
.ident{flex:1;margin:0;font-size:10pt}
.ident th{width:34%;background:#eef3fb}
.cover-profile{width:34mm;height:34mm;border-radius:50%;border:1.5mm solid #1e3a8a;object-fit:cover}
.cover-foot{text-align:center;font-size:10pt;letter-spacing:1px;color:#1e3a8a;margin-top:4mm}
.toc-title{font-size:20pt;color:#1e3a8a;border-bottom:2px solid #1e3a8a;padding-bottom:3mm;margin-bottom:5mm}
ol.toc{font-size:11.5pt;margin-left:6mm}
ol.toc li{margin-bottom:2.5mm}
.toc-sub{font-size:10pt;color:#475569;margin-left:2mm;list-style:none;font-weight:normal}
.small-note{font-size:9pt;color:#64748b}
@media print{a{color:inherit;text-decoration:none}}
</style>
</head>
<body>
'@

# ------------------------------------------------------------
# COVER
# ------------------------------------------------------------
$html += @'
<div class="cover">
  <div class="cover-band">
    <img class="cover-logo" src="../../assets/images/brand/logo_rizal_docs.png" alt="Logo Rizal Docs">
    <div class="kicker">LAPORAN UJIAN TENGAH SEMESTER</div>
    <h1>Mobile Programming</h1>
    <div class="cover-line"></div>
    <div class="app">Rizal Docs</div>
    <div class="appsub">Aplikasi Repositori &amp; Koleksi Dokumen</div>
  </div>
  <div class="cover-body">
    <table class="ident">
      <tr><th>Nama Lengkap</th><td><strong>RIZAL SURYAWAN</strong></td></tr>
      <tr><th>NIM</th><td><strong>241011750067</strong></td></tr>
      <tr><th>Kelas</th><td><strong>04SIFE002</strong></td></tr>
      <tr><th>Program Studi</th><td>Sistem Informasi S-1</td></tr>
      <tr><th>Kampus</th><td>Universitas Pamulang</td></tr>
      <tr><th>Tema Aplikasi</th><td>Repositori / Koleksi Dokumen (NIM berakhiran 7)</td></tr>
    </table>
    <img class="cover-profile" src="../../assets/images/profile/profile_rizal.png" alt="Foto profil">
  </div>
  <div class="cover-foot">
    PROGRAM STUDI SISTEM INFORMASI S-1<br>
    UNIVERSITAS PAMULANG<br>
    2026
  </div>
</div>
'@

# ------------------------------------------------------------
# DAFTAR ISI
# ------------------------------------------------------------
$html += @'
<div class="toc-page">
  <div class="toc-title">Daftar Isi</div>
  <ol class="toc">
    <li>BAB 1 &mdash; Pendahuluan</li>
    <li>BAB 2 &mdash; Deskripsi Aplikasi</li>
    <li>BAB 3 &mdash; Prosedur Pengerjaan
      <div class="toc-sub">Tahap 1 &ndash; 17: dokumentasi antarmuka dan source code</div>
    </li>
    <li>BAB 4 &mdash; Hasil Akhir</li>
    <li>BAB 5 &mdash; Kesimpulan</li>
    <li>Lampiran A &mdash; Source Code Aplikasi (folder lib)</li>
    <li>Lampiran B &mdash; Source Code Pengujian</li>
    <li>Lampiran C &mdash; Repositori dan Riwayat Commit</li>
  </ol>
  <div class="note">
    <strong>Cara membaca laporan:</strong> Bab 3 memuat screenshot setiap tahapan antarmuka
    aplikasi beserta keterangan dan potongan source code yang relevan. Source code lengkap
    dilampirkan pada Lampiran A dan B, sedangkan project akhir dapat dijalankan dari
    repositori GitHub pada Lampiran C.
  </div>
</div>
'@

# ------------------------------------------------------------
# BAB 1
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">BAB 1 &middot; PENDAHULUAN</h2>

<h3>1.1 Latar Belakang</h3>
<p>
Ujian Tengah Semester (UTS) mata kuliah Mobile Programming menuntut mahasiswa membangun
aplikasi mobile secara utuh: mulai dari perancangan antarmuka, navigasi antar halaman,
pengelolaan data, sampai pengujian. Aplikasi yang dibuat pada laporan ini bernama
<strong>Rizal Docs</strong>, yaitu aplikasi repositori dan koleksi dokumen yang berjalan
pada platform Android dengan framework Flutter.
</p>
<p>
Aplikasi ini menyimpan data pengguna dan data dokumen pada database lokal SQLite sehingga
seluruh fitur dapat digunakan tanpa koneksi internet. Gambar profil, logo, dan sampul
dokumen juga berasal dari aset lokal yang disertakan di dalam project, bukan diunduh dari
internet.
</p>

<h3>1.2 Tema Aplikasi</h3>
<p>
Tema aplikasi ditentukan dari angka terakhir NIM. NIM <strong>241011750067</strong>
berakhiran angka <strong>7</strong>, sehingga tema yang dipilih adalah
<strong>Aplikasi Repositori / Koleksi Dokumen</strong>. Tema tersebut diwujudkan dalam
bentuk katalog dokumen: setiap dokumen memiliki judul, penulis, kategori, tahun,
deskripsi, sampul, dan status favorit.
</p>

<h3>1.3 Tujuan</h3>
<ul>
  <li>Membangun aplikasi Android berbasis Flutter sesuai tema repositori dokumen.</li>
  <li>Menerapkan autentikasi (registrasi dan login) dengan validasi form dan SQLite.</li>
  <li>Membangun dashboard dengan header, body yang dapat di-scroll, dan bottom navigation.</li>
  <li>Menerapkan navigasi detail, aksi favorit dengan dialog konfirmasi, serta CRUD dokumen.</li>
  <li>Mendokumentasikan setiap tahapan pembuatan antarmuka beserta source code aplikasi.</li>
</ul>

<h3>1.4 Alat dan Bahan</h3>
<table>
  <tr><th style="width:32%">Komponen</th><th>Keterangan</th></tr>
  <tr><td>Framework</td><td>Flutter 3.47.7 (stable) dengan bahasa Dart 3.13.5</td></tr>
  <tr><td>Penyimpanan data</td><td>SQLite melalui package <code>sqflite</code> dan <code>path</code></td></tr>
  <tr><td>Format tanggal</td><td>Package <code>intl</code> dengan locale <code>id_ID</code></td></tr>
  <tr><td>Perangkat uji</td><td>Android Emulator (resolusi 1080 x 2400)</td></tr>
  <tr><td>Aset gambar</td><td>Dibuat lokal melalui skrip <code>tool/generate_assets.ps1</code></td></tr>
  <tr><td>Pengujian</td><td><code>flutter analyze</code>, <code>flutter test</code>, dan integration test</td></tr>
  <tr><td>Pembuatan laporan</td><td>HTML + Microsoft Edge headless (print to PDF)</td></tr>
</table>

<h3>1.5 Identitas Mahasiswa</h3>
<table>
  <tr><th style="width:32%">Nama Lengkap</th><td>RIZAL SURYAWAN</td></tr>
  <tr><th>NIM</th><td>241011750067</td></tr>
  <tr><th>Kelas</th><td>04SIFE002</td></tr>
  <tr><th>Program Studi</th><td>Sistem Informasi S-1</td></tr>
  <tr><th>Kampus</th><td>Universitas Pamulang</td></tr>
</table>

<h3>1.6 Sistematika Penulisan</h3>
<p>
Laporan ini disusun dengan urutan sebagai berikut agar pembaca dapat mengikuti proses
pengerjaan dari awal sampai akhir.
</p>
<ul>
  <li><strong>Bab 1 Pendahuluan:</strong> latar belakang, tema aplikasi, tujuan, alat dan bahan, identitas mahasiswa, serta sistematika penulisan.</li>
  <li><strong>Bab 2 Deskripsi Aplikasi:</strong> gambaran umum, fitur, pemenuhan ketentuan soal, struktur project, struktur folder aset, skema database, dan alur aplikasi.</li>
  <li><strong>Bab 3 Prosedur Pengerjaan:</strong> dokumentasi tujuh belas tahap pembuatan antarmuka beserta screenshot, potongan source code, dan hasil pengujian.</li>
  <li><strong>Bab 4 Hasil Akhir:</strong> ringkasan hasil per soal, galeri tampilan akhir, dan informasi build aplikasi.</li>
  <li><strong>Bab 5 Kesimpulan:</strong> rangkuman capaian dan saran pengembangan.</li>
  <li><strong>Lampiran A&ndash;C:</strong> source code aplikasi, source code pengujian, serta informasi repositori dan riwayat commit.</li>
</ul>
'@

# ------------------------------------------------------------
# BAB 2
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">BAB 2 &middot; DESKRIPSI APLIKASI</h2>

<h3>2.1 Gambaran Umum</h3>
<p>
Rizal Docs adalah aplikasi repositori dokumen. Pengguna harus registrasi dan login terlebih
dahulu, kemudian dapat melihat koleksi dokumen, mencari dokumen, membuka detail, menandai
favorit, serta menambah, mengubah, dan menghapus dokumen melalui menu Pengaturan.
Aplikasi terdiri dari halaman splash, autentikasi, dashboard dengan empat tab, halaman
detail, form dokumen, dan halaman profil.
</p>

<h3>2.2 Fitur Utama</h3>
<table>
  <tr><th style="width:20%">Fitur</th><th>Penjelasan</th><th style="width:30%">Lokasi Kode</th></tr>
  <tr><td>Registrasi</td><td>Membuat akun baru dengan nama lengkap, username, password, dan konfirmasi password.</td><td><code>features/auth/&#8203;register_page.dart</code></td></tr>
  <tr><td>Login</td><td>Memvalidasi username dan password ke database, menampilkan SnackBar bila berhasil dan AlertDialog bila gagal.</td><td><code>features/auth/&#8203;login_page.dart</code></td></tr>
  <tr><td>Dashboard</td><td>Header AppBar, kartu sambutan, pencarian, filter kategori, dan daftar dokumen yang dapat di-scroll.</td><td><code>features/dashboard/</code></td></tr>
  <tr><td>Detail dokumen</td><td>Menampilkan sampul, judul, kategori, tahun, penulis, deskripsi, dan informasi tambahan.</td><td><code>features/documents/&#8203;document_detail_page.dart</code></td></tr>
  <tr><td>Favorit</td><td>Menandai atau menghapus dokumen dari favorit melalui dialog konfirmasi dan SnackBar.</td><td><code>document_detail_page.dart</code></td></tr>
  <tr><td>CRUD dokumen</td><td>Tambah, ubah, dan hapus dokumen dari menu Pengaturan beserta dialog konfirmasi hapus.</td><td><code>features/settings/&#8203;settings_page.dart</code></td></tr>
  <tr><td>Profil</td><td>Menampilkan identitas mahasiswa, data akun, dan tombol keluar.</td><td><code>features/profile/&#8203;profile_page.dart</code></td></tr>
</table>

<h3>2.3 Pemenuhan Ketentuan Soal</h3>
<table>
  <tr><th style="width:16%">Soal</th><th>Ketentuan</th><th style="width:30%">Implementasi</th></tr>
  <tr><td>1 (20%)</td><td>Nama aplikasi sesuai mahasiswa, foto profil bertema pada login, seluruh gambar dari aset lokal, struktur folder aset terdokumentasi.</td><td>Nama <strong>Rizal Docs</strong>, gambar dari <code>assets/images/&#8203;</code>, dokumentasi pada bagian 2.5.</td></tr>
  <tr><td>2 (20%)</td><td>Login dan registrasi dengan <code>Form</code>, <code>GlobalKey&lt;FormState&gt;</code>, <code>TextFormField</code>, method <code>actionLogin()</code> dan <code>actionRegistrasi()</code>, validasi, SQLite, SnackBar, dan AlertDialog.</td><td><code>login_page.dart</code>, <code>register_page.dart</code>, <code>validators.dart</code>, <code>auth_repository.dart</code>.</td></tr>
  <tr><td>3 (25%)</td><td>Dashboard dengan AppBar, body scroll, BottomNavigationBar, StatefulWidget, daftar dari aset lokal, dan nama pengguna.</td><td><code>dashboard_page.dart</code> dan <code>home_tab.dart</code>.</td></tr>
  <tr><td>4 (25%)</td><td>Menu Pengaturan dengan CRUD, detail melalui <code>Navigator.push</code>, aksi favorit dengan dialog Ya/Batal dan SnackBar.</td><td><code>settings_page.dart</code>, <code>document_form_page.dart</code>, <code>document_detail_page.dart</code>.</td></tr>
</table>

<h3>2.4 Struktur Project</h3>
<pre class="code"><code>rizal_apps/
+-- android/                     konfigurasi Android (label: Rizal Docs)
+-- assets/images/
|   +-- brand/logo_rizal_docs.png
|   +-- covers/cover_01.png ... cover_06.png
|   +-- profile/profile_rizal.png
+-- docs/
|   +-- screenshots/             screenshot dokumentasi (16 gambar)
|   +-- laporan/                 laporan PDF ini
+-- integration_test/app_test.dart
+-- lib/
|   +-- main.dart                entry point + locale Indonesia
|   +-- app.dart                 MaterialApp, tema, splash
|   +-- core/
|   |   +-- constants/           nama aplikasi, identitas, path aset
|   |   +-- database/            helper SQLite (users + documents)
|   |   +-- theme/               warna, tipografi, komponen
|   |   +-- utils/               validator dan format tanggal
|   |   +-- widgets/             field, tombol, dialog, SnackBar
|   +-- data/document_seed.dart  6 data dokumen awal
|   +-- models/                  User dan Document
|   +-- repositories/            AuthRepository, DocumentRepository
|   +-- features/
|       +-- splash/              splash screen
|       +-- auth/                login, registrasi, scaffold autentikasi
|       +-- dashboard/           dashboard + tab beranda
|       +-- documents/           detail, form CRUD, kartu dokumen
|       +-- favorites/           tab favorit
|       +-- profile/             profil mahasiswa
|       +-- settings/            pengelolaan dokumen
+-- test/                        unit test dan widget test
+-- tool/generate_assets.ps1     generator aset gambar lokal
+-- pubspec.yaml</code></pre>

<h3>2.5 Struktur Folder Aset</h3>
<p>
Seluruh gambar berada di dalam folder <code>assets/images/&#8203;</code> dan didaftarkan pada
<code>pubspec.yaml</code>. Tidak ada pemanggilan <code>Image.network</code>,
<code>NetworkImage</code>, atau URL internet pada kode aplikasi.
</p>
<table>
  <tr><th style="width:38%">File</th><th>Penggunaan</th></tr>
  <tr><td><code>assets/images/&#8203;profile/profile_rizal.png</code></td><td>Foto profil bertema pada halaman login, dashboard, dan profil.</td></tr>
  <tr><td><code>assets/images/&#8203;brand/logo_rizal_docs.png</code></td><td>Logo aplikasi pada splash, AppBar dashboard, dan sampul laporan.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_01.png</code></td><td>Sampul dokumen Bisnis Digital dan Kewirausahaan.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_02.png</code></td><td>Sampul dokumen Kecerdasan Buatan Terapan.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_03.png</code></td><td>Sampul dokumen Manajemen Proyek Perangkat Lunak.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_04.png</code></td><td>Sampul dokumen Basis Data Relasional.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_05.png</code></td><td>Sampul dokumen Metodologi Penelitian Sistem Informasi.</td></tr>
  <tr><td><code>assets/images/&#8203;covers/cover_06.png</code></td><td>Sampul dokumen Dasar-Dasar Pemrograman Mobile.</td></tr>
</table>
<p class="small-note">
Registrasi aset pada pubspec.yaml: <code>assets/images/&#8203;profile/</code>,
<code>assets/images/&#8203;brand/</code>, dan <code>assets/images/&#8203;covers/</code>.
</p>

<h3>2.6 Skema Database</h3>
<p>
Database bernama <code>rizal_docs.db</code> dengan versi 2. Versi 1 membuat tabel
<code>users</code>, sedangkan versi 2 menambahkan tabel <code>documents</code> beserta
enam data awal. Migrasi ditangani oleh callback <code>onUpgrade</code> agar data pengguna
tidak hilang ketika aplikasi diperbarui.
</p>
<table>
  <tr><th style="width:24%">Tabel users</th><th>Tipe</th><th>Keterangan</th></tr>
  <tr><td>id</td><td>INTEGER</td><td>Primary key autoincrement</td></tr>
  <tr><td>nama</td><td>TEXT</td><td>Nama lengkap pengguna</td></tr>
  <tr><td>username</td><td>TEXT</td><td>Unik, dipakai untuk login</td></tr>
  <tr><td>password</td><td>TEXT</td><td>Password pengguna</td></tr>
  <tr><td>created_at</td><td>TEXT</td><td>Waktu pendaftaran (ISO 8601)</td></tr>
</table>
<table>
  <tr><th style="width:24%">Tabel documents</th><th>Tipe</th><th>Keterangan</th></tr>
  <tr><td>id</td><td>INTEGER</td><td>Primary key autoincrement</td></tr>
  <tr><td>title</td><td>TEXT</td><td>Judul dokumen</td></tr>
  <tr><td>category</td><td>TEXT</td><td>Kategori dokumen</td></tr>
  <tr><td>author</td><td>TEXT</td><td>Penulis dokumen</td></tr>
  <tr><td>year</td><td>INTEGER</td><td>Tahun terbit</td></tr>
  <tr><td>description</td><td>TEXT</td><td>Deskripsi dokumen</td></tr>
  <tr><td>image</td><td>TEXT</td><td>Path sampul di folder aset lokal</td></tr>
  <tr><td>is_favorite</td><td>INTEGER</td><td>Status favorit: 0 atau 1</td></tr>
  <tr><td>created_at</td><td>TEXT</td><td>Waktu dibuat</td></tr>
  <tr><td>updated_at</td><td>TEXT</td><td>Waktu diubah</td></tr>
</table>
'@
$html += Src "lib/core/database/database_helper.dart" 54 81 "Pembuatan tabel users dan documents"

$html += @'
<h3>2.7 Alur Aplikasi</h3>
<div class="flow">
  <div class="box">Splash Screen</div>
  <div class="arrow">&darr;</div>
  <div class="box">Login / Registrasi</div>
  <div class="arrow">&darr;</div>
  <div class="box">Dashboard (Beranda, Favorit, Pengaturan, Profil)</div>
  <div class="arrow">&darr;</div>
  <div class="box">Detail Dokumen</div>
  <div class="arrow">&darr;</div>
  <div class="box">Tambah / Hapus Favorit (dialog konfirmasi)</div>
</div>
<p>
Selain jalur utama di atas, menu Pengaturan menyediakan jalur CRUD: daftar dokumen,
form tambah, form ubah, dan dialog hapus. Semua perubahan langsung disimpan ke SQLite dan
daftar dimuat ulang setelah halaman kembali dibuka.
</p>

<h3>2.8 Peta Navigasi</h3>
<table>
  <tr><th style="width:17%">Dari</th><th style="width:32%">Aksi Pengguna</th><th style="width:27%">Halaman Tujuan</th><th>Metode Navigasi</th></tr>
  <tr><td>Login</td><td>Login berhasil</td><td>Dashboard</td><td><code>pushReplacement</code></td></tr>
  <tr><td>Dashboard</td><td>Ketuk kartu dokumen</td><td>Detail Dokumen</td><td><code>Navigator.push</code></td></tr>
  <tr><td>Detail</td><td>Tombol tambah/hapus favorit</td><td>Dialog konfirmasi</td><td><code>showDialog</code></td></tr>
  <tr><td>Detail</td><td>Kembali ke daftar</td><td>Dashboard (muat ulang)</td><td><code>Navigator.pop</code></td></tr>
  <tr><td>Pengaturan</td><td>Tambah atau ubah dokumen</td><td>Form Dokumen</td><td><code>push&lt;bool&gt;</code></td></tr>
  <tr><td>Pengaturan</td><td>Hapus dokumen</td><td>Dialog konfirmasi</td><td><code>showDialog</code></td></tr>
  <tr><td>Profil</td><td>Keluar dari akun</td><td>Login</td><td><code>pushAndRemoveUntil</code></td></tr>
</table>
'@

# ------------------------------------------------------------
# BAB 3
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">BAB 3 &middot; PROSEDUR PENGERJAAN</h2>
<p>
Bab ini mendokumentasikan tahapan pembuatan antarmuka aplikasi. Setiap tahap disertai
screenshot dari emulator Android (resolusi 1080 x 2400) dan keterangan mengenai komponen
Flutter yang digunakan. Potongan source code ditampilkan pada tahap yang relevan,
sedangkan source code lengkap berada pada Lampiran A dan B.
</p>
<div class="note">
  <strong>Ringkasan tahapan:</strong> (1) inisialisasi project dan tema, (2) pembuatan aset
  lokal, (3) pembuatan database SQLite, (4) halaman splash dan login, (5) registrasi,
  (6) validasi form, (7) dashboard, (8) detail dokumen, (9) favorit, (10) CRUD dokumen,
  (11) profil, dan (12) pengujian.
</div>

<h3>Tahap 1 &mdash; Halaman Login</h3>
<p>
Halaman login dibuat dengan <code>AuthScaffold</code> yang menampilkan foto profil bertema
repositori dokumen, nama aplikasi, dan identitas mahasiswa di bagian bawah. Form login
menggunakan dua buah <code>TextFormField</code> (username dan password) di dalam
<code>Form</code> dengan <code>GlobalKey&lt;FormState&gt;</code>. Tombol <em>Masuk</em>
memanggil method <code>actionLogin()</code>.
</p>
'@
$html += Fig "../screenshots/01-login.png" "Gambar 3.1 Halaman login" "Foto profil, judul aplikasi, form login, dan identitas mahasiswa."
$html += @'
<h3>Tahap 2 &mdash; Validasi Form Login</h3>
<p>
Validasi dijalankan sebelum data dikirim ke database. Jika username atau password kosong,
pesan kesalahan muncul tepat di bawah field masing-masing. Password juga divalidasi minimal
enam karakter. Validator dipusatkan pada class <code>AppValidators</code> agar konsisten
dipakai di halaman login dan registrasi.
</p>
'@
$html += Fig "../screenshots/12-validasi-login.png" "Gambar 3.2 Validasi form login" "Pesan Username tidak boleh kosong dan Password tidak boleh kosong tampil di bawah field."
$html += Src "lib/core/utils/validators.dart" 1 66 "Validator username dan password"

$html += @'
<h3>Tahap 3 &mdash; Login Gagal</h3>
<p>
Apabila kombinasi username dan password tidak ditemukan pada tabel <code>users</code>,
aplikasi menampilkan <code>AlertDialog</code> berjudul <em>Login Gagal</em> dengan pesan
<em>Username atau password salah</em> dan satu tombol <em>OK</em>. Dialog dibuat melalui
helper <code>showAppDialog()</code> agar tampilannya seragam.
</p>
'@
$html += Fig "../screenshots/11-login-gagal.png" "Gambar 3.3 Dialog login gagal" "AlertDialog dengan pesan Username atau password salah dan tombol OK."
$html += Src "lib/features/auth/login_page.dart" 53 60 "Penanganan login gagal"

$html += @'
<h3>Tahap 4 &mdash; Form Registrasi</h3>
<p>
Halaman registrasi menggunakan pola yang sama: <code>Form</code>,
<code>GlobalKey&lt;FormState&gt;</code>, dan empat <code>TextFormField</code> untuk nama
lengkap, username, password, dan konfirmasi password. Method
<code>actionRegistrasi()</code> memeriksa keunikan username, menyimpan data ke SQLite,
lalu kembali ke halaman login dengan membawa username yang baru didaftarkan.
</p>
'@
$html += Fig "../screenshots/13-form-registrasi.png" "Gambar 3.4 Form registrasi akun" "Empat field dengan validasi dan tombol Daftar."
$html += Src "lib/features/auth/register_page.dart" 38 82 "Method actionRegistrasi()"

$html += @'
<h3>Tahap 5 &mdash; Registrasi Berhasil</h3>
<p>
Setelah data tersimpan, aplikasi menampilkan SnackBar
<em>Registrasi berhasil, silakan login</em> dan kembali ke halaman login. Username hasil
registrasi otomatis diisikan pada field username agar pengguna tidak perlu mengetik ulang.
</p>
'@
$html += Fig "../screenshots/02-registrasi-berhasil.png" "Gambar 3.5 Registrasi berhasil" "SnackBar konfirmasi dan username terisi otomatis pada halaman login."

$html += @'
<h3>Tahap 6 &mdash; Login Berhasil</h3>
<p>
Jika autentikasi berhasil, method <code>actionLogin()</code> menampilkan SnackBar
<em>Login berhasil</em> lalu berpindah ke dashboard menggunakan
<code>Navigator.pushReplacement</code>. Data pengguna yang login dikirim ke
<code>DashboardPage</code> sehingga namanya dapat ditampilkan pada header.
</p>
'@
$html += Fig "../screenshots/03-login-berhasil.png" "Gambar 3.6 Login berhasil" "SnackBar Login berhasil dan dashboard menampilkan nama pengguna."
$html += Src "lib/features/auth/login_page.dart" 62 67 "SnackBar dan navigasi ke dashboard"

$html += @'
<h3>Tahap 7 &mdash; Dashboard</h3>
<p>
Dashboard merupakan <code>StatefulWidget</code> yang menyimpan indeks tab aktif. Halaman
terdiri dari tiga bagian sesuai ketentuan soal: <em>AppBar</em> sebagai header,
<em>body</em> yang dapat di-scroll, dan <code>BottomNavigationBar</code> sebagai footer
dengan empat tab (Beranda, Favorit, Pengaturan, Profil). Daftar dokumen pada tab Beranda
dibangun dengan <code>ListView.builder</code> dan menampilkan nama pengguna yang sedang
login pada sapaan <em>Halo, ...</em>.
</p>
'@
$html += Fig "../screenshots/04-dashboard.png" "Gambar 3.7 Dashboard aplikasi" "AppBar, kartu sambutan berisi nama dan NIM, pencarian, filter kategori, serta daftar dokumen."
$html += Src "lib/features/dashboard/dashboard_page.dart" 46 146 "Struktur dashboard: AppBar, body, dan BottomNavigationBar"
$html += Src "lib/features/dashboard/widgets/home_tab.dart" 119 142 "Daftar dokumen dengan ListView.builder"

$html += @'
<h3>Tahap 8 &mdash; Detail Dokumen</h3>
<p>
Detail dokumen dibuka dari kartu daftar menggunakan
<code>Navigator.of(context).push(MaterialPageRoute(...))</code>. Halaman detail memakai
<code>CustomScrollView</code> dan <code>SliverAppBar</code> untuk menampilkan sampul,
kemudian judul, kategori, tahun, penulis, deskripsi, dan informasi tambahan berupa tanggal
penambahan serta status favorit.
</p>
'@
$html += Fig "../screenshots/05-detail-dokumen.png" "Gambar 3.8 Halaman detail dokumen" "Sampul, judul, kategori, tahun, penulis, dan deskripsi dokumen."
$html += Src "lib/features/dashboard/widgets/home_tab.dart" 73 84 "Navigasi ke halaman detail"

$html += @'
<h3>Tahap 9 &mdash; Konfirmasi Favorit</h3>
<p>
Tombol aksi pada halaman detail menampilkan teks <em>Tambah ke Favorit</em> atau
<em>Hapus dari Favorit</em> sesuai status dokumen. Sebelum data diubah, aplikasi
menampilkan <code>AlertDialog</code> konfirmasi dengan pesan
<em>Yakin ingin menambahkan ... ke favorit?</em> serta tombol <em>Ya</em> dan
<em>Batal</em>.
</p>
'@
$html += Fig "../screenshots/06-konfirmasi-favorit.png" "Gambar 3.9 Dialog konfirmasi favorit" "Dialog Ya/Batal sebelum status favorit diubah."
$html += Src "lib/features/documents/document_detail_page.dart" 33 47 "Dialog konfirmasi sebelum mengubah favorit"

$html += @'
<h3>Tahap 10 &mdash; Favorit Tersimpan</h3>
<p>
Jika pengguna memilih <em>Ya</em>, status <code>is_favorite</code> diperbarui pada database
dan tampilan langsung berubah: tombol menjadi <em>Hapus dari Favorit</em> dan muncul
SnackBar <em>Dokumen berhasil ditambahkan ke favorit</em>.
</p>
'@
$html += Fig "../screenshots/07-favorit-tersimpan.png" "Gambar 3.10 Favorit berhasil disimpan" "SnackBar konfirmasi dan tombol berubah menjadi Hapus dari Favorit."
$html += Src "lib/features/documents/document_detail_page.dart" 54 67 "Penyimpanan status favorit dan SnackBar"

$html += @'
<h3>Tahap 11 &mdash; Tab Favorit</h3>
<p>
Tab Favorit membaca dokumen dengan <code>is_favorite = 1</code> melalui
<code>DocumentRepository.getFavorites()</code>. Daftar ditampilkan dengan
<code>ListView.builder</code>, dilengkapi jumlah dokumen, pull-to-refresh, dan empty state
apabila belum ada dokumen favorit.
</p>
'@
$html += Fig "../screenshots/08-tab-favorit.png" "Gambar 3.11 Tab favorit" "Dokumen favorit beserta jumlah dan akses ke halaman detail."
$html += Src "lib/repositories/document_repository.dart" 21 30 "Query dokumen favorit"

$html += @'
<h3>Tahap 12 &mdash; Menu Pengaturan (CRUD)</h3>
<p>
Menu Pengaturan memuat tombol <em>Tambah Dokumen</em> dan daftar seluruh dokumen. Setiap
baris memiliki menu tindakan <em>Ubah</em> dan <em>Hapus</em>. Halaman ini juga menjelaskan
alur create, read, update, dan delete kepada pengguna. Form tambah dan ubah dibuka melalui
<code>Navigator.push</code> dan mengembalikan nilai <code>true</code> bila data berubah
sehingga daftar otomatis dimuat ulang.
</p>
'@
$html += Fig "../screenshots/09-pengaturan-crud.png" "Gambar 3.12 Menu Pengaturan" "Tombol tambah, daftar dokumen, dan menu ubah/hapus pada setiap baris."
$html += Src "lib/features/settings/settings_page.dart" 53 63 "Membuka form tambah/ubah dokumen"

$html += @'
<h3>Tahap 13 &mdash; Form Tambah Dokumen</h3>
<p>
Form dokumen berisi field judul, penulis, kategori (dropdown), tahun, deskripsi, dan
pemilih sampul dari enam aset lokal. Validasi memastikan judul, penulis, tahun, dan
deskripsi tidak kosong, tahun berupa angka yang masuk akal, serta sampul telah dipilih.
</p>
'@
$html += Fig "../screenshots/14-form-tambah-dokumen.png" "Gambar 3.13 Form tambah dokumen" "Field data dokumen dan pemilihan sampul dari aset lokal."

$html += @'
<h3>Tahap 14 &mdash; Form Ubah Dokumen</h3>
<p>
Form ubah memakai halaman yang sama dengan form tambah, tetapi menerima objek
<code>Document</code> sehingga seluruh field terisi otomatis. Tombol berubah menjadi
<em>Simpan Perubahan</em>, dan repository memperbarui kolom <code>updated_at</code>.
</p>
'@
$html += Fig "../screenshots/15-form-edit-dokumen.png" "Gambar 3.14 Form ubah dokumen" "Data dokumen terisi otomatis dan tombol Simpan Perubahan."
$html += Src "lib/repositories/document_repository.dart" 59 72 "Update dokumen pada SQLite"

$html += @'
<h3>Tahap 15 &mdash; Konfirmasi Hapus Dokumen</h3>
<p>
Aksi hapus tidak langsung menghapus data. Aplikasi menampilkan dialog konfirmasi
<em>Hapus Dokumen</em> dengan pesan peringatan dan tombol <em>Ya</em> / <em>Batal</em>.
Setelah dikonfirmasi, data dihapus dari SQLite, SnackBar
<em>Dokumen berhasil dihapus</em> ditampilkan, dan daftar dimuat ulang.
</p>
'@
$html += Fig "../screenshots/16-konfirmasi-hapus.png" "Gambar 3.15 Dialog konfirmasi hapus" "Dialog hapus dengan tombol Batal dan Ya."
$html += Src "lib/features/settings/settings_page.dart" 65 94 "Method hapus dokumen"

$html += @'
<h3>Tahap 16 &mdash; Profil Mahasiswa</h3>
<p>
Tab Profil menampilkan foto profil, nama pengguna, username, serta data mahasiswa (nama,
NIM, kelas, program studi, dan kampus). Halaman ini juga menyediakan tombol keluar yang
kembali ke halaman login.
</p>
'@
$html += Fig "../screenshots/10-profil-mahasiswa.png" "Gambar 3.16 Halaman profil" "Identitas mahasiswa dan data akun yang sedang login."

$html += @'
<h3>Tahap 17 &mdash; Pengujian Aplikasi</h3>
<p>
Pengujian dilakukan pada tiga tingkat: analisis statis, unit/widget test, dan integration
test (end-to-end) pada emulator Android. Integration test mencakup registrasi, login,
pembukaan detail, penambahan favorit, pembukaan tab favorit, penambahan dokumen,
perubahan dokumen, dan penghapusan dokumen.
</p>
<table>
  <tr><th style="width:30%">Pengujian</th><th>Hasil</th></tr>
  <tr><td><code>flutter analyze</code></td><td>No issues found</td></tr>
  <tr><td>Unit test validator (6 kasus)</td><td>Lulus</td></tr>
  <tr><td>Unit test model Document (3 kasus)</td><td>Lulus</td></tr>
  <tr><td>Widget test splash dan validasi login (2 kasus)</td><td>Lulus</td></tr>
  <tr><td>Integration test alur utama</td><td>Lulus</td></tr>
</table>
<pre class="code"><code>$ flutter analyze
No issues found! (ran in 1.8s)

$ flutter test
00:01 +11: All tests passed!

$ flutter test integration_test/app_test.dart -d emulator-5554
00:24 +1: All tests passed!</code></pre>
'@

# ------------------------------------------------------------
# BAB 4
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">BAB 4 &middot; HASIL AKHIR</h2>

<h3>4.1 Ringkasan Hasil</h3>
<table>
  <tr><th style="width:17%">Soal</th><th>Hasil yang Dicapai</th><th style="width:14%">Status</th></tr>
  <tr><td>1</td><td>Aplikasi bernama Rizal Docs dengan foto profil bertema dan seluruh gambar dari aset lokal. Struktur folder aset didokumentasikan pada laporan dan README.</td><td>Selesai</td></tr>
  <tr><td>2</td><td>Registrasi dan login menggunakan Form, GlobalKey, TextFormField, validator, SQLite, SnackBar, dan AlertDialog.</td><td>Selesai</td></tr>
  <tr><td>3</td><td>Dashboard StatefulWidget dengan AppBar, body scroll, BottomNavigationBar, ListView.builder, dan nama pengguna.</td><td>Selesai</td></tr>
  <tr><td>4</td><td>Menu Pengaturan dengan CRUD, detail melalui Navigator.push, dialog konfirmasi favorit Ya/Batal, dan SnackBar.</td><td>Selesai</td></tr>
</table>

<h3>4.2 Galeri Hasil Akhir</h3>
<div class="gallery">
  <img src="../screenshots/04-dashboard.png" alt="Dashboard">
  <img src="../screenshots/08-tab-favorit.png" alt="Favorit">
  <img src="../screenshots/09-pengaturan-crud.png" alt="Pengaturan">
</div>
<p style="text-align:center" class="small-note">
Dashboard, tab Favorit, dan menu Pengaturan pada aplikasi versi akhir.
</p>

<h3>4.3 Informasi Build</h3>
<table>
  <tr><th style="width:30%">Item</th><th>Keterangan</th></tr>
  <tr><td>Nama package</td><td><code>rizal_apps</code></td></tr>
  <tr><td>Application ID Android</td><td><code>com.rizal.rizal_apps</code></td></tr>
  <tr><td>Label aplikasi</td><td>Rizal Docs</td></tr>
  <tr><td>Jumlah file Dart (lib)</td><td>__LIBCOUNT__ file, __LIBLINES__ baris</td></tr>
  <tr><td>Jumlah file pengujian</td><td>__TESTCOUNT__ file, __TESTLINES__ baris</td></tr>
  <tr><td>Perintah build</td><td><code>flutter build apk --release</code></td></tr>
  <tr><td>Lokasi APK</td><td><code>build/app/outputs/flutter-apk/app-release.apk</code></td></tr>
</table>
'@
$html = $html.Replace("__LIBCOUNT__", "$libCount").Replace("__LIBLINES__", "$libLines").Replace("__TESTCOUNT__", "$($testFiles.Count)").Replace("__TESTLINES__", "$testLines")

# ------------------------------------------------------------
# BAB 5
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">BAB 5 &middot; KESIMPULAN</h2>
<p>
Aplikasi Rizal Docs berhasil dibangun sesuai tema repositori/koleksi dokumen yang dipilih
berdasarkan angka terakhir NIM. Seluruh ketentuan UTS terpenuhi: antarmuka login dengan
foto profil bertema, autentikasi berbasis SQLite dengan validasi form, dashboard dengan
header dan bottom navigation, halaman detail dengan aksi favorit berdialog konfirmasi,
serta pengelolaan dokumen (create, read, update, delete) melalui menu Pengaturan.
</p>
<p>
Pengerjaan dilakukan secara bertahap dan setiap tahap diverifikasi dengan
<code>flutter analyze</code> dan pengujian. Hasil akhir menunjukkan tidak ada issue pada
analisis statis, sebelas unit/widget test lulus, dan integration test alur utama lulus pada
emulator Android. Seluruh gambar menggunakan aset lokal sehingga aplikasi tetap dapat
digunakan tanpa koneksi internet.
</p>
<p>
Beberapa hal yang dapat dikembangkan pada versi berikutnya: penyimpanan sesi login agar
pengguna tidak perlu masuk ulang, hashing password sebelum disimpan, pencarian lanjutan,
serta sinkronisasi data ke server. Untuk lingkup UTS, aplikasi sudah memenuhi seluruh
kebutuhan fungsional dan ketentuan soal.
</p>
'@

# ------------------------------------------------------------
# LAMPIRAN A - SOURCE CODE
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">LAMPIRAN A &middot; SOURCE CODE APLIKASI</h2>
<p>
Lampiran ini memuat seluruh source code aplikasi pada folder <code>lib</code> tanpa
pemotongan. Setiap berkas diawali dengan judul berwarna biru yang menyebutkan path dan
jumlah baris.
</p>
'@
foreach ($file in $libFiles) {
  $rel = $file.FullName.Substring($root.Length + 1).Replace("\", "/")
  $html += FileListing $rel
}
$html += FileListing "pubspec.yaml"

# ------------------------------------------------------------
# LAMPIRAN B - SOURCE CODE PENGUJIAN
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">LAMPIRAN B &middot; SOURCE CODE PENGUJIAN</h2>
<p>
Lampiran ini memuat unit test, widget test, dan integration test yang digunakan untuk
memverifikasi aplikasi.
</p>
'@
foreach ($rel in $testFiles) {
  $html += FileListing $rel
}

# ------------------------------------------------------------
# LAMPIRAN C - REPOSITORI
# ------------------------------------------------------------
$html += @'
<h2 class="chapter">LAMPIRAN C &middot; REPOSITORI DAN RIWAYAT COMMIT</h2>
<h3>C.1 Repositori</h3>
<table>
  <tr><th style="width:28%">Item</th><th>Keterangan</th></tr>
  <tr><td>Alamat repositori</td><td>https://github.com/zalwan/flutter_application_1</td></tr>
  <tr><td>Branch</td><td><code>uts</code></td></tr>
  <tr><td>Author commit</td><td>zalwan &lt;rizalsuryawan86@gmail.com&gt;</td></tr>
  <tr><td>Jumlah commit fitur</td><td>13 commit (di atas initial commit)</td></tr>
</table>
<h3>C.2 Riwayat Commit</h3>
<pre class="code"><code>__GITLOG__</code></pre>
<h3>C.3 Catatan Keamanan</h3>
<p>
Password disimpan sebagai teks biasa pada database lokal karena fokus pembelajaran berada
pada alur autentikasi dan validasi form. Pada aplikasi produksi, password wajib di-hash
(misalnya bcrypt atau argon2) dan dikirim melalui koneksi aman.
</p>
'@
$html = $html.Replace("__GITLOG__", (Enc $gitLog))

$html += @'
</body>
</html>
'@

[System.IO.File]::WriteAllText($htmlPath, $html, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("HTML ditulis: " + $htmlPath)

$edge = "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
if (-not (Test-Path -LiteralPath $edge)) {
  throw "Microsoft Edge tidak ditemukan."
}

$uri = ([System.Uri]$htmlPath).AbsoluteUri
$edgeArgs = @(
  "--headless=new",
  "--disable-gpu",
  "--no-pdf-header-footer",
  "--run-all-compositor-stages-before-draw",
  "--virtual-time-budget=20000",
  "--no-first-run",
  "--no-default-browser-check",
  "--user-data-dir=$env:TEMP\opencode\edge-laporan",
  "--print-to-pdf=$pdfPath",
  $uri
)

& $edge @edgeArgs | Out-Null
Start-Sleep -Seconds 2

if (-not (Test-Path -LiteralPath $pdfPath)) {
  throw "PDF gagal dibuat."
}

$sizeMb = [Math]::Round((Get-Item -LiteralPath $pdfPath).Length / 1MB, 2)
Write-Output ("PDF dibuat: " + $pdfPath + " (" + $sizeMb + " MB)")
exit 0
