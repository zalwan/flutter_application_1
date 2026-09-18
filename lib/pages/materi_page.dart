import 'package:flutter/material.dart';

class Materi {
  final IconData icon;
  final String judul;
  final String deskripsi;
  final String detail;

  const Materi({
    required this.icon,
    required this.judul,
    required this.deskripsi,
    required this.detail,
  });
}

const List<Materi> daftarMateri = [
  Materi(
    icon: Icons.flutter_dash,
    judul: '1. Pengenalan Flutter',
    deskripsi: 'Apa itu Flutter, Dart, dan cara kerja widget.',
    detail:
        'Flutter adalah framework UI open-source dari Google untuk membuat aplikasi mobile, web, dan desktop dari satu codebase. Bahasa yang digunakan adalah Dart. Semua komponen di Flutter adalah Widget.',
  ),
  Materi(
    icon: Icons.widgets_outlined,
    judul: '2. Stateless vs Stateful Widget',
    deskripsi: 'Perbedaan widget statis dan dinamis.',
    detail:
        'StatelessWidget bersifat statis dan tidak berubah (contoh: Text, Icon). StatefulWidget bisa berubah saat runtime dengan setState() (contoh: counter, form input, checkbox).',
  ),
  Materi(
    icon: Icons.view_column_outlined,
    judul: '3. Layout: Row, Column, Stack',
    deskripsi: 'Menyusun tampilan dengan widget layout.',
    detail:
        'Row menyusun widget secara horizontal, Column secara vertikal, dan Stack menumpuk widget. Kombinasikan dengan Container, Padding, Center, Expanded, dan SingleChildScrollView untuk layout responsif.',
  ),
  Materi(
    icon: Icons.navigation_outlined,
    judul: '4. Navigasi & Routing',
    deskripsi: 'Pindah halaman dengan Navigator.',
    detail:
        'Gunakan Navigator.push() dengan MaterialPageRoute untuk pindah halaman, dan Navigator.pop() untuk kembali. Untuk app dengan tab, gunakan BottomNavigationBar seperti pada aplikasi ini.',
  ),
  Materi(
    icon: Icons.storage_outlined,
    judul: '5. State Management Dasar',
    deskripsi: 'Mengelola data dengan setState.',
    detail:
        'setState() memberi tahu Flutter untuk me-render ulang widget yang datanya berubah. Untuk aplikasi besar, pelajari Provider, Riverpod, atau Bloc.',
  ),
];

class MateriPage extends StatelessWidget {
  const MateriPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: daftarMateri.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Materi Mobile Programming',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Ketuk salah satu materi untuk melihat detail.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
            ],
          );
        }

        final materi = daftarMateri[index - 1];
        return Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor:
                  Theme.of(context).colorScheme.primaryContainer,
              child: Icon(materi.icon),
            ),
            title: Text(
              materi.judul,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(materi.deskripsi),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(materi.detail),
              ),
            ],
          ),
        );
      },
    );
  }
}
