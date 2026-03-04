import 'package:flutter/material.dart';
import '../../../../shared/widgets/stage_badge.dart';

class ProjectDetails extends StatelessWidget {
  const ProjectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Project Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [

            Text(
              "Eco Resort - Coorg",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            StageBadge(stage: "Feasibility"),

            SizedBox(height: 20),

            Text("Location: Coorg"),
            SizedBox(height: 10),
            Text("Projected IRR: 18%"),
            SizedBox(height: 10),
            Text("Capital Required: ₹1 Cr"),
            SizedBox(height: 20),

            Text(
              "Market Snapshot",
              style: TextStyle(
                  fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 10),

            Text(
              "Tourism growth in this region is 12% YoY with supply gap in eco-luxury segment.",
            ),
          ],
        ),
      ),
    );
  }
}