# To-Do List App (Flutter + Supabase)

Aplikasi To-Do List dengan autentikasi email & password menggunakan Supabase.
Setiap pengguna hanya dapat melihat dan mengubah to-do miliknya sendiri.

## Fitur

- Registrasi dan login dengan email + password (Supabase Auth).
- Menampilkan email pengguna yang sedang login pada header halaman To-Do.
- Sesi tersimpan otomatis: pengguna tetap login setelah aplikasi ditutup dan dibuka kembali.
- Tombol Logout (dengan konfirmasi) untuk keluar dari aplikasi.
- CRUD to-do: tambah, tandai selesai, hapus, dan pull-to-refresh.
- Isolasi data antar pengguna dijaga oleh Row Level Security (RLS) di PostgreSQL.

## Fitur Praktikum 10 (TabLayout + Native/Sensor)

- Navigasi `DefaultTabController` dengan 2 tab: **List Tugas** dan **New Task**.
- **Kamera** (`image_picker`): ambil foto dari form New Task, preview thumbnail,
  lalu diunggah ke Supabase Storage bucket `todo-photos` saat tugas disimpan.
- **GPS** (`geolocator`): ambil koordinat latitude/longitude terkini dari form New Task.
- **Permission** (`permission_handler`): izin kamera, lokasi, dan notifikasi
  diminta serentak saat HomeScreen dibuka, dengan pesan arahan ke Settings
  bila ditolak permanen.
- **Push Notification** (`firebase_messaging`): registration ID disimpan ke tabel
  `fcm_tokens`; pesan foreground ditampilkan sebagai banner in-app.
  *Catatan: butuh konfigurasi Firebase (google-services.json) — bila belum
  dikonfigurasi, aplikasi tetap berjalan normal tanpa push notification.*

## Struktur Kode

```
lib/
  main.dart                        # Inisialisasi Supabase + Provider + Firebase
  config/supabase_config.dart      # Baca URL & publishable key dari --dart-define
  models/todo.dart                 # Model To-Do (+ description, photo_url, lat/lng)
  providers/task_draft_provider.dart # State draft tugas baru (foto, koordinat, submit)
  services/native_service.dart     # Permission, kamera, GPS, FCM
  screens/auth_gate.dart           # Memilih halaman login atau HomeScreen
  screens/home_screen.dart         # TabBar + TabBarView + header akun + logout
  screens/todo_screen.dart         # Tab "List Tugas" (logika inti Praktikum 9)
  screens/new_task_screen.dart     # Tab "New Task" (kamera + GPS + submit)
  screens/login_screen.dart        # Form login
  screens/register_screen.dart     # Form registrasi
  screens/setup_required_screen.dart # Petunjuk bila kredensial belum diisi
  utils/validators.dart            # Validasi email & password
  utils/error_messages.dart        # Pesan error Supabase dalam Bahasa Indonesia
supabase/schema.sql                # Tabel todos + RLS + storage + fcm_tokens
supabase/migration_ptm10.sql       # Migration kolom baru (jalankan di SQL Editor)
integration_test/account_isolation_test.dart # Uji isolasi data 2 akun
```

## Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com).
2. Buka **SQL Editor > New query**, tempel seluruh isi `supabase/schema.sql`, lalu **Run**.
   Untuk project yang sudah jalan sejak Praktikum 9, cukup jalankan
   `supabase/migration_ptm10.sql`.
3. Buka **Authentication > Sign In / Providers > Email**, lalu matikan
   **Confirm email** agar pengguna bisa langsung login setelah mendaftar.
4. Buka **Project Settings > API Keys**, salin **Project URL** dan **publishable key**
   (kalau project kamu masih memakai key lama, `anon` key juga bisa dipakai).
5. (Opsional, untuk push notification) Buat project di
   [console.firebase.google.com](https://console.firebase.google.com), daftarkan
   aplikasi Android dengan package `com.example.flutter_application_1`, unduh
   `google-services.json`, letakkan di `android/app/`, dan tambahkan plugin
   `com.google.gms.google-services` pada `android/app/build.gradle`.

## Menjalankan Aplikasi

Isi `dart_defines.json` di root project (file ini di-ignore oleh git):

```json
{
  "SUPABASE_URL": "https://xxxxxxxxxxxx.supabase.co",
  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_xxxxxxxx"
}
```

Lalu jalankan:

```bash
flutter run --dart-define-from-file=dart_defines.json
```

Jika kredensial belum diisi, aplikasi menampilkan halaman petunjuk konfigurasi,
bukan error yang membingungkan.

## Pengujian

Test unit dan widget (tanpa jaringan):

```bash
flutter test
```

Uji isolasi data dua akun terhadap Supabase sungguhan (butuh emulator/perangkat):

```bash
flutter test integration_test -d emulator-5554 --dart-define-from-file=dart_defines.json
```

Test tersebut mendaftarkan dua akun, membuat to-do pada masing-masing akun, lalu
memastikan akun B tidak bisa membaca, mengubah, menghapus, maupun menulis to-do
atas nama akun A. Akun uji memakai prefix `todo.e2e.*` sehingga mudah dikenali
dan bisa dihapus dari dashboard.

Uji manual "tetap login setelah aplikasi ditutup":

1. Login, lalu tutup aplikasi (atau `adb shell am force-stop <package>`).
2. Buka lagi aplikasinya — pengguna langsung masuk ke daftar to-do tanpa login ulang.
