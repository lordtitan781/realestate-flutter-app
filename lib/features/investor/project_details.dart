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
  bool _eoiSubmitted = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _checkIfEOIExists();
  }

  Future<void> _checkIfEOIExists() async {
    final appState = context.read<AppState>();
    final exists = appState.hasEOIForProject(widget.project.id!);
    setState(() {
      _eoiSubmitted = exists;
    });
  }

  Future<void> _submitEOI() async {
    if (!_complianceAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the compliance terms first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final success = await context.read<AppState>().addToPortfolio(widget.project);
      
      if (success && mounted) {
        setState(() => _eoiSubmitted = true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ Expression of Interest submitted for ${widget.project.title}'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop back after successful submission
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) Navigator.pop(context);
        });
      }
    } on Exception catch (e) {
      if (mounted) {
        final errorMessage = e.toString().contains('already submitted')
            ? 'You have already submitted an EOI for this project'
            : 'Failed to submit EOI. Please try again.';
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() => _eoiSubmitted = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  // Define standard milestones and map them to stages
  final List<String> _allMilestones = [
    'Land Approved',
    'Investors Joined',
    'Design Planning',
    'Construction Started',
    'Resort Completed',
    'Tourists Arriving',
  ];

  // Helper to determine completion based on current stage
  bool _isMilestoneCompleted(String milestone, String? stage) {
    if (stage == null) return false;
    
    // Mapping internal stage constants to milestone indices
    final Map<String, int> stageToIndex = {
      'LAND_APPROVED': 0,
      'FUNDING': 1,
      'PLANNING': 2,
      'CONSTRUCTION': 3,
      'COMPLETED': 4,
      'OPERATIONAL': 5, // Assuming this for 'Tourists Arriving'
    };

    final currentStageIndex = stageToIndex[stage] ?? -1;
    final milestoneIndex = _allMilestones.indexOf(milestone);
    
    return milestoneIndex <= currentStageIndex;
  }

  bool _isMilestoneInProgress(String milestone, String? stage) {
    if (stage == null) return false;
    
    final Map<String, int> stageToIndex = {
      'LAND_APPROVED': 0,
      'FUNDING': 1,
      'PLANNING': 2,
      'CONSTRUCTION': 3,
      'COMPLETED': 4,
      'OPERATIONAL': 5,
    };

    final currentStageIndex = stageToIndex[stage] ?? -1;
    final milestoneIndex = _allMilestones.indexOf(milestone);
    
    return milestoneIndex == currentStageIndex + 1;
  }

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

            // Project Lifecycle Tracker (Standardized Milestones)
            _sectionHeader(context, "Development Roadmap"),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: Column(
                children: _allMilestones.map((milestone) {
                  final isCompleted = _isMilestoneCompleted(milestone, proj.stage);
                  final isInProgress = _isMilestoneInProgress(milestone, proj.stage);
                  
                  return MilestoneTile(
                    title: milestone,
                    completed: isCompleted,
                    inProgress: isInProgress,
                  );
                }).toList(),
              ),
            ),
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
                        onChanged: _eoiSubmitted ? null : (val) => setState(() => _complianceAccepted = val!),
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

            // EOI Status or Submit Button
            if (_eoiSubmitted)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade700, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'EOI Submitted',
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade700),
                          ),
                          const Text(
                            'This project has been added to your portfolio',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              ElevatedButton(
                onPressed: (_complianceAccepted && !_isSubmitting) ? _submitEOI : null,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Expression of Interest (EOI)'),
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
