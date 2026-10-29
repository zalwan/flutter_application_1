import 'package:flutter/material.dart';

import '../models/post.dart';
import '../services/post_api_service.dart';
import 'post_detail_screen.dart';

/// Halaman daftar artikel yang diambil dari API.
class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key, this.apiService});

  /// Boleh disuntikkan dari luar (untuk testing / DI).
  final PostApiService? apiService;

  @override
  State<PostListScreen> createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late final PostApiService _api = widget.apiService ?? PostApiService();

  List<Post> _posts = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  @override
  void dispose() {
    _api.dispose();
    super.dispose();
  }

  /// Memanggil API. Dipakai saat pertama kali dibuka dan saat retry/refresh.
  Future<void> _loadPosts() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final posts = await _api.fetchPosts();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } on ApiException catch (e) {
      // Respons gagal dari server / kesalahan jaringan → tampilkan pesan.
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _loading = false;
      });
    }
  }

  void _openDetail(Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const _BrandTitle(),
        actions: [
          if (!_loading && _error == null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(child: _CountBadge(count: _posts.length)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    // 1) Sedang mengambil data → skeleton.
    if (_loading) {
      return const _SkeletonList();
    }

    // 2) Gagal → pesan error + tombol coba lagi (tetap bisa scroll).
    if (_error != null) {
      return _CenteredScrollable(
        child: _ErrorView(message: _error!, onRetry: _loadPosts),
      );
    }

    // 3) Berhasil tetapi kosong → state empty.
    if (_posts.isEmpty) {
      return const _CenteredScrollable(child: _EmptyView());
    }

    // 4) Berhasil → hero artikel terbaru + daftar sisanya.
    final featured = _posts.first;
    final rest = _posts.skip(1).toList();

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        _FeaturedCard(post: featured, onTap: () => _openDetail(featured)),
        if (rest.isNotEmpty) ...[
          const SizedBox(height: 36),
          Text(
            'Artikel lainnya',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          for (final post in rest) _ArticleTile(post: post, onTap: () => _openDetail(post)),
        ],
      ],
    );
  }
}

/// Monogram + nama brand di AppBar.
class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'Z',
            style: TextStyle(
              color: scheme.onPrimaryContainer,
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        const Text('Zal Artikel'),
      ],
    );
  }
}

/// Badge jumlah artikel di pojok kanan AppBar.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primaryContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count artikel',
        style: theme.textTheme.labelMedium?.copyWith(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Kartu featured: artikel terbaru dengan cover besar.
class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final image = post.image;

    return Semantics(
      button: true,
      label: 'Buka artikel ${post.title}',
      child: Material(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CoverImage(
                imageUrl: image?.url ?? '',
                imageAlt: image?.alt ?? '',
                height: 200,
                tag: post.tags.isNotEmpty ? post.tags.first : null,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      post.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _MetaRow(
                      publishedLabel: post.publishedLabel,
                      readingMinutes: post.readingMinutes,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Baris artikel: thumbnail kiri, judul + meta kanan.
class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.post, required this.onTap});

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      button: true,
      label: 'Buka artikel ${post.title}',
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _CoverImage(
                  imageUrl: post.image?.url ?? '',
                  imageAlt: post.image?.alt ?? '',
                  width: 96,
                  height: 96,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _MetaRow(
                        publishedLabel: post.publishedLabel,
                        readingMinutes: post.readingMinutes,
                        compact: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Gambar cover dengan fallback (tanpa gambar → placeholder berikon).
class _CoverImage extends StatelessWidget {
  const _CoverImage({
    required this.imageUrl,
    required this.imageAlt,
    this.width,
    this.height,
    this.tag,
  });

  final String imageUrl;
  final String imageAlt;
  final double? width;
  final double? height;
  final String? tag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hasImage = imageUrl.isNotEmpty;
    final size = (width: width ?? double.infinity, height: height ?? 200.0);

    return SizedBox(
      width: size.width,
      height: size.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: hasImage
            ? Image.network(
                imageUrl,
                width: size.width,
                height: size.height,
                fit: BoxFit.cover,
                semanticLabel: imageAlt.isEmpty ? null : imageAlt,
                errorBuilder: (_, _, _) => _placeholder(scheme),
              )
            : _placeholder(scheme),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surfaceContainerHighest,
      child: Center(
        child: Icon(
          Icons.article_outlined,
          size: 40,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

/// Baris meta: tanggal + durasi baca dengan ikon.
class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.publishedLabel,
    required this.readingMinutes,
    this.compact = false,
  });

  final String publishedLabel;
  final int readingMinutes;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w500,
    );
    final iconSize = compact ? 13.0 : 15.0;

    return Wrap(
      spacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _MetaItem(
          icon: Icons.calendar_today_outlined,
          label: publishedLabel,
          style: style,
          iconSize: iconSize,
        ),
        _MetaItem(
          icon: Icons.schedule_outlined,
          label: '$readingMinutes mnt baca',
          style: style,
          iconSize: iconSize,
        ),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
    required this.style,
    required this.iconSize,
  });

  final IconData icon;
  final String label;
  final TextStyle? style;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: variant),
        const SizedBox(width: 4),
        Text(label, style: style),
      ],
    );
  }
}

/// Skeleton loading dengan denyut halus.
class _SkeletonList extends StatefulWidget {
  const _SkeletonList();

  @override
  State<_SkeletonList> createState() => _SkeletonListState();
}

class _SkeletonListState extends State<_SkeletonList>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat(reverse: true);

  late final Animation<double> _opacity =
      Tween(begin: 0.35, end: 0.85).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final boxColor = scheme.surfaceContainerHighest;

    return FadeTransition(
      opacity: _opacity,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Skeleton kartu featured.
          Container(
            height: 210,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            height: 22,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            height: 14,
            decoration: BoxDecoration(
              color: boxColor,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(height: 36),
          // Skeleton baris artikel.
          for (var i = 0; i < 4; i++) ...[
            Row(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: boxColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: boxColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

/// Pembungkus agar konten yang tingginya pendek tetap bisa di-scroll
/// (dibutuhkan agar RefreshIndicator berfungsi).
class _CenteredScrollable extends StatelessWidget {
  const _CenteredScrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: constraints.maxHeight),
          child: Center(child: Padding(padding: const EdgeInsets.all(24), child: child)),
        ),
      ),
    );
  }
}

/// Tampilan saat daftar artikel kosong.
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.article_outlined, size: 52, color: scheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'Belum ada artikel',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tarik layar ke bawah untuk memuat ulang.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// Tampilan saat panggilan API gagal.
class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.wifi_off_rounded, size: 52, color: scheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'Artikel tidak bisa dimuat',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Coba lagi'),
        ),
      ],
    );
  }
}