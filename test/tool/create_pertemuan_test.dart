import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/create_pertemuan.dart';

void main() {
  late Directory projectRoot;

  setUp(() {
    projectRoot = Directory.systemTemp.createTempSync('pertemuan_creator_');
    Directory('${projectRoot.path}/lib/pertemuan').createSync(recursive: true);
  });

  tearDown(() => projectRoot.deleteSync(recursive: true));

  test('creates a page template and refreshes the registry', () {
    final directory = createPertemuan(projectRoot: projectRoot, number: 4);

    expect(directory.path, endsWith('lib/pertemuan/ptm_4'));
    expect(
      File('${directory.path}/page.dart').readAsStringSync(),
      contains('class Pertemuan4Page'),
    );
    expect(
      File(
        '${projectRoot.path}/lib/pertemuan/generated/'
        'pertemuan_registry.g.dart',
      ).readAsStringSync(),
      contains("judul: 'Pertemuan 4'"),
    );
  });

  for (final invalidNumber in [0, -1]) {
    test('rejects invalid number $invalidNumber', () {
      expect(
        () => createPertemuan(projectRoot: projectRoot, number: invalidNumber),
        throwsA(isA<ArgumentError>()),
      );
    });
  }

  for (final invalidArgs in <List<String>>[
    [],
    ['abc'],
    ['2', '3'],
  ]) {
    test('rejects invalid CLI arguments $invalidArgs', () {
      expect(
        () => parsePertemuanNumber(invalidArgs),
        throwsA(isA<FormatException>()),
      );
    });
  }

  test('does not overwrite an existing destination', () {
    final page = File('${projectRoot.path}/lib/pertemuan/ptm_4/page.dart')
      ..createSync(recursive: true)
      ..writeAsStringSync('user content');

    expect(
      () => createPertemuan(projectRoot: projectRoot, number: 4),
      throwsA(isA<FileSystemException>()),
    );
    expect(page.readAsStringSync(), 'user content');
  });
}
