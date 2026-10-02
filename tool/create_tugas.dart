import 'dart:io';

import 'generate_pertemuan.dart';

int parseTugasNumber(List<String> args) {
  if (args.length != 1) {
    throw const FormatException(
      'Penggunaan: dart run tool/create_tugas.dart <nomor>',
    );
  }

  final number = int.tryParse(args.single);
  if (number == null || number <= 0) {
    throw const FormatException('Nomor tugas harus bilangan bulat positif.');
  }

  return number;
}

String buildTugasPageSource(int number) =>
    '''
import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const TugasPertemuan${number}Page();

class TugasPertemuan${number}Page extends StatelessWidget {
  const TugasPertemuan${number}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tugas Pertemuan $number')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman template untuk Tugas Pertemuan $number. '
            'Silakan kembangkan tugas di file ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
''';

Directory createTugas({required Directory projectRoot, required int number}) {
  if (number <= 0) {
    throw ArgumentError.value(number, 'number', 'Harus lebih besar dari 0');
  }

  final destination = Directory(
    '${projectRoot.path}/lib/pertemuan/tugas_$number',
  );
  if (destination.existsSync()) {
    throw FileSystemException('Folder tugas sudah ada', destination.path);
  }

  destination.createSync(recursive: true);
  try {
    File(
      '${destination.path}/page.dart',
    ).writeAsStringSync(buildTugasPageSource(number), flush: true);
    generatePertemuanRegistry(projectRoot: projectRoot);
    return destination;
  } catch (_) {
    destination.deleteSync(recursive: true);
    rethrow;
  }
}

void main(List<String> args) {
  try {
    final number = parseTugasNumber(args);
    final directory = createTugas(
      projectRoot: Directory.current,
      number: number,
    );
    stdout.writeln('Tugas Pertemuan $number dibuat: ${directory.path}');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 64;
  }
}
