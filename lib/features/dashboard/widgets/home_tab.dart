import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/document.dart';
import '../../../models/user.dart';
import '../../../repositories/document_repository.dart';
import '../../documents/widgets/document_card.dart';

/// Konten utama tab Beranda pada dashboard.
///
/// Menampilkan sapaan pengguna, ringkasan koleksi, pencarian, filter kategori,
/// dan daftar dokumen yang dibaca dari database SQLite. Seluruh konten
/// dibangun dengan [ListView.builder] sehingga halaman dapat di-scroll dan
/// data ditampilkan secara dinamis.
class HomeTab extends StatefulWidget {
  const HomeTab({
    super.key,
    required this.user,
    required this.onNavigate,
  });

  final User user;
  final ValueChanged<int> onNavigate;

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const String _allCategory = 'Semua';

  final TextEditingController _searchController = TextEditingController();
  final DocumentRepository _repository = DocumentRepository.instance;

  List<Document> _documents = [];
  String _selectedCategory = _allCategory;
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<String> get _categories {
    final Set<String> categories = <String>{
      for (final Document document in _documents) document.category,
    };
    final List<String> sorted = categories.toList()..sort();
    return <String>[_allCategory, ...sorted];
  }

  List<Document> get _filteredDocuments {
    final String query = _searchQuery.trim().toLowerCase();

    return _documents.where((Document document) {
      final bool matchesCategory =
          _selectedCategory == _allCategory ||
          document.category == _selectedCategory;
      final bool matchesQuery =
          query.isEmpty ||
          document.title.toLowerCase().contains(query) ||
          document.author.toLowerCase().contains(query) ||
          document.category.toLowerCase().contains(query);

      return matchesCategory && matchesQuery;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final List<Document> documents = _filteredDocuments;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: documents.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return _buildHeader(documents);
          }

          final Document document = documents[index - 1];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: DocumentCard(document: document),
          );
        },
      ),
    );
  }

  Widget _buildHeader(List<Document> filteredDocuments) {
    final int totalFavorites = _documents
        .where((Document document) => document.isFavorite)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _WelcomeCard(
          user: widget.user,
          totalDocuments: _documents.length,
          totalFavorites: totalFavorites,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _searchController,
          onChanged: (String value) => setState(() => _searchQuery = value),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Cari judul, penulis, atau kategori',
            prefixIcon: const Icon(
              Icons.search_rounded,
              size: 20,
              color: AppTheme.textSecondary,
            ),
            suffixIcon: _searchQuery.isEmpty
                ? null
                : IconButton(
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: 'Hapus pencarian',
                  ),
          ),
        ),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final String category in _categories)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: _selectedCategory == category,
                    showCheckmark: false,
                    onSelected: (_) {
                      setState(() => _selectedCategory = category);
                    },
                    selectedColor: AppTheme.primary,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _selectedCategory == category
                          ? Colors.white
                          : AppTheme.textSecondary,
                    ),
                    side: BorderSide(
                      color: _selectedCategory == category
                          ? AppTheme.primary
                          : AppTheme.border,
                    ),
                    shape: const StadiumBorder(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Koleksi Dokumen',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${filteredDocuments.length} dokumen',
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
        if (_errorMessage != null)
          _MessageCard(
            icon: Icons.error_outline_rounded,
            title: 'Terjadi kesalahan',
            message: _errorMessage!,
            actionLabel: 'Coba Lagi',
            onAction: _loadDocuments,
          )
        else if (filteredDocuments.isEmpty)
          _MessageCard(
            icon: Icons.search_off_rounded,
            title: 'Dokumen tidak ditemukan',
            message: _searchQuery.isEmpty && _selectedCategory == _allCategory
                ? 'Belum ada dokumen pada repositori.'
                : 'Coba kata kunci atau kategori lain.',
            actionLabel:
                _searchQuery.isEmpty && _selectedCategory == _allCategory
                ? null
                : 'Reset Filter',
            onAction: _searchQuery.isEmpty && _selectedCategory == _allCategory
                ? null
                : () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _selectedCategory = _allCategory;
                    });
                  },
          ),
        SizedBox(height: filteredDocuments.isEmpty ? 0 : 4),
      ],
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.user,
    required this.totalDocuments,
    required this.totalFavorites,
  });

  final User user;
  final int totalDocuments;
  final int totalFavorites;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x331E3A8A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat datang kembali,',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${AppConstants.studentNim} • ${AppConstants.studentClass}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 54,
                height: 54,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                child: ClipOval(
                  child: Image.asset(
                    AppConstants.profileImage,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Divider(color: Colors.white.withValues(alpha: 0.18), height: 1),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  label: 'Total Dokumen',
                  value: '$totalDocuments',
                  icon: Icons.description_outlined,
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                child: _StatItem(
                  label: 'Favorit',
                  value: '$totalFavorites',
                  icon: Icons.favorite_border_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppTheme.textSecondary),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              height: 1.4,
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
