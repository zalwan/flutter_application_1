import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/post.dart';

/// Jenis kegagalan saat memanggil API, agar UI bisa menampilkan pesan yang
/// sesuai untuk tiap kasus.
enum ApiErrorKind { network, timeout, server, invalidResponse }

/// Exception khusus untuk error dari proses API.
class ApiException implements Exception {
  const ApiException(this.kind, this.message);

  final ApiErrorKind kind;
  final String message;

  @override
  String toString() => message;
}

/// Service yang membungkus semua pemanggilan REST API.
///
/// Di sini hanya ada operasi baca (GET), karena API publik
/// https://zal.pages.dev/api-docs memang read-only.
class PostApiService {
  PostApiService({http.Client? client}) : _client = client ?? http.Client();

  static const String baseUrl = 'https://zal.pages.dev';

  final http.Client _client;

  /// Header default untuk setiap permintaan.
  ///
  /// Penjelasan tentang header apikey dan Authorization:
  ///
  /// 1. `apikey` — header untuk mengirim API key, sebuah kunci rahasia yang
  ///    mengidentifikasi aplikasi/klien yang memanggil API (dipakai misalnya
  ///    oleh Supabase). Fungsinya untuk validasi: server hanya melayani
  ///    permintaan dari aplikasi yang memiliki kunci sah, dan bisa
  ///    menerapkan rate limit per kunci.
  ///
  /// 2. `Authorization` — header untuk autentikasi pengguna, biasanya berisi
  ///    token: `Authorization: Bearer <token>`. Token diperoleh setelah login
  ///    dan memberitahu server "siapa" yang mengakses, sehingga server bisa
  ///    membatasi data sesuai hak akses user tersebut.
  ///
  /// API ini TIDAK memerlukan keduanya — dokumentasinya menyatakan "No API
  /// key required", cukup GET biasa. Jika suatu saat memakai API ber-Auth
  /// (misal Supabase), tinggal aktifkan baris di bawah ini.
  Map<String, String> _defaultHeaders() {
    return {
      'Accept': 'application/json',
      // 'apikey': '<API_KEY_ANDA>',
      // 'Authorization': 'Bearer <TOKEN_LOGIN>',
    };
  }

  /// Mengambil daftar artikel: `GET /api/v1/posts.json`.
  ///
  /// Metode HTTP yang sesuai untuk operasi "membaca data" adalah GET.
  /// (POST untuk membuat, PUT/PATCH untuk mengubah, DELETE untuk menghapus —
  /// API ini tidak menyediakannya.)
  Future<List<Post>> fetchPosts() async {
    final uri = Uri.parse('$baseUrl/api/v1/posts.json');

    try {
      // Timeout mencegah aplikasi menggantung saat koneksi lambat.
      final response = await _client
          .get(uri, headers: _defaultHeaders())
          .timeout(const Duration(seconds: 15));

      // --- Menangani respons dari server berdasarkan status code ---

      // 2xx = berhasil.
      if (response.statusCode == 200) {
        // Cek Content-Type dulu: error body tidak dijamin JSON.
        final contentType = response.headers['content-type'] ?? '';
        if (!contentType.contains('application/json')) {
          throw const ApiException(
            ApiErrorKind.invalidResponse,
            'Server mengembalikan tipe data yang tidak dikenali.',
          );
        }

        final body = jsonDecode(response.body) as Map<String, dynamic>;
        final items = body['data'] as List<dynamic>? ?? const [];
        return items
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Selain 2xx = gagal (404, 500, dll).
      throw ApiException(
        ApiErrorKind.server,
        'Server gagal memproses permintaan (HTTP ${response.statusCode}).',
      );
    } on TimeoutException {
      // Server tidak merespons dalam batas waktu.
      throw const ApiException(
        ApiErrorKind.timeout,
        'Waktu permintaan habis. Periksa koneksi Anda lalu coba lagi.',
      );
    } on SocketException {
      // Gagal di level jaringan (tidak ada internet, DNS error, dst).
      throw const ApiException(
        ApiErrorKind.network,
        'Tidak ada koneksi internet.',
      );
    } on http.ClientException {
      throw const ApiException(
        ApiErrorKind.network,
        'Gagal terhubung ke server.',
      );
    } on FormatException {
      // JSON-nya tidak sesuai bentuk yang kita harapkan.
      throw const ApiException(
        ApiErrorKind.invalidResponse,
        'Format data dari server tidak valid.',
      );
    }
  }

  void dispose() => _client.close();
}