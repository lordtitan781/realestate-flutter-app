import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, appState, child) {
        final pending = appState.pendingLands.length;
        final approved = appState.approvedLands.length;
        final projects = appState.projects.length;

        if (appState.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Administrator Overview",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                Text("Pending land submissions: $pending"),
                Text("Approved land parcels: $approved"),
                Text("Active investment projects: $projects"),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}
