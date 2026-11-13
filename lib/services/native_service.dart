import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Top-level function wajib untuk handler background message FCM
/// (tidak boleh berupa method/lambda karena dijalankan di isolate terpisah).
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    'FCM background message received: '
    '${message.notification?.title ?? message.data['title'] ?? '(no title)'}',
  );
}

/// Error berbahasa Indonesia yang aman ditampilkan langsung ke pengguna.
class NativeException implements Exception {
  const NativeException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Pusat integrasi fitur native/sensor: permission, kamera, GPS, dan FCM.
///
/// Semua fungsi aman dipanggil walau Firebase belum dikonfigurasi:
/// integrasi FCM dinonaktifkan dengan anggun (graceful degradation)
/// agar logika bisnis To-Do yang sudah ada tidak pernah rusak.
class NativeService {
  NativeService._();

  static const String _photoBucket = 'todo-photos';

  static bool _firebaseReady = false;
  static bool get firebaseReady => _firebaseReady;

  // =========================================================================
  // Firebase (FCM)
  // =========================================================================

  /// Menginisialisasi Firebase. Aman dipanggil tanpa google-services.json:
  /// jika gagal, aplikasi tetap berjalan tanpa push notification.
  static Future<void> ensureFirebaseInitialized() async {
    try {
      await Firebase.initializeApp();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _firebaseReady = true;
      debugPrint('Firebase initialized (FCM ready).');
    } catch (error) {
      _firebaseReady = false;
      debugPrint('Firebase not configured, FCM disabled: $error');
    }
  }

  // =========================================================================
  // Permission handling
  // =========================================================================

  /// Izin yang dibutuhkan sebelum mengakses hardware: kamera, lokasi,
  /// dan notifikasi (Android 13+ / POST_NOTIFICATIONS).
  static const List<Permission> _corePermissions = [
    Permission.camera,
    Permission.locationWhenInUse,
    Permission.notification,
  ];

  /// Meminta semua izin inti secara serentak. Dipanggil sekali saat
  /// pengguna masuk ke HomeScreen, sebelum fitur mana pun diakses.
  static Future<Map<Permission, PermissionStatus>>
  requestCorePermissions() async {
    return _corePermissions.request();
  }

  /// Meminta satu izin dan mengembalikan true bila sudah diizinkan.
  /// Melempar [NativeException] bila ditolak permanen agar UI bisa
  /// mengarahkan pengguna ke halaman setting.
  static Future<bool> ensureGranted(
    Permission permission,
    String label,
  ) async {
    if (await permission.isGranted) {
      return true;
    }
    final status = await permission.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }
    if (status.isPermanentlyDenied) {
      throw NativeException(
        'Izin $label ditolak permanen. Izinkan lewat '
        'Pengaturan > Aplikasi > flutter_application_1.',
      );
    }
    throw NativeException('Izin $label diperlukan untuk fitur ini.');
  }

  // =========================================================================
  // Kamera (image_picker) + Supabase Storage
  // =========================================================================

  /// Mengambil foto dari kamera. Panggil setelah izin kamera diizinkan.
  /// Mengembalikan null bila pengguna membatalkan pengambilan foto.
  static Future<XFile?> capturePhoto() async {
    await ensureGranted(Permission.camera, 'kamera');
    return ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
      imageQuality: 80,
    );
  }

  /// Mengunggah file foto ke Supabase Storage bucket `todo-photos`
  /// dalam folder bernama user_id (dijaga kebijakan RLS storage),
  /// lalu mengembalikan URL publik dari foto tersebut.
  static Future<String> uploadTodoPhoto(String filePath) async {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      throw const NativeException('Sesi berakhir. Silakan login ulang.');
    }

    final file = File(filePath);
    if (!await file.exists()) {
      throw const NativeException('File foto tidak ditemukan.');
    }

    final bytes = await file.readAsBytes();
    final objectPath =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    try {
      await client.storage.from(_photoBucket).uploadBinary(
            objectPath,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
    } on StorageException {
      rethrow;
    }

    return client.storage.from(_photoBucket).getPublicUrl(objectPath);
  }

  // =========================================================================
  // GPS (geolocator)
  // =========================================================================

  /// Mengambil koordinat latitude/longitude terkini. Memeriksa status
  /// layanan lokasi dan izin sebelum meminta posisi ke OS.
  static Future<({double latitude, double longitude})>
      getCurrentCoordinates() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const NativeException(
        'Layanan lokasi (GPS) sedang mati. '
        'Aktifkan lewat Quick Settings lalu coba lagi.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await ensureGranted(Permission.locationWhenInUse, 'lokasi');
      permission = await Geolocator.checkPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const NativeException(
        'Izin lokasi ditolak permanen. Izinkan lewat '
        'Pengaturan > Aplikasi > flutter_application_1.',
      );
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: LocationSettings(accuracy: LocationAccuracy.high),
    );
    return (latitude: position.latitude, longitude: position.longitude);
  }

  // =========================================================================
  // FCM runtime (token + foreground handler)
  // =========================================================================

  /// Menyiapkan FCM: minta izin notifikasi Firebase, pasang listener
  /// pesan foreground, daftarkan app instance dan simpan registration ID
  /// ke tabel `fcm_tokens`, lalu pantau perputaran registration ID.
  /// Tidak melakukan apa-apa bila Firebase belum dikonfigurasi.
  static Future<void> initializeMessaging({
    required void Function(RemoteMessage message) onForegroundMessage,
  }) async {
    if (!_firebaseReady) {
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      messaging.onRegistered.listen(saveMessagingToken);
      await messaging.register();

      FirebaseMessaging.onMessage.listen(onForegroundMessage);
      debugPrint('FCM messaging initialized.');
    } catch (error) {
      debugPrint('FCM init failed (app continues without push): $error');
    }
  }

  /// Menyimpan registration ID FCM milik pengguna yang sedang login.
  static Future<void> saveMessagingToken(String? token) async {
    if (token == null || token.isEmpty) {
      return;
    }
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    if (user == null) {
      return;
    }
    await client.from('fcm_tokens').upsert({
      'user_id': user.id,
      'token': token,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }
}
