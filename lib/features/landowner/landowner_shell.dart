import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import 'landowner_dashboard.dart';
import 'add_land_screen.dart';

class LandownerShell extends StatefulWidget {
  const LandownerShell({super.key});

  @override
  State<LandownerShell> createState() => _LandownerShellState();
}

class _LandownerShellState extends State<LandownerShell> {
  int currentIndex = 0;

  final pages = const [
    LandownerDashboard(),
    AddLandScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Landowner Portal"),
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
            icon: Icon(Icons.add),
            label: "Add Land",
          ),
        ],
      ),
    );
  }
}
