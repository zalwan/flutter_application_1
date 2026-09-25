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
  });

  final int number;
  final String name;
  final Directory directory;
}

List<PertemuanFolder> discoverPertemuanFolders(Directory pertemuanRoot) {
  if (!pertemuanRoot.existsSync()) return [];

  final canonicalName = RegExp(r'^ptm_([1-9]\d*)$');
  final folders = <PertemuanFolder>[];
  final numbers = <int>{};

  for (final entity in pertemuanRoot.listSync(followLinks: false)) {
    if (entity is! Directory) continue;

    final name = entity.uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .last;
    if (!name.startsWith('ptm')) continue;

    final match = canonicalName.firstMatch(name);
    if (match == null) {
      throw PertemuanGenerationException(
        'Nama folder pertemuan tidak valid: ${entity.path}',
      );
    }

    final number = int.parse(match.group(1)!);
    if (!numbers.add(number)) {
      throw PertemuanGenerationException('Nomor pertemuan duplikat: $number');
    }

    if (!File('${entity.path}/page.dart').existsSync()) {
      throw PertemuanGenerationException(
        'page.dart tidak ditemukan di ${entity.path}',
      );
    }

    folders.add(PertemuanFolder(number: number, name: name, directory: entity));
  }

  folders.sort((a, b) => a.number.compareTo(b.number));
  return folders;
}

String buildRegistrySource(List<PertemuanFolder> folders) {
  final ordered = [...folders]..sort((a, b) => a.number.compareTo(b.number));
  final numbers = <int>{};

  for (final folder in ordered) {
    if (!numbers.add(folder.number)) {
      throw PertemuanGenerationException(
        'Nomor pertemuan duplikat: ${folder.number}',
      );
    }
  }

  final buffer = StringBuffer()
    ..writeln('// GENERATED CODE - DO NOT MODIFY BY HAND.')
    ..writeln()
    ..writeln("import '../pertemuan_item.dart';");

  for (final folder in ordered) {
    buffer.writeln(
      "import '../${folder.name}/page.dart' as ptm${folder.number};",
    );
  }

  buffer
    ..writeln()
    ..writeln('final List<PertemuanItem> daftarPertemuan = [');

  for (final folder in ordered) {
    buffer
      ..writeln('  PertemuanItem(')
      ..writeln('    nomor: ${folder.number},')
      ..writeln("    judul: 'Pertemuan ${folder.number}',")
      ..writeln('    pageBuilder: ptm${folder.number}.buildPertemuanPage,')
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
