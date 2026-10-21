import 'package:flutter/material.dart';

import 'utils/app_theme.dart';
import 'screens/auth/login_screen.dart';

class ApotekKuApp extends StatelessWidget {
  const ApotekKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ApotekKu',
      debugShowCheckedModeBanner: false,

      // Menggunakan tema kustom dari utils/app_theme.dart
      theme: AppTheme.lightTheme,

      // Halaman awal yang ditampilkan saat aplikasi dibuka
      home: const LoginScreen(),
    );
  }
}
