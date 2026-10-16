import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import 'home_session_page.dart';
import 'login_page.dart';

/// Gate saat app start: baca SQLite via `checkSession()`.
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, auth, _) {
        if (auth.isCheckingSession) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Memeriksa session...'),
                ],
              ),
            ),
          );
        }
        if (auth.isLoggedIn) return const HomeSessionPage();
        return const LoginPage();
      },
    );
  }
}
