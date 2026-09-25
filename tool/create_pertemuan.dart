import 'dart:io';

import 'generate_pertemuan.dart';

int parsePertemuanNumber(List<String> args) {
  if (args.length != 1) {
    throw const FormatException(
      'Penggunaan: dart run tool/create_pertemuan.dart <nomor>',
    );
  }

  final number = int.tryParse(args.single);
  if (number == null || number <= 0) {
    throw const FormatException(
      'Nomor pertemuan harus bilangan bulat positif.',
    );
  }

  return number;
}

String buildPertemuanPageSource(int number) =>
    '''
import 'package:flutter/material.dart';

Widget buildPertemuanPage() => const Pertemuan${number}Page();

class Pertemuan${number}Page extends StatelessWidget {
  const Pertemuan${number}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pertemuan $number')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Halaman template untuk Pertemuan $number. '
            'Silakan kembangkan materi di file ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
''';

Directory createPertemuan({
  required Directory projectRoot,
  required int number,
}) {
  if (number <= 0) {
    throw ArgumentError.value(number, 'number', 'Harus lebih besar dari 0');
  }

  final destination = Directory(
    '${projectRoot.path}/lib/pertemuan/ptm_$number',
  );
  if (destination.existsSync()) {
    throw FileSystemException('Folder pertemuan sudah ada', destination.path);
  }

  destination.createSync(recursive: true);
  try {
    File(
      '${destination.path}/page.dart',
    ).writeAsStringSync(buildPertemuanPageSource(number), flush: true);
    generatePertemuanRegistry(projectRoot: projectRoot);
    return destination;
  } catch (_) {
    destination.deleteSync(recursive: true);
    rethrow;
  }
}

void main(List<String> args) {
  try {
    final number = parsePertemuanNumber(args);
    final directory = createPertemuan(
      projectRoot: Directory.current,
      number: number,
    );
    stdout.writeln('Pertemuan $number dibuat: ${directory.path}');
  } on FormatException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  } on Object catch (error) {
    stderr.writeln(error);
    exitCode = 64;
  }
}
