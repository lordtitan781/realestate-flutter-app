import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';

class MyLandsScreen extends StatelessWidget {
  const MyLandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Lands')),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) return const Center(child: CircularProgressIndicator());

          final currentUserId = appState.currentUserId;
          final all = [...appState.pendingLands, ...appState.approvedLands];

          // Filter to only lands owned by the current user
          final owned = all.where((land) => land.ownerId != null && currentUserId != null && land.ownerId == currentUserId).toList();

          if (owned.isEmpty) return const Center(child: Text('You have not submitted any lands yet'));
          return ListView.builder(
            itemCount: owned.length,
            itemBuilder: (context, i) {
              final land = owned[i];
              return Card(
                child: ListTile(
                  title: Text(land.name),
                  subtitle: Text('Location: ${land.location} \nStatus: ${land.stage}'),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
