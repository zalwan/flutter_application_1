import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/app_feedback.dart';
import '../../models/document.dart';
import '../../repositories/document_repository.dart';

/// Halaman detail dokumen.
///
/// Menampilkan gambar sampul, judul, deskripsi, serta informasi tambahan
/// (kategori, tahun, penulis, dan tanggal ditambahkan). Tombol aksi favorit
/// memakai AlertDialog konfirmasi sebelum data diperbarui.
class DocumentDetailPage extends StatefulWidget {
  const DocumentDetailPage({super.key, required this.document});

  final Document document;

  @override
  State<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends State<DocumentDetailPage> {
  late Document _document;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _document = widget.document;
  }

  Future<void> _toggleFavorite() async {
    final bool willAdd = !_document.isFavorite;

    final bool confirmed = await showConfirmDialog(
      context,
      title: willAdd ? 'Tambah ke Favorit' : 'Hapus dari Favorit',
      message: willAdd
          ? 'Yakin ingin menambahkan "${_document.title}" ke favorit?'
          : 'Yakin ingin menghapus "${_document.title}" dari favorit?',
    );

    if (!confirmed || !mounted) return;

    setState(() => _isUpdating = true);

    try {
      final int? id = _document.id;
      if (id == null) {
        throw StateError('Dokumen belum tersimpan pada database.');
      }

      await DocumentRepository.instance.setFavorite(id, willAdd);

      if (!mounted) return;
      setState(() {
        _document = _document.copyWith(isFavorite: willAdd);
        _isUpdating = false;
      });

      showAppSnackBar(
        context,
        willAdd
            ? 'Dokumen berhasil ditambahkan ke favorit'
            : 'Dokumen dihapus dari daftar favorit',
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _isUpdating = false);
      showAppDialog(
        context,
        title: 'Gagal Memperbarui',
        message: 'Terjadi kesalahan saat menyimpan perubahan: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 300,
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: _CoverHeader(document: _document),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _document.title,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.category_outlined,
                          label: _document.category,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.calendar_today_outlined,
                          label: 'Tahun ${_document.year}',
                        ),
                      ),
                      if (_document.isFavorite) ...[
                        const SizedBox(width: 10),
                        const Expanded(
                          child: _InfoChip(
                            icon: Icons.favorite_rounded,
                            label: 'Favorit',
                            isHighlighted: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Penulis',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                _document.author,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatTanggalPanjang(_document.createdAt),
                          style: const TextStyle(
                            fontSize: 10.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _document.description,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.7,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Informasi Dokumen',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      children: [
                        _DetailRow(
                          label: 'Kategori',
                          value: _document.category,
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _DetailRow(
                          label: 'Tahun Terbit',
                          value: '${_document.year}',
                        ),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _DetailRow(label: 'Penulis', value: _document.author),
                        const Divider(height: 1, indent: 16, endIndent: 16),
                        _DetailRow(
                          label: 'Status',
                          value: _document.isFavorite
                              ? 'Favorit'
                              : 'Koleksi Umum',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: _FavoriteButton(
            isFavorite: _document.isFavorite,
            isLoading: _isUpdating,
            onPressed: _toggleFavorite,
          ),
        ),
      ),
    );
  }
}

/// Bagian atas halaman detail berisi sampul dokumen dengan latar gradasi.
class _CoverHeader extends StatelessWidget {
  const _CoverHeader({required this.document});

  final Document document;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 44, bottom: 18),
            child: Container(
              height: 200,
              width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 24,
                    offset: Offset(0, 12),
                  ),
                ],
                image: DecorationImage(
                  image: AssetImage(document.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({
    required this.isFavorite,
    required this.isLoading,
    required this.onPressed,
  });

  final bool isFavorite;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
            ),
      label: Text(isFavorite ? 'Hapus dari Favorit' : 'Tambah ke Favorit'),
      style: FilledButton.styleFrom(
        backgroundColor: isFavorite
            ? const Color(0xFFE11D48)
            : AppTheme.primary,
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    final Color color = isHighlighted
        ? const Color(0xFFE11D48)
        : AppTheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
