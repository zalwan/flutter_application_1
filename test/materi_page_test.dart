import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/pages/materi_page.dart';

void main() {
  test('curriculum progresses from basic to advanced topics', () {
    expect(daftarMateri.length, greaterThanOrEqualTo(15));
    expect(
      daftarMateri.map((materi) => materi.tingkat).toSet(),
      TingkatMateri.values.toSet(),
    );

    final levels = daftarMateri.map((materi) => materi.tingkat.index).toList();
    expect(levels, orderedEquals([...levels]..sort()));

    final titles = daftarMateri.map((materi) => materi.judul).join(' ');
    expect(titles, contains('Performance'));
    expect(titles, contains('Security'));
    expect(titles, contains('CI/CD'));
  });

  testWidgets('material cards show their level and expandable detail', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MateriPage())),
    );

    expect(find.text('Dasar'), findsWidgets);

    await tester.tap(find.text('1. Pengenalan Flutter & Dart'));
    await tester.pumpAndSettle();

    expect(find.textContaining('SDK UI lintas platform'), findsOneWidget);
  });
}
