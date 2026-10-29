import 'package:flutter/material.dart';

/// Tema aplikasi: nuansa "kertas & tinta" hangat dengan aksen hijau daun.
/// Hijau dipilih karena konteks baca-tulis yang tenang, bukan warna tech
/// kebanyakan (biru-ungu).
abstract final class AppTheme {
  static const Color _seed = Color(0xFF2E6B4C);

  // Palet terang (light): kertas krem, tinta cokelat tua, aksen hijau.
  static const Color _paper = Color(0xFFF8F5EF);
  static const Color _ink = Color(0xFF201C16);
  static const Color _inkSoft = Color(0xFF6B665B);

  // Palet gelap (dark): kertas malam, tinta terang, aksen hijau mint.
  static const Color _paperDark = Color(0xFF1B1914);
  static const Color _inkDark = Color(0xFFE9E4D8);
  static const Color _inkSoftDark = Color(0xFFB6B0A2);

  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF93D8B5) : const Color(0xFF2E6B4C),
      onPrimary: isDark ? const Color(0xFF00391F) : Colors.white,
      primaryContainer:
          isDark ? const Color(0xFF135234) : const Color(0xFFCCE8D4),
      onPrimaryContainer:
          isDark ? const Color(0xFFCAEAD3) : const Color(0xFF0E3A25),
      surface: isDark ? _paperDark : _paper,
      surfaceContainerLowest:
          isDark ? const Color(0xFF161410) : const Color(0xFFFDFBF6),
      surfaceContainerLow:
          isDark ? const Color(0xFF201D18) : const Color(0xFFF2EEE6),
      surfaceContainer:
          isDark ? const Color(0xFF24211C) : const Color(0xFFECE7DD),
      surfaceContainerHigh:
          isDark ? const Color(0xFF2B2721) : const Color(0xFFE6E1D6),
      surfaceContainerHighest:
          isDark ? const Color(0xFF312C25) : const Color(0xFFE0DAD0),
      onSurface: isDark ? _inkDark : _ink,
      onSurfaceVariant: isDark ? _inkSoftDark : _inkSoft,
      outline: isDark ? const Color(0xFF837D70) : const Color(0xFF8A8478),
      outlineVariant:
          isDark ? const Color(0xFF3A362E) : const Color(0xFFD4CDBF),
    );

    final base = ThemeData(colorScheme: scheme, useMaterial3: true);

    return base.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: base.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: scheme.primaryContainer,
        labelStyle: base.textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        side: BorderSide.none,
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        showCheckmark: false,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: base.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      progressIndicatorTheme:
          ProgressIndicatorThemeData(color: scheme.primary),
      snackBarTheme: base.snackBarTheme.copyWith(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}