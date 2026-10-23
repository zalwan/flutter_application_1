import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../core/widgets/app_feedback.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/primary_button.dart';
import '../../models/user.dart';
import '../../repositories/auth_repository.dart';
import '../dashboard/dashboard_page.dart';
import 'register_page.dart';
import 'widgets/auth_scaffold.dart';

/// Halaman login aplikasi.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Memvalidasi form lalu mencocokkan data dengan database SQLite.
  Future<void> actionLogin() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final User? user = await AuthRepository.instance.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;

      if (user == null) {
        await showAppDialog(
          context,
          title: 'Login Gagal',
          message: 'Username atau password salah',
        );
        return;
      }

      showAppSnackBar(context, 'Login berhasil');
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => DashboardPage(user: user),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      showAppDialog(
        context,
        title: 'Terjadi Kesalahan',
        message: 'Tidak dapat mengakses database: $error',
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _openRegisterPage() async {
    final String? registeredUsername = await Navigator.of(context)
        .push<String>(
          MaterialPageRoute<String>(
            builder: (BuildContext context) => const RegisterPage(),
          ),
        );

    if (!mounted) return;
    if (registeredUsername != null && registeredUsername.isNotEmpty) {
      _usernameController.text = registeredUsername;
      _passwordController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      children: [
        AuthCard(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Masuk ke Akun',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Silakan masuk untuk mulai mengelola koleksi dokumen Anda.',
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'Username',
                  hint: 'Masukkan username',
                  controller: _usernameController,
                  prefixIcon: Icons.person_outline_rounded,
                  validator: AppValidators.username,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username],
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Password',
                  hint: 'Minimal 6 karakter',
                  controller: _passwordController,
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: _obscurePassword,
                  validator: AppValidators.password,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  onFieldSubmitted: (_) => actionLogin(),
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
                  label: 'Masuk',
                  icon: Icons.login_rounded,
                  isLoading: _isLoading,
                  onPressed: actionLogin,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'Belum punya akun?',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: _isLoading ? null : _openRegisterPage,
          icon: const Icon(Icons.person_add_alt_1_rounded, size: 18),
          label: const Text('Registrasi Akun Baru'),
        ),
      ],
    );
  }
}
