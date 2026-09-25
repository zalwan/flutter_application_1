import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const Pertemuan2Page();

class Pertemuan2Page extends StatelessWidget {
  const Pertemuan2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pertemuan 2')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Membuat 3 pages HOME, MATERI, dan PROFILE',
            // 'Silakan kembangkan materi di file ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
