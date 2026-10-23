import 'package:intl/intl.dart';

/// Memformat tanggal menjadi teks berbahasa Indonesia,
/// contoh: `18 Juni 2024`.
String formatTanggalPanjang(DateTime date) {
  return DateFormat('d MMMM y', 'id_ID').format(date);
}
