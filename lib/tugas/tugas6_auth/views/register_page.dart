import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../models/mahasiswa_options.dart';
import '../services/auth_service.dart';
import '../widgets/auth_text_field.dart';
import 'auth_scope.dart';
import 'home_session_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _prodi = MahasiswaOptions.prodi.first;
  String? _kelas = MahasiswaOptions.kelas.first;
  String? _gender = MahasiswaOptions.gender.first;
  int? _semester = MahasiswaOptions.semester.first;

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_prodi == null ||
        _kelas == null ||
        _gender == null ||
        _semester == null) {
      Fluttertoast.showToast(
        msg: 'Lengkapi semua pilihan dropdown.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return;
    }
    final auth = context.read<AuthService>();
    final error = await auth.register(
      name: _nameController.text,
      nim: _nimController.text,
      password: _passwordController.text,
      prodi: _prodi!,
      kelas: _kelas!,
      gender: _gender!,
      semester: _semester!,
    );
    if (!mounted) return;
    if (error != null) {
      Fluttertoast.showToast(
        msg: error,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red.shade700,
        textColor: Colors.white,
      );
      return;
    }
    Fluttertoast.showToast(
      msg: 'Registrasi berhasil. Session tersimpan di SQLite.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
    pushAndRemoveUntilWithAuth(context, const HomeSessionPage());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthService>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tugas 6 - Register Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registrasi Mahasiswa',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Data tersimpan di tabel users SQLite (kunci: NIM).',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              AuthTextField(
                controller: _nameController,
                label: 'Nama Lengkap',
                hint: 'cth: Rizal Suryawan',
                icon: Icons.person_outline,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _nimController,
                label: 'NIM',
                hint: 'cth: 241011750067',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  final nim = v?.trim() ?? '';
                  if (nim.isEmpty) return 'NIM wajib diisi';
                  if (!RegExp(r'^[0-9]+$').hasMatch(nim)) {
                    return 'NIM hanya angka';
                  }
                  if (nim.length < 8) return 'NIM minimal 8 digit';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthTextField(
                controller: _passwordController,
                label: 'Password',
                icon: Icons.lock_outline,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password wajib diisi';
                  if (v.length < 4) return 'Minimal 4 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              AuthDropdown<String>(
                label: 'Program Studi',
                icon: Icons.school_outlined,
                value: _prodi,
                items: MahasiswaOptions.prodi
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _prodi = v),
                validator: (v) => v == null ? 'Prodi wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              AuthDropdown<String>(
                label: 'Kelas',
                icon: Icons.class_outlined,
                value: _kelas,
                items: MahasiswaOptions.kelas
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _kelas = v),
                validator: (v) => v == null ? 'Kelas wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              AuthDropdown<String>(
                label: 'Jenis Kelamin',
                icon: Icons.wc_outlined,
                value: _gender,
                items: MahasiswaOptions.gender
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _gender = v),
                validator: (v) =>
                    v == null ? 'Jenis kelamin wajib dipilih' : null,
              ),
              const SizedBox(height: 12),
              AuthDropdown<int>(
                label: 'Semester',
                icon: Icons.timeline_outlined,
                value: _semester,
                items: MahasiswaOptions.semester
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e, child: Text('Semester $e')),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _semester = v),
                validator: (v) => v == null ? 'Semester wajib dipilih' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: isLoading ? null : _submit,
                icon: const Icon(Icons.person_add_outlined),
                label: Text(isLoading ? 'Menyimpan...' : 'Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
