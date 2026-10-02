import 'dart:io';

class PertemuanGenerationException implements Exception {
  const PertemuanGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PertemuanFolder {
  const PertemuanFolder({
    required this.number,
    required this.name,
    required this.directory,
    required this.kind,
  });

  final int number;
  final String name;
  final Directory directory;
  final String kind; // 'ptm' atau 'tugas'

  String get alias => '$kind$number';

  String get judul =>
      kind == 'tugas' ? 'Tugas Pertemuan $number' : 'Pertemuan $number';
}

List<PertemuanFolder> discoverPertemuanFolders(Directory pertemuanRoot) {
  if (!pertemuanRoot.existsSync()) return [];

  final canonicalName = RegExp(r'^(ptm|tugas)_([1-9]\d*)$');
  final folders = <PertemuanFolder>[];
  final keys = <String>{};

  for (final entity in pertemuanRoot.listSync(followLinks: false)) {
    if (entity is! Directory) continue;

    final name = entity.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    if (!name.startsWith('ptm') && !name.startsWith('tugas')) continue;

    final match = canonicalName.firstMatch(name);
    if (match == null) {
      throw PertemuanGenerationException(
        'Nama folder tidak valid: ${entity.path} '
        '(gunakan ptm_<nomor> atau tugas_<nomor>)',
      );
    }

    final kind = match.group(1)!;
    final number = int.parse(match.group(2)!);
    if (!keys.add('$kind$number')) {
      throw PertemuanGenerationException(
        'Duplikat folder: $kind $number',
      );
    }

    if (!File('${entity.path}/page.dart').existsSync()) {
      throw PertemuanGenerationException(
        'page.dart tidak ditemukan di ${entity.path}',
      );
    }

    folders.add(PertemuanFolder(
      number: number,
      name: name,
      directory: entity,
      kind: kind,
    ));
  }

  folders.sort((a, b) {
    final byNumber = a.number.compareTo(b.number);
    if (byNumber != 0) return byNumber;
    return a.kind == 'ptm' ? -1 : 1;
  });
  return folders;
}

String buildRegistrySource(List<PertemuanFolder> folders) {
  final ordered = [...folders]..sort((a, b) {
    final byNumber = a.number.compareTo(b.number);
    if (byNumber != 0) return byNumber;
    return a.kind == 'ptm' ? -1 : 1;
  });

  final aliases = <String>{};
  for (final folder in ordered) {
    if (!aliases.add(folder.alias)) {
      throw PertemuanGenerationException(
        'Duplikat folder: ${folder.kind} ${folder.number}',
      );
    }
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln()
    ..writeln("import '../pertemuan_item.dart';");

  for (final folder in ordered) {
    buffer.writeln(
      "import '../${folder.name}/page.dart' as ${folder.alias};",
    );
  }

  buffer
    ..writeln()
    ..writeln('final List<PertemuanItem> daftarPertemuan = [');

  for (final folder in ordered) {
    buffer
      ..writeln('  PertemuanItem(')
      ..writeln('    nomor: ${folder.number},')
      ..writeln("    judul: '${folder.judul}',")
      ..writeln('    pageBuilder: ${folder.alias}.buildPertemuanPage,')
      ..writeln('  ),');
  }

  buffer.writeln('];');
  return buffer.toString();
}

File generatePertemuanRegistry({required Directory projectRoot}) {
  final root = Directory('${projectRoot.path}/lib/pertemuan');
  final folders = discoverPertemuanFolders(root);
  final source = buildRegistrySource(folders);
  final generated = Directory('${root.path}/generated')
    ..createSync(recursive: true);
  final target = File('${generated.path}/pertemuan_registry.g.dart');
  final temporary = File('${target.path}.tmp');

  try {
    temporary.writeAsStringSync(source, flush: true);
    temporary.renameSync(target.path);
  } finally {
    if (temporary.existsSync()) temporary.deleteSync();
  }

  return target;
}

void main(List<String> args) {
  try {
    final output = generatePertemuanRegistry(projectRoot: Directory.current);
    stdout.writeln('Registry diperbarui: ${output.path}');
  } on PertemuanGenerationException catch (error) {
    stderr.writeln(error.message);
    exitCode = 64;
  }
}
