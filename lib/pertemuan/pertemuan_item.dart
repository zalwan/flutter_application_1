import 'package:flutter/widgets.dart';

typedef PertemuanPageBuilder = Widget Function();

class PertemuanItem {
  const PertemuanItem({
    required this.nomor,
    required this.judul,
    required this.pageBuilder,
  });

  final int nomor;
  final String judul;
  final PertemuanPageBuilder pageBuilder;
}
