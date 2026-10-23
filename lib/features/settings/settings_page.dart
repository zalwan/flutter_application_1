import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_feedback.dart';
import '../../models/document.dart';
import '../../repositories/document_repository.dart';
import '../documents/document_form_page.dart';

/// Halaman pengaturan untuk mengelola data dokumen (create, read, update,
/// delete).
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DocumentRepository _repository = DocumentRepository.instance;

  List<Document> _documents = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final List<Document> documents = await _repository.getAll();
      if (!mounted) return;
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat dokumen: $error';
        _isLoading = false;
      });
    }
  }

  Future<void> _openForm({Document? document}) async {
    final bool? changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (BuildContext context) => DocumentFormPage(document: document),
      ),
    );

    if (changed == true) {
      await _loadDocuments();
    }
  }

  Future<void> _deleteDocument(Document document) async {
    final bool confirmed = await showConfirmDialog(
      context,
      title: 'Hapus Dokumen',
      message:
          'Yakin ingin menghapus "${document.title}"? '
          'Data yang dihapus tidak dapat dikembalikan.',
    );

    if (!confirmed || !mounted) return;

    try {
      final int? id = document.id;
      if (id == null) {
        throw StateError('Dokumen tidak memiliki id.');
      }

      await _repository.delete(id);
      if (!mounted) return;
      showAppSnackBar(context, 'Dokumen berhasil dihapus');
      await _loadDocuments();
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Gagal Menghapus',
        message: 'Terjadi kesalahan saat menghapus dokumen: $error',
      );
    }
  }

  void _showManageSheet() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Kelola Data Dokumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Pilih tindakan yang ingin dilakukan pada koleksi dokumen.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const _SheetIcon(
                    icon: Icons.add_rounded,
                    color: AppTheme.primary,
                  ),
                  title: const Text('Tambah Dokumen'),
                  subtitle: const Text(
                    'Create - menambahkan data baru',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _openForm();
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const _SheetIcon(
                    icon: Icons.edit_outlined,
                    color: Color(0xFF0F766E),
                  ),
                  title: const Text('Ubah Dokumen'),
                  subtitle: const Text(
                    'Update - pilih dokumen pada daftar di bawah',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const _SheetIcon(
                    icon: Icons.delete_outline_rounded,
                    color: Color(0xFFDC2626),
                  ),
                  title: const Text('Hapus Dokumen'),
                  subtitle: const Text(
                    'Delete - pilih ikon hapus pada daftar dokumen',
                    style: TextStyle(fontSize: 11),
                  ),
                  onTap: () => Navigator.of(sheetContext).pop(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadDocuments,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Kelola data koleksi dokumen aplikasi.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showManageSheet,
                icon: const Icon(Icons.more_horiz_rounded),
                tooltip: 'Menu pengelolaan data',
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.border),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add_rounded, size: 20),
            label: const Text('Tambah Dokumen'),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Daftar Dokumen',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_documents.length} data',
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 48),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_errorMessage != null)
            _SettingsMessage(
              icon: Icons.error_outline_rounded,
              message: _errorMessage!,
              actionLabel: 'Coba Lagi',
              onAction: _loadDocuments,
            )
          else if (_documents.isEmpty)
            const _SettingsMessage(
              icon: Icons.folder_off_outlined,
              message:
                  'Belum ada dokumen. Gunakan tombol Tambah Dokumen untuk '
                  'membuat data baru.',
            )
          else
            ..._documents.map(
              (Document document) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ManagedDocumentTile(
                  document: document,
                  onEdit: () => _openForm(document: document),
                  onDelete: () => _deleteDocument(document),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppTheme.border),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: AppTheme.primary,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Menu pengelolaan data mencakup tambah (create), lihat '
                    '(read), ubah (update), dan hapus (delete) dokumen.',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ManagedDocumentTile extends StatelessWidget {
  const _ManagedDocumentTile({
    required this.document,
    required this.onEdit,
    required this.onDelete,
  });

  final Document document;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onTap: onEdit,
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            document.image,
            width: 44,
            height: 58,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          document.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            '${document.category} • ${document.year}',
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert_rounded, size: 20),
          tooltip: 'Aksi dokumen',
          onSelected: (String value) {
            if (value == 'edit') {
              onEdit();
            } else if (value == 'delete') {
              onDelete();
            }
          },
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem<String>(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 18),
                  SizedBox(width: 10),
                  Text('Ubah'),
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Color(0xFFDC2626),
                  ),
                  SizedBox(width: 10),
                  Text('Hapus', style: TextStyle(color: Color(0xFFDC2626))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsMessage extends StatelessWidget {
  const _SettingsMessage({
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
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 38, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _SheetIcon extends StatelessWidget {
  const _SheetIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
