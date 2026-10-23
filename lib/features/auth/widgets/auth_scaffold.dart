import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';

/// Kerangka halaman autentikasi (login & registrasi).
///
/// Bagian atas berisi branding dan foto profil bertema repositori dokumen,
/// sedangkan bagian bawah berisi form yang dapat di-scroll.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.children,
    this.showBackButton = false,
    this.headerTitle,
  });

  final List<Widget> children;
  final bool showBackButton;
  final String? headerTitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.scaffold,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppTheme.primary, AppTheme.primaryDark],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  if (showBackButton)
                    Positioned(
                      left: 8,
                      top: 4,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                        ),
                        tooltip: 'Kembali',
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        showBackButton ? 52 : 32,
                        24,
                        showBackButton ? 26 : 36,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.18),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                AppConstants.profileImage,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            headerTitle ?? AppConstants.appName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            AppConstants.appTagline,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.75),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              child: Column(
                children: [
                  ...children,
                  const SizedBox(height: 24),
                  Text(
                    '${AppConstants.studentName} • ${AppConstants.studentNim} • ${AppConstants.studentClass}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu putih pembungkus form autentikasi.
class AuthCard extends StatelessWidget {
  const AuthCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: child,
    );
  }
}
