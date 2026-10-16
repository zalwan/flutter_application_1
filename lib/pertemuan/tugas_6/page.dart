import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../tugas/tugas6_auth/services/auth_service.dart';
import '../../tugas/tugas6_auth/views/splash_gate.dart';

Widget buildPertemuanPage() => const TugasPertemuan6Page();

class TugasPertemuan6Page extends StatelessWidget {
  const TugasPertemuan6Page({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthService()..checkSession(),
      child: const SplashGate(),
    );
  }
}
