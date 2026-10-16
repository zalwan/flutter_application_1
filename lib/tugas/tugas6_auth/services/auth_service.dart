import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../models/user_model.dart';

/// Service / Auth Provider untuk Tugas 6 (login NIM + register mahasiswa).
///
/// View tidak boleh menyentuh sqflite langsung — semua lewat sini.
class AuthService extends ChangeNotifier {
  AuthService({DatabaseHelper? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _db;

  UserModel? currentUser;
  ActiveSession? currentSession;
  bool isLoading = false;
  bool isCheckingSession = true;

  bool get isLoggedIn => currentUser != null;

  String _hash(String nim, String password) {
    final normalized = nim.trim();
    return base64Encode(utf8.encode('$normalized::$password'));
  }

  /// Dipanggil sekali saat app / halaman Tugas 6 start.
  Future<void> checkSession() async {
    isCheckingSession = true;
    notifyListeners();
    try {
      currentUser = await _db.checkSession();
      currentSession = currentUser == null
          ? null
          : await _db.getSession();
    } finally {
      isCheckingSession = false;
      notifyListeners();
    }
  }

  /// Return `null` jika sukses, atau pesan error untuk ditampilkan di UI.
  Future<String?> register({
    required String name,
    required String nim,
    required String password,
    required String prodi,
    required String kelas,
    required String gender,
    required int semester,
  }) async {
    isLoading = true;
    notifyListeners();
    try {
      final normalizedNim = nim.trim();
      final existing = await _db.getUserByNim(normalizedNim);
      if (existing != null) {
        return 'NIM sudah terdaftar. Silakan login.';
      }
      final id = await _db.insertUser(
        UserModel(
          name: name.trim(),
          nim: normalizedNim,
          passwordHash: _hash(normalizedNim, password),
          prodi: prodi,
          kelas: kelas,
          gender: gender,
          semester: semester,
          createdAt: DateTime.now(),
        ),
      );
      await _db.saveSession(userId: id, nim: normalizedNim);
      currentUser = await _db.getUserByNim(normalizedNim);
      currentSession = await _db.getSession();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Return `null` jika sukses, atau pesan error untuk ditampilkan di UI.
  Future<String?> login({required String nim, required String password}) async {
    isLoading = true;
    notifyListeners();
    try {
      final normalizedNim = nim.trim();
      final user = await _db.getUserByNim(normalizedNim);
      if (user == null ||
          user.passwordHash != _hash(normalizedNim, password)) {
        return 'NIM atau password salah.';
      }
      if (user.id == null) return 'Data user rusak. Daftar ulang.';
      await _db.saveSession(userId: user.id!, nim: user.nim);
      currentUser = user;
      currentSession = await _db.getSession();
      return null;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _db.clearSession();
    currentUser = null;
    currentSession = null;
    notifyListeners();
  }

  Future<void> refreshSessionInfo() async {
    currentSession = await _db.getSession();
    notifyListeners();
  }
}
