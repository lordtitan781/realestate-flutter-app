import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'features/auth/login_screen.dart';

void main() {
  runApp(const TourismInvestmentApp());
}

class TourismInvestmentApp extends StatelessWidget {
  const TourismInvestmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
    );
  }
}