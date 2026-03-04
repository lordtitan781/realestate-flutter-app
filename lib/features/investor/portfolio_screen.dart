import 'package:flutter/material.dart';
import '../../../../shared/widgets/stage_badge.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [

          Text(
            "My Portfolio",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 20),

          Card(
            child: ListTile(
              title: Text("Beach Resort - Goa"),
              subtitle: Text("Invested: ₹10L | IRR: 17%"),
              trailing: StageBadge(stage: "Construction"),
            ),
          )
        ],
      ),
    );
  }
}