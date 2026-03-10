import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/widgets/stage_badge.dart';
import '../../shared/app_state.dart';
import 'project_details.dart';
import '../projects/milestones_page.dart';

class PortfolioScreen extends StatefulWidget {
  const PortfolioScreen({super.key});

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Refresh EOI data when the screen is opened to get the latest portfolio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = context.read<AppState>();
      if (appState.currentUserId != null && appState.currentUserRole == 'INVESTOR') {
        appState.fetchAll();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh portfolio when returning to this screen
      final appState = context.read<AppState>();
      if (appState.currentUserId != null && appState.currentUserRole == 'INVESTOR') {
        appState.fetchAll();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Portfolio"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              final appState = context.read<AppState>();
              if (appState.currentUserId != null && appState.currentUserRole == 'INVESTOR') {
                appState.fetchAll();
              }
            },
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          final portfolio = appState.investorPortfolio;
          
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (portfolio.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.pie_chart_outline, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "No investments yet",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: portfolio.length,
            itemBuilder: (context, index) {
              final proj = portfolio[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetails(project: proj),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.business,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proj.title,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Investment Required: ₹${proj.investmentRequired.toStringAsFixed(2)}",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            StageBadge(stage: proj.stage),
                            const SizedBox(height: 8),
                            Text(
                              "${proj.expectedIRR.toStringAsFixed(1)}% IRR",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                            if (proj.id != null && proj.title.isNotEmpty)
                              Column(
                                children: [
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => MilestonesPage(
                                            projectId: proj.id!,
                                            projectName: proj.title,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('View Milestones'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
