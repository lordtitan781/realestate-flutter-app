import 'package:flutter/material.dart';
import 'package:realestate/shared/widgets/summary_card.dart';

class InvestorDashboard extends StatelessWidget {
  const InvestorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [

            Text(
              "Investor Overview",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),

            Row(
              children: [
                SummaryCard(title: "Total Invested", value: "₹25L"),
                SizedBox(width: 10),
                SummaryCard(title: "Active Projects", value: "3"),
              ],
            ),

            SizedBox(height: 20),

            Row(
              children: [
                SummaryCard(title: "Avg IRR", value: "17%"),
                SizedBox(width: 10),
                SummaryCard(title: "Next Milestone", value: "Construction"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}