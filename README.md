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

## Struktur Kode

```
lib/
  main.dart                        # Inisialisasi Supabase + MaterialApp
  config/supabase_config.dart      # Baca URL & publishable key dari --dart-define
  models/todo.dart                 # Model To-Do
  screens/auth_gate.dart           # Memilih halaman login atau To-Do sesuai status sesi
  screens/login_screen.dart        # Form login
  screens/register_screen.dart     # Form registrasi
  screens/todo_screen.dart         # Daftar to-do + email pengguna + tombol logout
  screens/setup_required_screen.dart # Petunjuk bila kredensial belum diisi
  utils/validators.dart            # Validasi email & password
  utils/error_messages.dart        # Pesan error Supabase dalam Bahasa Indonesia
supabase/schema.sql                # Tabel todos + kebijakan RLS (jalankan di SQL Editor)
integration_test/account_isolation_test.dart # Uji isolasi data 2 akun
```

## Setup Supabase

1. Buat project baru di [supabase.com](https://supabase.com).
2. Buka **SQL Editor > New query**, tempel seluruh isi `supabase/schema.sql`, lalu **Run**.
3. Buka **Authentication > Sign In / Providers > Email**, lalu matikan
   **Confirm email** agar pengguna bisa langsung login setelah mendaftar.
4. Buka **Project Settings > API Keys**, salin **Project URL** dan **publishable key**
   (kalau project kamu masih memakai key lama, `anon` key juga bisa dipakai).

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
