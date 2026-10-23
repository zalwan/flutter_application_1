import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../models/document.dart';
import '../../repositories/document_repository.dart';
import '../documents/document_detail_page.dart';
import '../documents/widgets/document_card.dart';

/// Halaman daftar dokumen favorit.
///
/// Data dibaca dari kolom `is_favorite` pada tabel dokumen sehingga daftar
/// selalu sinkron dengan aksi favorit pada halaman detail.
class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final DocumentRepository _repository = DocumentRepository.instance;

  List<Document> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Document> documents = await _repository.getFavorites();
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat favorit: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _openDetail(Document document) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            DocumentDetailPage(document: document),
      ),
    );

    if (!mounted) return;
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadFavorites,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _documents.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) return _buildHeader();

          final Document document = _documents[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DocumentCard(
              document: document,
              onTap: () => _openDetail(document),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Favorit Saya',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Dokumen yang Anda tandai sebagai favorit.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (!_isLoading)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE11D48).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_documents.length} dokumen',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE11D48),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 20),
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorMessage != null)
          _FavoritesMessage(
            icon: Icons.error_outline_rounded,
            message: _errorMessage!,
            actionLabel: 'Coba Lagi',
            onAction: _loadFavorites,
          )
        else if (_documents.isEmpty)
          const _FavoritesMessage(
            icon: Icons.favorite_border_rounded,
            message:
                'Belum ada dokumen favorit. Buka detail dokumen lalu tekan '
                'tombol "Tambah ke Favorit" untuk menambahkannya ke sini.',
          ),
      ],
    );
  }
}

class _FavoritesMessage extends StatelessWidget {
  const _FavoritesMessage({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 44, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
