import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'features/auth/login_screen.dart';
import 'features/finance/financial_calculator.dart';
import 'features/admin/pending_lands_page.dart';
import 'shared/app_state.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState()..fetchAll(),
      child: const TourismInvestmentApp(),
    ),
  );
}

class TourismInvestmentApp extends StatelessWidget {
  const TourismInvestmentApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Investify',
      theme: AppTheme.lightTheme,
      home: const LoginScreen(),
      routes: {
        '/finance': (_) => const FinancialCalculator(),
        '/admin': (_) => const PendingLandsPage(),
      },
    );
  }
}
