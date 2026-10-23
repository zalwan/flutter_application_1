import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/document.dart';
import '../../repositories/document_repository.dart';

/// Halaman form untuk menambah dan mengubah dokumen.
///
/// Jika [document] bernilai `null`, halaman berjalan dalam mode tambah data.
class DocumentFormPage extends StatefulWidget {
  const DocumentFormPage({super.key, this.document});

  final Document? document;

  bool get isEditing => document != null;

  @override
  State<DocumentFormPage> createState() => _DocumentFormPageState();
}

class _DocumentFormPageState extends State<DocumentFormPage> {
  static const List<String> _categories = [
    'Teknologi',
    'Akademik',
    'Manajemen',
    'Sains',
    'Bisnis',
    'Umum',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late String _category;
  late String _selectedImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final Document? document = widget.document;

    _titleController.text = document?.title ?? '';
    _authorController.text = document?.author ?? '';
    _yearController.text = document?.year.toString() ?? '';
    _descriptionController.text = document?.description ?? '';
    _category = document?.category ?? _categories.first;
    _selectedImage = document?.image ?? AppConstants.coverImages.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveDocument() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final DateTime now = DateTime.now();
    final Document document = Document(
      id: widget.document?.id,
      title: _titleController.text.trim(),
      category: _category,
      author: _authorController.text.trim(),
      year: int.parse(_yearController.text.trim()),
      description: _descriptionController.text.trim(),
      image: _selectedImage,
      isFavorite: widget.document?.isFavorite ?? false,
      createdAt: widget.document?.createdAt ?? now,
      updatedAt: now,
    );

    try {
      if (widget.isEditing) {
        await DocumentRepository.instance.update(document);
      } else {
        await DocumentRepository.instance.create(document);
      }

      if (!mounted) return;
      showAppSnackBar(
        context,
        widget.isEditing
            ? 'Dokumen berhasil diperbarui'
            : 'Dokumen berhasil ditambahkan',
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      showAppDialog(
        context,
        title: 'Gagal Menyimpan',
        message: 'Terjadi kesalahan saat menyimpan dokumen: $error',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = <String>{
      ..._categories,
      if (widget.document != null) widget.document!.category,
    }.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Dokumen' : 'Tambah Dokumen'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    label: 'Judul Dokumen',
                    hint: 'Contoh: Basis Data Relasional',
                    controller: _titleController,
                    prefixIcon: Icons.title_rounded,
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Judul'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Penulis',
                    hint: 'Nama penulis dokumen',
                    controller: _authorController,
                    prefixIcon: Icons.person_outline_rounded,
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Penulis'),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kategori',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(
                                  Icons.category_outlined,
                                  size: 20,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              items: [
                                for (final String category in categories)
                                  DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(
                                      category,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                              ],
                              onChanged: (String? value) {
                                if (value != null) {
                                  setState(() => _category = value);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 110,
                        child: AppTextField(
                          label: 'Tahun',
                          hint: '2025',
                          controller: _yearController,
                          keyboardType: TextInputType.number,
                          validator: AppValidators.tahun,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Deskripsi',
                    hint: 'Ringkasan isi dokumen',
                    controller: _descriptionController,
                    maxLines: 5,
                    validator: (String? value) =>
                        AppValidators.requiredField(value, 'Deskripsi'),
                    textInputAction: TextInputAction.newline,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sampul Dokumen',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih salah satu gambar dari aset lokal aplikasi.',
              style: TextStyle(fontSize: 11.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 142,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: AppConstants.coverImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (BuildContext context, int index) {
                  final String image = AppConstants.coverImages[index];
                  final bool isSelected = image == _selectedImage;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedImage = image),
                    child: Container(
                      width: 94,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.border,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(image, fit: BoxFit.cover),
                            if (isSelected)
                              Positioned(
                                top: 6,
                                right: 6,
                                child: Container(
                                  padding: const EdgeInsets.all(3),
                                  decoration: const BoxDecoration(
                                    color: AppTheme.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check_rounded,
                                    size: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: PrimaryButton(
            label: widget.isEditing ? 'Simpan Perubahan' : 'Tambah Dokumen',
            icon: Icons.save_outlined,
            isLoading: _isSaving,
            onPressed: _saveDocument,
          ),
        ),
      ),
    );
  }
}
