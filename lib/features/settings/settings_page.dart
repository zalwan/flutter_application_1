import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Halaman pengaturan.
///
/// Menu pengelolaan data (create, read, update, delete) dokumen akan
/// ditambahkan pada pengembangan fitur CRUD.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const Text(
          'Pengaturan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Kelola data koleksi dokumen aplikasi.',
          style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.border),
          ),
          child: const Column(
            children: [
              Icon(Icons.tune_rounded, size: 42, color: AppTheme.textSecondary),
              SizedBox(height: 12),
              Text(
                'Menu pengelolaan dokumen akan tersedia di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
