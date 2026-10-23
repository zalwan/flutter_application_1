import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Menyiapkan data locale Indonesia untuk format tanggal pada halaman detail.
  await initializeDateFormatting('id_ID');
  runApp(const RizalDocsApp());
}
