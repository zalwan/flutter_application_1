import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Membuka isi artikel langsung di dalam app lewat WebView,
/// tanpa harus keluar ke browser eksternal.
class PostWebViewScreen extends StatefulWidget {
  const PostWebViewScreen({super.key, required this.url, this.title});

  final String url;
  final String? title;

  @override
  State<PostWebViewScreen> createState() => _PostWebViewScreenState();
}

class _PostWebViewScreenState extends State<PostWebViewScreen> {
  late final WebViewController _controller;

  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // Saat halaman mulai dimuat → tampilkan progress.
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _failed = false;
            });
          },
          // Selesai dimuat → sembunyikan progress.
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() => _loading = false);
          },
          // Error di frame utama (bukan sub-resource) → tampilkan retry.
          onWebResourceError: (error) {
            if (!mounted || error.isForMainFrame != true) return;
            setState(() {
              _failed = true;
              _loading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _reload() {
    setState(() => _failed = false);
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(widget.title ?? 'Artikel', maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Stack(
        children: [
          Positioned.fill(child: WebViewWidget(controller: _controller)),
          // Indikator tipis di atas, tidak menutupi konten.
          if (_loading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: LinearProgressIndicator(
                minHeight: 3,
                backgroundColor: Colors.transparent,
              ),
            ),
          if (_failed)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 52,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Artikel gagal dimuat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Periksa koneksi Anda lalu coba lagi.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: _reload,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Coba lagi'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}