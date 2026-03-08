import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';
import 'land_approval_screen.dart';
import 'project_management_screen.dart';

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
                // Admin action buttons
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LandApprovalScreen())),
                      icon: const Icon(Icons.landscape),
                      label: const Text('Pending Lands'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen())),
                      icon: const Icon(Icons.business),
                      label: const Text('Project Management'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProjectManagementScreen())),
                      icon: const Icon(Icons.flag),
                      label: const Text('Milestones'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
