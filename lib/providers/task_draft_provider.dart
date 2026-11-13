import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/native_service.dart';

/// State management (Provider) untuk draft tugas baru pada tab "New Task".
///
/// Menahan sementara hasil fitur native (foto kamera & koordinat GPS)
/// sebelum seluruh data digabungkan dan dikirim ke tabel `todos` Supabase.
class TaskDraftProvider extends ChangeNotifier {
  String? _photoPath;
  double? _latitude;
  double? _longitude;

  bool _capturingPhoto = false;
  bool _locating = false;
  bool _submitting = false;
  String? _lastError;

  String? get lastError => _lastError;

  String? get photoPath => _photoPath;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  bool get capturingPhoto => _capturingPhoto;
  bool get locating => _locating;
  bool get submitting => _submitting;

  bool get hasPhoto => _photoPath != null;
  bool get hasLocation => _latitude != null && _longitude != null;

  /// Memicu kamera dan menyimpan file hasil jepretan sebagai preview.
  /// Mengembalikan true bila pengguna berhasil mengambil foto.
  Future<bool> capturePhoto() async {
    if (_capturingPhoto) {
      return false;
    }
    _capturingPhoto = true;
    notifyListeners();

    try {
      final photo = await NativeService.capturePhoto();
      _photoPath = photo?.path;
      if (_photoPath != null) {
        _lastError = null;
      }
      return _photoPath != null;
    } on NativeException catch (error) {
      _photoPath = null;
      _showError(error.message);
      return false;
    } catch (error) {
      debugPrint('capturePhoto failed: $error');
      _showError('Gagal mengambil foto. Coba lagi.');
      return false;
    } finally {
      _capturingPhoto = false;
      notifyListeners();
    }
  }

  /// Memicu GPS dan menyimpan koordinat terkini.
  Future<bool> fetchLocation() async {
    if (_locating) {
      return false;
    }
    _locating = true;
    notifyListeners();

    try {
      final position = await NativeService.getCurrentCoordinates();
      _latitude = position.latitude;
      _longitude = position.longitude;
      _lastError = null;
      return true;
    } on NativeException catch (error) {
      _latitude = null;
      _longitude = null;
      _showError(error.message);
      return false;
    } catch (error) {
      debugPrint('fetchLocation failed: $error');
      _showError('Gagal mendapatkan lokasi. Coba lagi.');
      return false;
    } finally {
      _locating = false;
      notifyListeners();
    }
  }

  /// Validasi + submit data gabungan (teks, foto, koordinat) ke Supabase.
  /// Mengembalikan null bila sukses, atau pesan error untuk ditampilkan.
  Future<String?> submit({
    required String title,
    String? description,
  }) async {
    final trimmedTitle = title.trim();
    if (trimmedTitle.isEmpty) {
      return 'Judul tugas wajib diisi.';
    }
    if (trimmedTitle.length > 200) {
      return 'Judul tugas maksimal 200 karakter.';
    }
    if (_submitting) {
      return null;
    }

    _submitting = true;
    notifyListeners();

    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) {
        return 'Sesi berakhir. Silakan login ulang.';
      }

      // Upload foto dulu (bila ada) agar diperoleh URL publiknya.
      String? photoUrl;
      if (_photoPath != null) {
        photoUrl = await NativeService.uploadTodoPhoto(_photoPath!);
      }

      await client.from('todos').insert({
        'title': trimmedTitle,
        'user_id': user.id,
        if (description != null && description.trim().isNotEmpty)
          'description': description.trim(),
        'photo_url': ?photoUrl,
        'latitude': ?_latitude,
        'longitude': ?_longitude,
      });

      reset();
      return null;
    } on StorageException {
      return 'Gagal mengunggah foto ke Storage. Coba lagi.';
    } on PostgrestException catch (error) {
      return 'Gagal menyimpan tugas: ${error.message}';
    } catch (error) {
      debugPrint('submit task failed: $error');
      return 'Koneksi ke server gagal. Periksa internet kamu lalu coba lagi.';
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Mengosongkan seluruh draft (foto, koordinat) setelah submit sukses.
  void reset() {
    _photoPath = null;
    _latitude = null;
    _longitude = null;
    notifyListeners();
  }

  void _showError(String message) {
    _lastError = message;
    debugPrint('TaskDraftProvider: $message');
  }
}
