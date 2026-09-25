import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const Pertemuan3Page();

class Pertemuan3Page extends StatelessWidget {
  const Pertemuan3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pertemuan 3')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman template untuk Pertemuan 3. '
            'Silakan kembangkan materi di file ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
