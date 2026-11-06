import 'package:flutter/material.dart';

class SetupRequiredScreen extends StatelessWidget {
  const SetupRequiredScreen({super.key});

  static const _runCommand =
      'flutter run --dart-define-from-file=dart_defines.json';

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Konfigurasi Supabase')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.settings_suggest_outlined,
                  size: 56,
                  color: colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Kredensial Supabase belum diisi',
                  style: textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Aplikasi butuh Supabase URL dan publishable key untuk bisa '
                  'login dan menyimpan to-do.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 24),
                const Text('1. Isi file dart_defines.json di root project:'),
                const SizedBox(height: 8),
                const SelectableText(
                  '{\n'
                  '  "SUPABASE_URL": "https://xxxx.supabase.co",\n'
                  '  "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."\n'
                  '}',
                ),
                const SizedBox(height: 16),
                const Text('2. Jalankan ulang aplikasi dengan perintah:'),
                const SizedBox(height: 8),
                const SelectableText(_runCommand),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
