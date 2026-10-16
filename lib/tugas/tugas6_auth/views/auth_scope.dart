import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

/// Helper navigasi Tugas 6.
///
/// Provider yang dipasang di `TugasPertemuan6Page` bersifat *scoped*
/// (hanya berlaku di route itu). `Navigator.push` biasa membuat route
/// baru yang BUKAN turunan provider tersebut, sehingga `RegisterPage`
/// / `HomeSessionPage` akan kena `ProviderNotFoundException`.
///
/// Semua push di flow auth WAJIB lewat helper ini agar instance
/// `AuthService` yang sama diteruskan via `ChangeNotifierProvider.value`.
Future<T?> pushWithAuth<T>(BuildContext context, Widget page) {
  final auth = context.read<AuthService>();
  return Navigator.of(context).push<T>(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: page,
      ),
    ) as Route<T>,
  );
}

Future<T?> pushReplacementWithAuth<T>(BuildContext context, Widget page) {
  final auth = context.read<AuthService>();
  return Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(
      builder: (_) => ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: page,
      ),
    ) as Route<T>,
  );
}

Future<T?> pushAndRemoveUntilWithAuth<T>(
  BuildContext context,
  Widget page,
) {
  final auth = context.read<AuthService>();
  return Navigator.of(context).pushAndRemoveUntil<T>(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<AuthService>.value(
        value: auth,
        child: page,
      ),
    ),
    (_) => false,
  );
}
