import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';
import 'add_land_screen.dart';

class LandownerDashboard extends StatelessWidget {
  const LandownerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  "Landowner Dashboard",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                if (appState.pendingLands.isNotEmpty) ...[
                  const Text(
                    "Pending Submissions",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...appState.pendingLands.map((land) => Card(
                        child: ListTile(
                          title: Text(land.name),
                          subtitle: Text(
                              "Location: ${land.location} | Status: ${land.stage}"),
                        ),
                      )),
                ],
                const SizedBox(height: 20),
                if (appState.approvedLands.isNotEmpty) ...[
                  const Text(
                    "Approved Parcels",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  const SizedBox(height: 10),
                  ...appState.approvedLands.map((land) => Card(
                        child: ListTile(
                          title: Text(land.name),
                          subtitle: Text("Location: ${land.location}"),
                          trailing: const Icon(Icons.check_circle, color: Colors.green),
                        ),
                      )),
                ],
                if (appState.pendingLands.isEmpty && appState.approvedLands.isEmpty)
                  const Center(child: Text("No land submissions yet.")),
                const SizedBox(height: 20),
                // Landowner quick actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLandScreen())),
                        icon: const Icon(Icons.add_location),
                        label: const Text('Submit Land'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pushNamed(context, '/my-lands'),
                        icon: const Icon(Icons.list),
                        label: const Text('My Lands'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
