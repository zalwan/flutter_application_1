import 'package:flutter/material.dart';

import '../pertemuan/generated/pertemuan_registry.g.dart';
import '../pertemuan/pertemuan_item.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    if (daftarPertemuan.isEmpty) {
      return const _EmptyPertemuan();
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: daftarPertemuan.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == 0) return const _HomeHeader();
        return _PertemuanCard(pertemuan: daftarPertemuan[index - 1]);
      },
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Pertemuan',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Pilih pertemuan untuk membuka halaman tugas atau materi.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _PertemuanCard extends StatelessWidget {
  const _PertemuanCard({required this.pertemuan});

  final PertemuanItem pertemuan;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: ValueKey('pertemuan-${pertemuan.nomor}-button'),
        borderRadius: borderRadius,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => pertemuan.pageBuilder()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text('${pertemuan.nomor}'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pertemuan.judul,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Buka halaman ${pertemuan.judul}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPertemuan extends StatelessWidget {
  const _EmptyPertemuan();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada pertemuan. Tambahkan dengan menjalankan:\n'
          'dart run tool/create_pertemuan.dart <nomor>',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
