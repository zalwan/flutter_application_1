import 'package:flutter/material.dart';

import '../../core/utils/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import 'widgets/auth_scaffold.dart';

/// Halaman registrasi pengguna baru.
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _konfirmasiController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _konfirmasiController.dispose();
    super.dispose();
  }

  /// Memvalidasi form lalu menyimpan pengguna baru ke database SQLite.
  Future<void> actionRegistrasi() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final String username = _usernameController.text.trim().toLowerCase();
      final bool isTaken = await AuthRepository.instance.isUsernameTaken(
        username,
      );

      if (!mounted) return;

      if (isTaken) {
        await showAppDialog(
          context,
          title: 'Registrasi Gagal',
          message: 'Username sudah digunakan, silakan pilih username lain.',
        );
        return;
      }

      final User user = await AuthRepository.instance.register(
        nama: _namaController.text,
        username: username,
        password: _passwordController.text,
      );

      if (!mounted) return;
      showAppSnackBar(context, 'Registrasi berhasil, silakan login');
      Navigator.of(context).pop(user.username);
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Terjadi Kesalahan',
        message: 'Tidak dapat menyimpan data: $error',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      headerTitle: 'Buat Akun Baru',
      children: [
        AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrasi Pengguna',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Lengkapi data di bawah untuk membuat akun Rizal Docs.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Nama Lengkap',
                  hint: 'Contoh: Rizal Suryawan',
                  controller: _namaController,
                  prefixIcon: Icons.badge_outlined,
                  validator: AppValidators.nama,
                  keyboardType: TextInputType.name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Username',
                  hint: 'Username untuk login',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: AppValidators.username,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newUsername],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: AppValidators.password,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Konfirmasi Password',
                  hint: 'Ulangi password',
                  controller: _konfirmasiController,
                  prefixIcon: Icons.lock_reset_rounded,
                  obscureText: _obscurePassword,
                  validator: (String? value) =>
                      AppValidators.konfirmasiPassword(
                        value,
                        _passwordController.text,
                      ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => actionRegistrasi(),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      size: 20,
                      color: const Color(0xFF64748B),
                    ),
                    tooltip: _obscurePassword
                        ? 'Tampilkan password'
                        : 'Sembunyikan password',
                  ),
                ),
                const SizedBox(height: 22),
                PrimaryButton(
                  label: 'Daftar',
                  icon: Icons.person_add_alt_1_rounded,
                  isLoading: _isLoading,
                  onPressed: actionRegistrasi,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
