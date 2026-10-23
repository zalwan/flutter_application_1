import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/splash_page.dart';

/// Root widget aplikasi Rizal Docs.
class RizalDocsApp extends StatelessWidget {
  const RizalDocsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Header seluruh halaman berwarna biru tua, sehingga ikon status bar
      // dibuat terang agar tetap terbaca.
      builder: (BuildContext context, Widget? child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashPage(),
    );
  }
}
