import 'package:flutter/material.dart';
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