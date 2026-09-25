# Dynamic Pertemuan Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Home content with an ordered, clickable list of pertemuan pages and provide dependency-free commands that create template folders and regenerate the compile-time registry.

**Architecture:** A Dart generator scans canonical `lib/pertemuan/ptm_<number>/page.dart` entries and writes a typed Flutter registry. A companion creator command adds one template folder and invokes the same generator; Home renders the generated registry and navigates to each page through its builder function.

**Tech Stack:** Dart 3.12, Flutter Material 3, `dart:io`, `flutter_test`; no additional package dependencies.

**Spec:** `docs/superpowers/specs/2026-09-25-dynamic-pertemuan-design.md`

## Global Constraints

- Keep the existing bottom navigation destinations: Home, Materi, and Profile.
- Do not move existing Home, Materi, or Profile content into a pertemuan folder.
- Use canonical folder names matching `ptm_<positive integer>` with no leading zero.
- Every valid pertemuan folder must contain `page.dart` and expose `Widget buildPertemuanPage()`.
- Generated registry files are never edited manually.
- Add no third-party dependencies.
- Validate every folder before replacing the existing registry.

## Review Focus

- Directories such as `ptm-4`, `ptm_0`, and `ptm_04` must fail generation with the offending path in the message; covered by Task 1 validation tests.
- A pertemuan directory without `page.dart` must fail without changing an existing registry; covered by Task 1 preservation test.
- Duplicate meeting numbers supplied to registry generation must fail instead of producing ambiguous navigation; covered by Task 1 duplicate-number unit test.
- Creator input `0`, negative values, non-integers, and an existing destination must fail without overwriting user content; covered by Task 2 command tests.
- Numeric ordering must place `ptm_10` after `ptm_3`, and navigation must open the builder belonging to the tapped card; covered by Task 1 ordering and Task 3 widget tests.

---

### Task 1: Transactional Pertemuan Registry Generator

**Files:**
- Create: `tool/generate_pertemuan.dart`
- Create: `test/tool/generate_pertemuan_test.dart`

**Interfaces:**
- Consumes: project root containing `lib/pertemuan/ptm_<number>/page.dart` directories.
- Produces: `List<PertemuanFolder> discoverPertemuanFolders(Directory pertemuanRoot)`, `String buildRegistrySource(List<PertemuanFolder> folders)`, and `File generatePertemuanRegistry({required Directory projectRoot})`.

- [ ] **Step 1: Write failing discovery, ordering, and registry-preservation tests**

Create `test/tool/generate_pertemuan_test.dart` with temporary-directory setup and these concrete cases:

```dart
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
    final directory =
        Directory('${projectRoot.path}/lib/pertemuan/$folder')
          ..createSync(recursive: true);
    File('${directory.path}/page.dart')
        .writeAsStringSync('Widget buildPertemuanPage() => throw 0;');
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
      Directory('${projectRoot.path}/lib/pertemuan/$invalidName')
          .createSync();

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
    final generatedDirectory =
        Directory('${projectRoot.path}/lib/pertemuan/generated')
          ..createSync();
    final registry =
        File('${generatedDirectory.path}/pertemuan_registry.g.dart')
          ..writeAsStringSync('existing registry');
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
      source.indexOf("../ptm_2/page.dart"),
      lessThan(source.indexOf("../ptm_3/page.dart")),
    );
    expect(source, contains("judul: 'Pertemuan 2'"));
    expect(source, contains('pageBuilder: ptm2.buildPertemuanPage'));
  });
}
```

- [ ] **Step 2: Run the generator tests and confirm the expected failure**

Run:

```bash
flutter test test/tool/generate_pertemuan_test.dart
```

Expected: compilation fails because `tool/generate_pertemuan.dart` and its public interfaces do not exist.

- [ ] **Step 3: Implement the generator with validation before file replacement**

Create `tool/generate_pertemuan.dart` with these public types and discovery behavior:

```dart
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
    folders.add(
      PertemuanFolder(number: number, name: name, directory: entity),
    );
  }

  folders.sort((a, b) => a.number.compareTo(b.number));
  return folders;
}
```

Add the registry rendering, transactional file replacement, and CLI entry point:

```dart
String buildRegistrySource(List<PertemuanFolder> folders) {
  final ordered = [...folders]
    ..sort((a, b) => a.number.compareTo(b.number));
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
      ..writeln(
        '    pageBuilder: ptm${folder.number}.buildPertemuanPage,',
      )
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
```

- [ ] **Step 4: Run and format the generator tests**

Run:

```bash
dart format tool/generate_pertemuan.dart test/tool/generate_pertemuan_test.dart
flutter test test/tool/generate_pertemuan_test.dart
```

Expected: all generator tests pass.

- [ ] **Step 5: Commit the transactional generator**

```bash
git add tool/generate_pertemuan.dart test/tool/generate_pertemuan_test.dart
git commit -m "feat: add pertemuan registry generator"
```

### Task 2: Template Creator and Initial Pertemuan Pages

**Files:**
- Create: `tool/create_pertemuan.dart`
- Create: `test/tool/create_pertemuan_test.dart`
- Create: `lib/pertemuan/pertemuan_item.dart`
- Create: `lib/pertemuan/ptm_2/page.dart`
- Create: `lib/pertemuan/ptm_3/page.dart`
- Create: `lib/pertemuan/generated/pertemuan_registry.g.dart`

**Interfaces:**
- Consumes: `generatePertemuanRegistry({required Directory projectRoot})` from Task 1.
- Produces: `int parsePertemuanNumber(List<String> args)`, `Directory createPertemuan({required Directory projectRoot, required int number})`; Flutter pages expose `Widget buildPertemuanPage()`; generated registry exposes `final List<PertemuanItem> daftarPertemuan`.

- [ ] **Step 1: Write failing creator tests**

Create `test/tool/create_pertemuan_test.dart`:

```dart
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
      File('${projectRoot.path}/lib/pertemuan/generated/'
              'pertemuan_registry.g.dart')
          .readAsStringSync(),
      contains("judul: 'Pertemuan 4'"),
    );
  });

  for (final invalidNumber in [0, -1]) {
    test('rejects invalid number $invalidNumber', () {
      expect(
        () => createPertemuan(
          projectRoot: projectRoot,
          number: invalidNumber,
        ),
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
```

- [ ] **Step 2: Run the creator tests and confirm the expected failure**

Run:

```bash
flutter test test/tool/create_pertemuan_test.dart
```

Expected: compilation fails because `tool/create_pertemuan.dart` does not exist.

- [ ] **Step 3: Implement the typed model, creator API, and CLI parsing**

Create `lib/pertemuan/pertemuan_item.dart`:

```dart
import 'package:flutter/widgets.dart';

typedef PertemuanPageBuilder = Widget Function();

class PertemuanItem {
  const PertemuanItem({
    required this.nomor,
    required this.judul,
    required this.pageBuilder,
  });

  final int nomor;
  final String judul;
  final PertemuanPageBuilder pageBuilder;
}
```

Create `tool/create_pertemuan.dart` with the following behavior. The generated body text is fixed so widget assertions remain stable:

```dart
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
    throw const FormatException('Nomor pertemuan harus bilangan bulat positif.');
  }
  return number;
}

String buildPertemuanPageSource(int number) => '''
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
  final destination =
      Directory('${projectRoot.path}/lib/pertemuan/ptm_$number');
  if (destination.existsSync()) {
    throw FileSystemException('Folder pertemuan sudah ada', destination.path);
  }

  destination.createSync(recursive: true);
  try {
    File('${destination.path}/page.dart')
        .writeAsStringSync(buildPertemuanPageSource(number), flush: true);
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
```

- [ ] **Step 4: Run creator tests, then create PTM 2 and PTM 3 through the public command**

Run:

```bash
dart format tool/create_pertemuan.dart lib/pertemuan/pertemuan_item.dart test/tool/create_pertemuan_test.dart
flutter test test/tool/create_pertemuan_test.dart
dart run tool/create_pertemuan.dart 2
dart run tool/create_pertemuan.dart 3
dart format lib/pertemuan
```

Expected: tests pass; both template directories exist; registry lists 2 before 3.

- [ ] **Step 5: Confirm the generated registry and pages compile**

Run:

```bash
flutter analyze lib/pertemuan
```

Expected: no issues found.

- [ ] **Step 6: Commit the creator, model, templates, and generated registry**

```bash
git add tool/create_pertemuan.dart test/tool/create_pertemuan_test.dart lib/pertemuan
git commit -m "feat: add pertemuan template creator"
```

### Task 3: Dynamic Home Buttons and Navigation

**Files:**
- Modify: `lib/pages/home_page.dart`
- Modify: `test/widget_test.dart`

**Interfaces:**
- Consumes: `daftarPertemuan` and each `PertemuanItem.pageBuilder` from Task 2.
- Produces: Home cards keyed as `ValueKey('pertemuan-<number>-button')` that push the selected page.

- [ ] **Step 1: Replace the stale counter test with failing Home and navigation tests**

Replace `test/widget_test.dart` with:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('Home lists pertemuan in numeric order', (tester) async {
    await tester.pumpWidget(const MyApp());

    final ptm2 = find.byKey(const ValueKey('pertemuan-2-button'));
    final ptm3 = find.byKey(const ValueKey('pertemuan-3-button'));

    expect(ptm2, findsOneWidget);
    expect(ptm3, findsOneWidget);
    expect(tester.getTopLeft(ptm2).dy, lessThan(tester.getTopLeft(ptm3).dy));
  });

  testWidgets('tapping a pertemuan opens its generated page', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const ValueKey('pertemuan-2-button')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Halaman template untuk Pertemuan 2.'),
      findsOneWidget,
    );
    expect(find.byType(BackButton), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run the widget tests and confirm the expected failure**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: tests fail because Home does not expose pertemuan cards.

- [ ] **Step 3: Replace Home's static menu with registry-backed cards**

Import `../pertemuan/generated/pertemuan_registry.g.dart` and render a `ListView.separated`. Keep a compact introductory heading, then render one Material card per item. Each tappable card must use:

```dart
key: ValueKey('pertemuan-${pertemuan.nomor}-button'),
onTap: () {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => pertemuan.pageBuilder()),
  );
},
```

Show `pertemuan.judul`, the subtitle `Buka halaman ${pertemuan.judul}`, a numbered circular avatar, and a trailing chevron. When `daftarPertemuan` is empty, show centered text explaining that `dart run tool/create_pertemuan.dart <nomor>` adds the first entry.

- [ ] **Step 4: Format, analyze, and run widget tests**

Run:

```bash
dart format lib/pages/home_page.dart test/widget_test.dart
flutter analyze lib/pages/home_page.dart test/widget_test.dart
flutter test test/widget_test.dart
```

Expected: analyzer and both widget tests pass.

- [ ] **Step 5: Commit the dynamic Home page**

```bash
git add lib/pages/home_page.dart test/widget_test.dart
git commit -m "feat: show generated pertemuan on home"
```

### Task 4: Usage Documentation and End-to-End Verification

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: the two tool commands and folder contract from Tasks 1-2.
- Produces: contributor instructions for safely adding and regenerating pertemuan pages.

- [ ] **Step 1: Document the normal and manual workflows**

Replace the generic README introduction with the app purpose, then include these exact commands and explanations:

```bash
dart run tool/create_pertemuan.dart 4
dart run tool/generate_pertemuan.dart
flutter run
```

Explain that the first command is preferred, the second is required after manually adding a canonical folder, each page exposes `Widget buildPertemuanPage()`, and `lib/pertemuan/generated/pertemuan_registry.g.dart` must not be edited by hand.

- [ ] **Step 2: Run the generator and verify its committed output is current**

Run:

```bash
dart run tool/generate_pertemuan.dart
git diff --exit-code -- lib/pertemuan/generated/pertemuan_registry.g.dart
```

Expected: generator succeeds and the diff command exits 0.

- [ ] **Step 3: Run complete static analysis and tests**

Run:

```bash
dart format --output=none --set-exit-if-changed lib tool test
flutter analyze
flutter test
```

Expected: formatter exits 0, analyzer reports no issues, and all tests pass.

- [ ] **Step 4: Commit documentation**

```bash
git add README.md
git commit -m "docs: explain pertemuan generation workflow"
```

- [ ] **Step 5: Confirm the worktree contains no unintended changes**

Run:

```bash
git status --short
git log -5 --oneline
```

Expected: status is clean and the feature commits appear above the design and plan commits.
