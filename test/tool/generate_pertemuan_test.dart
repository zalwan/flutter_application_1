import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/generate_pertemuan.dart';

void main() {
  late Directory projectRoot;

  setUp(() {
    projectRoot = Directory.systemTemp.createTempSync('pertemuan_generator_');
    Directory('${projectRoot.path}/lib/pertemuan').createSync(recursive: true);
  });

  tearDown(() => projectRoot.deleteSync(recursive: true));

  void addPage(String folder) {
    final directory = Directory('${projectRoot.path}/lib/pertemuan/$folder')
      ..createSync(recursive: true);
    File(
      '${directory.path}/page.dart',
    ).writeAsStringSync('Widget buildPertemuanPage() => throw 0;');
  }

  test('discovers canonical folders and orders their numbers numerically', () {
    addPage('ptm_10');
    addPage('ptm_2');
    addPage('ptm_3');

    final folders = discoverPertemuanFolders(
      Directory('${projectRoot.path}/lib/pertemuan'),
    );

    expect(folders.map((folder) => folder.number), [2, 3, 10]);
  });

  for (final invalidName in ['ptm-4', 'ptm_0', 'ptm_04']) {
    test('rejects non-canonical folder $invalidName', () {
      Directory('${projectRoot.path}/lib/pertemuan/$invalidName').createSync();

      expect(
        () => generatePertemuanRegistry(projectRoot: projectRoot),
        throwsA(
          isA<PertemuanGenerationException>().having(
            (error) => error.message,
            'message',
            contains(invalidName),
          ),
        ),
      );
    });
  }

  test('rejects duplicate numbers', () {
    final folder = PertemuanFolder(
      number: 2,
      name: 'ptm_2',
      directory: Directory('${projectRoot.path}/lib/pertemuan/ptm_2'),
    );

    expect(
      () => buildRegistrySource([folder, folder]),
      throwsA(isA<PertemuanGenerationException>()),
    );
  });

  test('missing page leaves the previous registry unchanged', () {
    final generatedDirectory = Directory(
      '${projectRoot.path}/lib/pertemuan/generated',
    )..createSync();
    final registry = File(
      '${generatedDirectory.path}/pertemuan_registry.g.dart',
    )..writeAsStringSync('existing registry');
    Directory('${projectRoot.path}/lib/pertemuan/ptm_2').createSync();

    expect(
      () => generatePertemuanRegistry(projectRoot: projectRoot),
      throwsA(isA<PertemuanGenerationException>()),
    );
    expect(registry.readAsStringSync(), 'existing registry');
  });

  test('writes sorted imports and entries after all input is valid', () {
    addPage('ptm_3');
    addPage('ptm_2');

    final output = generatePertemuanRegistry(projectRoot: projectRoot);
    final source = output.readAsStringSync();

    expect(
      source.indexOf('../ptm_2/page.dart'),
      lessThan(source.indexOf('../ptm_3/page.dart')),
    );
    expect(source, contains("judul: 'Pertemuan 2'"));
    expect(source, contains('pageBuilder: ptm2.buildPertemuanPage'));
  });
}
