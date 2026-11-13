import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/task_draft_provider.dart';

/// Tab 2 ("New Task"): form pembuatan tugas dengan integrasi
/// kamera (preview foto), GPS (koordinat), dan submit gabungan
/// ke tabel `todos` di Supabase.
class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _onCapturePhoto(TaskDraftProvider draft) async {
    final ok = await draft.capturePhoto();
    if (!ok && !mounted) {
      return;
    }
    if (!ok) {
      _showMessage(draft.lastError ?? 'Gagal mengambil foto.');
    }
  }

  Future<void> _onFetchLocation(TaskDraftProvider draft) async {
    final ok = await draft.fetchLocation();
    if (!ok && !mounted) {
      return;
    }
    if (!ok) {
      _showMessage(draft.lastError ?? 'Gagal mendapatkan lokasi.');
    }
  }

  Future<void> _onSubmit(TaskDraftProvider draft) async {
    final error = await draft.submit(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (!mounted) {
      return;
    }
    if (error != null) {
      _showMessage(error);
      return;
    }

    _titleController.clear();
    _descriptionController.clear();
    _showMessage('Tugas baru berhasil disimpan.');
    // Kembali ke tab daftar agar pengguna langsung melihat hasilnya.
    DefaultTabController.maybeOf(context)?.animateTo(0);
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskDraftProvider>(
      builder: (context, draft, _) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Tugas Baru',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Lengkapi teks, foto, dan lokasi lalu tekan Simpan.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Judul tugas',
                  hintText: 'Contoh: Laporan Praktikum PTM 10',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                  hintText: 'Detail pekerjaan yang harus dilakukan…',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // ---- Kamera -------------------------------------------------
              _SectionCard(
                icon: Icons.photo_camera_outlined,
                title: 'Foto Tugas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (draft.hasPhoto && draft.photoPath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(draft.photoPath!),
                          height: 160,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Foto siap, akan diunggah saat disimpan.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Hapus foto',
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: draft.reset,
                          ),
                        ],
                      ),
                    ] else
                      Text(
                        'Belum ada foto. Tekan tombol di bawah untuk '
                        'mengambil foto dari kamera.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: draft.capturingPhoto
                          ? null
                          : () => _onCapturePhoto(draft),
                      icon: draft.capturingPhoto
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.photo_camera),
                      label: Text(
                        draft.capturingPhoto ? 'Menyiapkan kamera…' : 'Ambil Foto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---- GPS ----------------------------------------------------
              _SectionCard(
                icon: Icons.location_on_outlined,
                title: 'Lokasi Tugas',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      draft.hasLocation
                          ? 'Koordinat terkunci:\n'
                              'Latitude : ${draft.latitude!.toStringAsFixed(6)}\n'
                              'Longitude: ${draft.longitude!.toStringAsFixed(6)}'
                          : 'Belum ada koordinat. Tekan tombol di bawah '
                              'untuk mengambil posisi GPS terkini.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed:
                          draft.locating ? null : () => _onFetchLocation(draft),
                      icon: draft.locating
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        draft.locating ? 'Mencari lokasi…' : 'Dapat Lokasi',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ---- Submit -------------------------------------------------
              FilledButton.icon(
                onPressed:
                    draft.submitting ? null : () => _onSubmit(draft),
                icon: draft.submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload_outlined),
                label: Text(
                  draft.submitting ? 'Menyimpan…' : 'Simpan Tugas',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(title, style: Theme.of(context).textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
