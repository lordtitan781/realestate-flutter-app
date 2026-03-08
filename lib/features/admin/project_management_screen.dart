import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../shared/app_state.dart';
import 'create_project_screen.dart';
import '../projects/milestones_page.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() =>
      _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Load latest projects when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProjects());
  }

  Future<void> _loadProjects() async {
    final appState = context.read<AppState>();
    await appState.fetchAll();
    setState(() {});
  }
  void _updateStage(BuildContext context, int idx, String newStage) {
    final appState = context.read<AppState>();
    final currentProj = appState.projects[idx];
    
    final updatedProj = Project(
      id: currentProj.id,
      projectName: currentProj.projectName,
      location: currentProj.location,
      landSize: currentProj.landSize,
      investmentRequired: currentProj.investmentRequired,
      expectedROI: currentProj.expectedROI,
      expectedIRR: currentProj.expectedIRR,
      stage: newStage,
    );
    
    appState.addProject(updatedProj);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              // Open create screen and refresh on return
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateProjectScreen()),
              );
              await _loadProjects();
            },
          )
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadProjects,
              child: appState.projects.isEmpty
                  ? SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.6,
                        alignment: Alignment.center,
                        child: const Text('No projects created yet.'),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appState.projects.length,
                      itemBuilder: (context, i) {
                        final proj = appState.projects[i];
                        return Card(
                          child: ListTile(
                            title: Text(proj.title),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Location: ${proj.location}'),
                                const SizedBox(height: 4),
                                Text('Expected ROI: ${proj.expectedROI.toStringAsFixed(2)}%'),
                                const SizedBox(height: 4),
                                Text('Capital Required: ₹${proj.capitalRequired.toStringAsFixed(2)}'),
                              ],
                            ),
                            isThreeLine: true,
                            trailing: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                DropdownButton<String>(
                                  value: proj.stage,
                                  items: const [
                                    DropdownMenuItem(value: 'LAND_APPROVED', child: Text('Land Approved')),
                                    DropdownMenuItem(value: 'INVESTORS_JOINED', child: Text('Investors Joined')),
                                    DropdownMenuItem(value: 'DESIGN_PLANNING', child: Text('Design / Planning')),
                                    DropdownMenuItem(value: 'CONSTRUCTION_STARTED', child: Text('Construction Started')),
                                    DropdownMenuItem(value: 'RESORT_COMPLETED', child: Text('Resort Completed')),
                                    DropdownMenuItem(value: 'TOURISTS_ARRIVING', child: Text('Tourists Arriving')),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      _updateStage(context, i, v);
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: proj.id != null
                                      ? () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => MilestonesPage(
                                                projectId: proj.id!,
                                                projectName: proj.title,
                                              ),
                                            ),
                                          );
                                        }
                                      : null,
                                  child: const Text('View Milestones'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          );
        },
      ),
    );
  }
}
