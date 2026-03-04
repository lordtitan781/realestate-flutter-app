import 'package:flutter/material.dart';
import 'package:realestate/shared/widgets/stage_badge.dart';
import 'package:realestate/shared/widgets/capital_progress.dart';
import 'project_details.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          const Text(
            "Explore Projects",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Eco Resort - Coorg",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const StageBadge(stage: "Feasibility"),

                  const SizedBox(height: 10),

                  const Text("Expected IRR: 18%"),

                  const SizedBox(height: 10),

                  const CapitalProgress(
                    progress: 0.65, // 65% funded
                    label: "Capital Raised",
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProjectDetails(),
                        ),
                      );
                    },
                    child: const Text("View Details"),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}