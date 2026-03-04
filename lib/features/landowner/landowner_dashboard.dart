import 'package:flutter/material.dart';
import '../../../../shared/widgets/stage_badge.dart';

class LandownerDashboard extends StatelessWidget {
  const LandownerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Text(
            "Landowner Overview",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Card(
            child: ListTile(
              title: Text("Beach Land - Goa"),
              subtitle: Text("Size: 3 Acres | EOIs: 4"),
              trailing: StageBadge(stage: "Feasibility"),
            ),
          )
        ],
      ),
    );
  }
}