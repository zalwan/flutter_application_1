import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  // Data dari data-diri.md
  final String name = 'RIZAL SURYAWAN';
  final String nim = '241011750067';
  final String jurusan = 'SISTEM INFORMASI';
  final String matkuliah = 'MOBILE PROGRAMMING';
  final String kelas = 'SIFE002';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primary,
                  child: Text(
                    _initials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'NIM: $nim',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                Chip(
                  label: Text(kelas),
                  avatar: const Icon(Icons.class_outlined, size: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _InfoTile(
            icon: Icons.school_outlined,
            title: 'Jurusan',
            value: jurusan,
          ),
          _InfoTile(
            icon: Icons.book_outlined,
            title: 'Mata Kuliah',
            value: matkuliah,
          ),
          _InfoTile(
            icon: Icons.badge_outlined,
            title: 'NIM',
            value: nim,
          ),
          _InfoTile(
            icon: Icons.group_outlined,
            title: 'Kelas',
            value: kelas,
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: colorScheme.secondaryContainer,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.verified_outlined),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tugas Mobile Programming — Aplikasi 3 halaman: Home, Materi, Profile.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, size: 20),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        subtitle: Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
