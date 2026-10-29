import 'package:flutter/material.dart';

import '../models/post.dart';
import 'post_webview_screen.dart';

/// Halaman detail sebuah artikel.
class PostDetailScreen extends StatelessWidget {
  const PostDetailScreen({super.key, required this.post});

  final Post post;

  /// Membuka isi artikel lewat WebView di dalam app (tanpa keluar ke browser).
  void _openArticle(BuildContext context) {
    final uri = Uri.tryParse(post.url);
    if (uri == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PostWebViewScreen(url: post.url, title: post.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final image = post.image;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: scheme.surface,
            surfaceTintColor: Colors.transparent,
            title: const Text('Artikel'),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (image != null && image.url.isNotEmpty) ...[
                    _HeroImage(image: image),
                    const SizedBox(height: 20),
                  ],
                  Text(
                    post.title,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _MetaLine(
                    publishedLabel: post.publishedLabel,
                    readingMinutes: post.readingMinutes,
                  ),
                  if (post.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final tag in post.tags) Chip(label: Text(tag)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  Text(
                    post.description,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: FilledButton.icon(
          onPressed: () => _openArticle(context),
          icon: const Icon(Icons.menu_book_outlined),
          label: const Text('Baca artikel'),
        ),
      ),
    );
  }
}

/// Cover artikel yang besar, dengan fallback bila gambar gagal dimuat.
class _HeroImage extends StatelessWidget {
  const _HeroImage({required this.image});

  final PostImage image;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        image.url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        semanticLabel: image.alt.isEmpty ? null : image.alt,
        errorBuilder: (_, _, _) => Container(
          width: double.infinity,
          height: 220,
          color: scheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.image_not_supported_outlined,
              color: scheme.onSurfaceVariant,
              size: 40,
            ),
          ),
        ),
      ),
    );
  }
}

/// Baris tanggal + durasi baca.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.publishedLabel, required this.readingMinutes});

  final String publishedLabel;
  final int readingMinutes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final color = theme.colorScheme.onSurfaceVariant;

    return Wrap(
      spacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_outlined, size: 15, color: color),
            const SizedBox(width: 5),
            Text(publishedLabel, style: style),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.schedule_outlined, size: 15, color: color),
            const SizedBox(width: 5),
            Text('$readingMinutes menit baca', style: style),
          ],
        ),
      ],
    );
  }
}