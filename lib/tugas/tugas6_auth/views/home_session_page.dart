import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'auth_scope.dart';
import 'login_page.dart';

class HomeSessionPage extends StatelessWidget {
  const HomeSessionPage({super.key});

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthService>().logout();
    Fluttertoast.showToast(
      msg: 'Logout berhasil. Session dihapus.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    if (!context.mounted) return;
    pushAndRemoveUntilWithAuth(context, const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final user = auth.currentUser;
    final session = auth.currentSession;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas 6 - Home Session'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      (user?.name.isNotEmpty ?? false)
                          ? user!.name.substring(0, 1).toUpperCase()
                          : '?',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.name ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('NIM: ${user?.nim ?? '-'}'),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_outlined),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _InfoTile(
            icon: Icons.badge_outlined,
            title: 'NIM (SQLite UNIQUE)',
            value: user?.nim ?? '-',
          ),
          _InfoTile(
            icon: Icons.school_outlined,
            title: 'Program Studi',
            value: user?.prodi ?? '-',
          ),
          _InfoTile(
            icon: Icons.class_outlined,
            title: 'Kelas',
            value: user?.kelas ?? '-',
          ),
          _InfoTile(
            icon: Icons.wc_outlined,
            title: 'Jenis Kelamin',
            value: user?.gender ?? '-',
          ),
          _InfoTile(
            icon: Icons.timeline_outlined,
            title: 'Semester',
            value: user == null ? '-' : 'Semester ${user.semester}',
          ),
          _InfoTile(
            icon: Icons.login_outlined,
            title: 'Login At',
            value:
                session != null ? session.loginAt.toLocal().toString() : '-',
          ),
          _InfoTile(
            icon: Icons.timer_outlined,
            title: 'Expires At',
            value:
                session != null ? session.expiresAt.toLocal().toString() : '-',
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Anda masih logged in karena checkSession() menemukan '
                'baris valid di tabel active_session saat app start.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _logout(context),
            icon: const Icon(Icons.logout),
            label: const Text('Logout (hapus session)'),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, size: 20),
        ),
        title: Text(title, style: Theme.of(context).textTheme.bodySmall),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }
}
