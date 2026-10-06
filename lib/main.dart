import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TapJayaApp());
}

class TapJayaApp extends StatelessWidget {
  const TapJayaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tap Jaya',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}