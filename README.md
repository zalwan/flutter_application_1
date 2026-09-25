# Mobile Programming UNPAM

A Flutter application for organizing assignments or learning materials by meeting. The Home page reads a generated registry and displays each meeting as a clickable button.

## Adding a Meeting

The recommended approach is to use the template generator:

```bash
dart run tool/create_pertemuan.dart 4
```

This command creates `lib/pertemuan/ptm_4/page.dart` and immediately updates the registry. Replace `4` with the meeting number you want to add.

Every `page.dart` file must expose the following function:

```dart
Widget buildPertemuanPage();
```

Meeting folders must use the `ptm_<number>` format, such as `ptm_5`. The number must be a positive integer without leading zeros.

If you create or modify a folder manually, update the registry with:

```bash
dart run tool/generate_pertemuan.dart
```

The `lib/pertemuan/generated/pertemuan_registry.g.dart` file is generated automatically and must not be edited manually.

## Running the Application

```bash
flutter run
```

## Project Checks

```bash
flutter analyze
flutter test
```
