import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/native_service.dart';
import '../utils/error_messages.dart';
import 'new_task_screen.dart';
import 'todo_screen.dart';

/// Halaman utama Praktikum 10: navigasi TabLayout (TabBar + TabBarView).
///
/// Tab 1 memuat ulang halaman daftar To-DO lama (logika inti tidak diubah),
/// tab 2 memuat form tugas baru dengan integrasi kamera, GPS, dan notifikasi.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _client = Supabase.instance.client;

  String get _email =>
      _client.auth.currentUser?.email ?? '(email tidak tersedia)';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    _initializeMessaging();
  }

  Future<void> _requestPermissions() async {
    final results = await NativeService.requestCorePermissions();
    final denied = results.entries
        .where((entry) => !entry.value.isGranted && !entry.value.isLimited)
        .map((entry) => entry.key.toString())
        .toList();
    if (denied.isNotEmpty && mounted) {
      debugPrint('Permissions not granted: $denied');
    }
  }

  Future<void> _initializeMessaging() async {
    await NativeService.initializeMessaging(
      onForegroundMessage: _showForegroundMessage,
    );
  }

  /// Notifikasi saat aplikasi berada di depan (foreground) ditampilkan
  /// sebagai banner di dalam aplikasi, karena payload FCM tidak otomatis
  /// muncul di system tray ketika aplikasi terbuka.
  void _showForegroundMessage(RemoteMessage message) {
    if (!mounted) {
      return;
    }
    final title = message.notification?.title ?? 'Notifikasi baru';
    final body = message.notification?.body ?? message.data['title'] ?? '';
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 6),
          content: Text('$title\n$body'),
        ),
      );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar'),
        content: Text('Keluar dari akun $_email?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }
    try {
      await _client.auth.signOut();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(messageForError(error))),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('To-Do List'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'List Tugas'),
              Tab(icon: Icon(Icons.add_task), text: 'New Task'),
            ],
          ),
        ),
        body: Column(
          children: [
            _AccountHeader(email: _email, onLogout: _logout),
            const Expanded(
              child: TabBarView(
                children: [TodoListTab(), NewTaskScreen()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccountHeader extends StatelessWidget {
  const _AccountHeader({required this.email, required this.onLogout});

  final String email;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                child: Text(
                  email.isEmpty ? '?' : email.characters.first.toUpperCase(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Masuk sebagai', style: textTheme.labelMedium),
                    Text(
                      email,
                      style: textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: onLogout,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
