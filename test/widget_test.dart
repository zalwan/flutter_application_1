import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/models/post.dart';
import 'package:flutter_application_1/screens/post_list_screen.dart';
import 'package:flutter_application_1/services/post_api_service.dart';

class _FakeApiService extends PostApiService {
  _FakeApiService({this.error});

  final ApiException? error;

  @override
  Future<List<Post>> fetchPosts() async {
    if (error != null) throw error!;
    return [
      Post(
        slug: 'contoh-artikel',
        title: 'Contoh Artikel',
        description: 'Deskripsi artikel untuk pengujian.',
        publishedAt: DateTime(2026, 8, 14),
        tags: const ['Flutter', 'API'],
        readingMinutes: 5,
        url: 'https://zal.pages.dev/blog/contoh-artikel',
      ),
    ];
  }
}

void main() {
  testWidgets('menampilkan daftar artikel saat API berhasil', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: PostListScreen(apiService: _FakeApiService())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Contoh Artikel'), findsOneWidget);
    expect(find.text('14 Agu 2026'), findsOneWidget);
    expect(find.text('5 mnt baca'), findsOneWidget);
  });

  testWidgets('menampilkan pesan error saat API gagal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PostListScreen(
          apiService: _FakeApiService(
            error: const ApiException(
              ApiErrorKind.network,
              'Tidak ada koneksi internet.',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tidak ada koneksi internet.'), findsOneWidget);
    expect(find.text('Coba lagi'), findsOneWidget);
  });
}