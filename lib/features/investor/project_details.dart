import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../shared/widgets/stage_badge.dart';
import '../../models/project.dart';
import '../../shared/app_state.dart';
import '../../widgets/milestone_tile.dart';
import '../projects/milestones_page.dart';

class ProjectDetails extends StatefulWidget {
  final Project project;

  const ProjectDetails({super.key, required this.project});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  bool _complianceAccepted = false;

  @override
  Widget build(BuildContext context) {
    final proj = widget.project;
    return Scaffold(
      appBar: AppBar(title: const Text("Destination Intelligence")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Destination Title & Theme
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(proj.title, style: Theme.of(context).textTheme.headlineMedium),
                      Text(proj.theme, style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                StageBadge(stage: proj.stage),
              ],
            ),
            const SizedBox(height: 24),

            // Market Intelligence Module (Requirement: Destination Analytics)
            _sectionHeader(context, "Market Intelligence"),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  _analyticRow("Projected Growth", "${proj.projectedGrowth}% YoY", Icons.trending_up, Colors.green),
                  const Divider(height: 24),
                  _analyticRow("Demand Index", "${proj.demandIndex}/10", Icons.leaderboard, Colors.blue),
                  const Divider(height: 24),
                  _analyticRow("Risk Profile", proj.riskProfile, Icons.shield_outlined, Colors.orange),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => MilestonesPage(projectId: proj.id!, projectName: proj.title)),
                );
              },
              icon: const Icon(Icons.event_note),
              label: const Text('View Milestones'),
            ),
            const SizedBox(height: 12),

            // Financial Modelling Output (Requirement: ROI/IRR Projections)
            _sectionHeader(context, "Financial Projections"),
            const SizedBox(height: 12),
            Row(
              children: [
                _miniStatCard(context, "Expected IRR", "${proj.irr}%", Icons.pie_chart),
                const SizedBox(width: 12),
                _miniStatCard(context, "Capital Req.", "₹${proj.capitalRequired} Cr", Icons.account_balance),
              ],
            ),
            const SizedBox(height: 32),

            // Project Lifecycle Tracker (Requirement: Milestone Visibility)
            _sectionHeader(context, "Development Roadmap"),
            const SizedBox(height: 12),
            MilestoneTile(title: "Feasibility Study", completed: true),
            MilestoneTile(title: "Regulatory Approvals", completed: proj.stage != "Feasibility", inProgress: proj.stage == "Approvals"),
            MilestoneTile(title: "Construction Phase", completed: proj.stage == "Operational", inProgress: proj.stage == "Construction"),
            MilestoneTile(title: "Operational Handover", inProgress: proj.stage == "Operational"),
            const SizedBox(height: 32),

            // Compliance & Disclaimer (Requirement: Compliance controls)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                children: [
                  const Text(
                    "Disclaimer: Real estate investments carry inherent risks. Projections are based on current market intelligence and historical data.",
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: _complianceAccepted,
                        onChanged: (val) => setState(() => _complianceAccepted = val!),
                      ),
                      const Expanded(
                        child: Text("I acknowledge the financial modelling assumptions and risk profile.", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _complianceAccepted ? () {
                context.read<AppState>().addToPortfolio(proj);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Expression of Interest submitted for ${proj.title}')),
                );
              } : null,
              child: const Text('Submit Expression of Interest (EOI)'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _analyticRow(String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Text(label, style: const TextStyle(color: Colors.grey)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _miniStatCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
