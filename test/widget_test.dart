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
