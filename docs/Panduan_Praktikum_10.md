# Panduan Screenshot & Narasi Laporan — Praktikum 10

Panduan untuk melengkapi laporan praktikum: checklist screenshot pembuktian
fitur, narasi teknis, dan langkah pengujian.

## 1. Checklist Screenshot

### A. Konfigurasi & Struktur
- [ ] Tampilan SQL Editor Supabase setelah menjalankan `supabase/migration_ptm10.sql`
      (tabel `todos` dengan kolom baru: `description`, `photo_url`, `latitude`,
      `longitude`, dan tabel `fcm_tokens`).
- [ ] Supabase Dashboard > Storage > bucket `todo-photos` terlihat.
- [ ] (Jika push notification diuji) Firebase Console > Project Settings >
      aplikasi Android terdaftar + file `google-services.json` di `android/app/`.

### B. Permission Handling (permission_handler)
- [ ] Dialog izin **Kamera** muncul pertama kali (Android system dialog,
      judul "Allow flutter_application_1 to take pictures...").
- [ ] Dialog izin **Lokasi** muncul ("Allow ... to access this device's
      location?").
- [ ] Dialog izin **Notifikasi** muncul (Android 13+, "Allow ... to send you
      notifications?").
- [ ] (Opsional) Layar Settings > Apps > flutter_application_1 > Permissions
      setelah izin ditolak permanen, sebagai bukti arahan ke Settings.

### C. Kamera (image_picker + Supabase Storage)
- [ ] Tab "New Task" dengan tombol "Ambil Foto" sebelum foto diambil.
- [ ] Tampilan kamera emulator terbuka (virtual scene) saat tombol ditekan.
- [ ] Preview thumbnail foto muncul di kartu "Foto Tugas" setelah jepretan.
- [ ] Daftar tugas (tab "List Tugas") menampilkan badge ikon kamera/"Foto" dan
      deskripsi pada item tugas yang baru dibuat.
- [ ] Supabase Dashboard > Storage > `todo-photos` > folder berisi file `.jpg`
      milik user (path: `<user_id>/<timestamp>.jpg`) — bukti upload sukses.
- [ ] (Opsional) URL publik foto dibuka di browser menampilkan gambar.

### D. GPS (geolocator)
- [ ] Koordinat Latitude/Longitude tampil pada kartu "Lokasi Tugas" setelah
      tombol "Dapat Lokasi" ditekan.
- [ ] Item tugas di tab "List Tugas" menampilkan badge ikon lokasi dengan nilai
      latitude.
- [ ] (Opsional) Tabel `todos` di Supabase menampilkan baris dengan nilai
      latitude/longitude terisi.

### E. Push Notification (FCM)
- [ ] Log `firebase init completed` / `FCM messaging initialized.` pada
      `adb logcat` atau Debug Console (bila Firebase sudah dikonfigurasi).
- [ ] Tabel `fcm_tokens` di Supabase berisi baris registration ID milik akun
      yang login.
- [ ] Notifikasi foreground: kirim pesan dari Firebase Console > Messaging >
      New campaign selagi aplikasi terbuka → banner SnackBar muncul di dalam
      aplikasi.
- [ ] Notifikasi background: kirim pesan selagi aplikasi di-minimize →
      notifikasi muncul di system tray Android.

### F. Navigasi TabLayout
- [ ] HomeScreen dengan AppBar + TabBar 2 tab ("List Tugas", "New Task").
- [ ] Header akun (email + tombol Logout) tetap tampil di kedua tab.
- [ ] Halaman "List Tugas" identik dengan aplikasi Praktikum 9 (proves core
      logic tidak berubah).
- [ ] Alur submit: isi judul → ambil foto → dapat lokasi → Simpan → pindah otomatis
      ke tab list dengan item baru tampil.

## 2. Narasi Teknis (copy-paste ke laporan, ±190 kata)

Pada praktikum ini aplikasi To-Do List diperluas dengan navigasi TabLayout dan
integrasi fitur native. HomeScreen memakai DefaultTabController dengan AppBar
berisi TabBar dua tab: List Tugas (logika CRUD Praktikum 9 yang tidak diubah)
dan New Task. Permission handling memakai permission_handler: saat HomeScreen
dibuka, izin Camera, Location, dan Notification diminta serentak melalui
`Permission.request()`, sehingga setiap akses hardware sudah terlebih dulu
disetujui oleh OS. Alur kamera: pengguna menekan tombol "Ambil Foto" pada
widget NewTaskScreen → TaskDraftProvider memanggil NativeService.capturePhoto
→ plugin image_picker memicu aplikasi kamera Android (MediaStore Intent) → OS
membuka sensor kamera → hasilnya berupa XFile yang ditampilkan sebagai preview
Image.file → saat tugas disimpan, byte file diunggah ke Supabase Storage bucket
`todo-photos` di folder user_id (dijaga RLS storage), lalu URL publiknya
disimpan ke kolom `photo_url` tabel todos. Alur GPS: tombol "Dapat Lokasi"
memanggil geolocator.getCurrentPosition → plugin mengecek layanan lokasi dan
izin ACCESS_FINE_LOCATION → OS membaca sensor GNSS → koordinat
latitude/longitude ditampilkan lalu disimpan ke kolom tabel. Push notification
memakai Firebase Cloud Messaging: Firebase.initializeApp dijalankan saat
startup, registration ID diambil lewat register() dan di-upsert ke tabel
fcm_tokens; pesan foreground ditampilkan sebagai banner in-app melalui listener
onMessage, sedangkan pesan background otomatis muncul di system tray via
handler top-level. Seluruh fitur berjalan tanpa mengubah logika CRUD maupun
kebijakan RLS yang sudah ada.

## 3. Langkah Pengujian Manual

1. `flutter run -d emulator-5554 --dart-define-from-file=dart_defines.json`
2. Login / registrasi akun → dialog izin muncul (screenshot B).
3. Buka tab "New Task" → isi judul & deskripsi.
4. Tekan "Ambil Foto" → kamera terbuka → ambil foto → preview muncul (C).
5. Tekan "Dapat Lokasi" → koordinat tampil (D). Untuk emulator: set lokasi via
   Extended Controls > Location.
6. Tekan "Simpan Tugas" → otomatis pindah ke tab list, item baru tampil dengan
   badge foto & lokasi.
7. Cek Supabase Storage & tabel `todos` (C/D).
8. (Firebase terkonfigurasi) Kirim campaign dari Firebase Console →
   foreground banner (E), lalu minimize app → kirim lagi → system tray (E).
9. Logout → login akun lain → pastikan data akun pertama tidak terlihat
   (regresi isolasi data).
