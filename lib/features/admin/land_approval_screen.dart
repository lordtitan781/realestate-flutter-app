import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';

class LandApprovalScreen extends StatefulWidget {
  const LandApprovalScreen({super.key});

  @override
  State<LandApprovalScreen> createState() => _LandApprovalScreenState();
}

class _LandApprovalScreenState extends State<LandApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pending Lands')),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AppState>(
          builder: (context, appState, child) {
            if (appState.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final pending = appState.pendingLands;

            if (pending.isEmpty) {
              return const Center(child: Text("No pending land submissions."));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pending.length,
              itemBuilder: (context, i) {
                final land = pending[i];
                return Card(
                  child: ListTile(
                    title: Text(land.name),
                    subtitle: Text(
                        "Location: ${land.location} | Size: ${land.size} acres"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          onPressed: () async {
                            if (land.id != null) {
                              await appState.approveLand(land.id!, land.name, land.location);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${land.name} approved and project created!')),
                              );
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () {
                            // rejection logic could go here
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
