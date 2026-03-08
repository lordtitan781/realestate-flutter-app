import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'investor_dashboard.dart';
import 'explore_screen.dart';
import 'portfolio_screen.dart';

class InvestorShell extends StatefulWidget {
  const InvestorShell({super.key});

  @override
  State<InvestorShell> createState() => _InvestorShellState();
}

class _InvestorShellState extends State<InvestorShell> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    InvestorDashboard(),
    ExploreScreen(),
    PortfolioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Investify"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: "Explore",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: "Portfolio",
          ),
        ],
      ),
    );
  }
}
