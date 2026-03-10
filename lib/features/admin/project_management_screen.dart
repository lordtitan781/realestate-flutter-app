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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProjects();
    });
  }

  Future<void> _loadProjects() async {
    final appState = context.read<AppState>();
    await appState.fetchAll();
  }

  void _updateStage(BuildContext context, int idx, String newStage) {
    final appState = context.read<AppState>();
    final currentProj = appState.projects[idx];
    if (currentProj.id == null) return;
    appState.updateProjectStage(currentProj.id!, newStage);
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
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateProjectScreen(),
                ),
              );

              await _loadProjects();
            },
          )
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          if (appState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (appState.projects.isEmpty) {
            return RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 300),
                  Center(
                    child: Text('No projects created yet'),
                  )
                ],
              ),
            );
          }

          return SafeArea(
            child: RefreshIndicator(
              onRefresh: _loadProjects,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appState.projects.length,
                itemBuilder: (context, i) {
                  final proj = appState.projects[i];

                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            proj.projectName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text("Location: ${proj.location}"),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Text('Update Stage: ', style: TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: DropdownButton<String>(
                                  value: proj.stage,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: 'LAND_APPROVED', child: Text('1. Land Approved')),
                                    DropdownMenuItem(value: 'FUNDING', child: Text('2. Investors Joined')),
                                    DropdownMenuItem(value: 'PLANNING', child: Text('3. Design Planning')),
                                    DropdownMenuItem(value: 'CONSTRUCTION', child: Text('4. Construction Started')),
                                    DropdownMenuItem(value: 'COMPLETED', child: Text('5. Resort Completed')),
                                    DropdownMenuItem(value: 'OPERATIONAL', child: Text('6. Tourists Arriving')),
                                    DropdownMenuItem(value: 'CANCELLED', child: Text('Cancelled')),
                                  ],
                                  onChanged: (value) {
                                    if (value != null) {
                                      _updateStage(context, i, value);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MilestonesPage(
                                      projectId: proj.id!,
                                      projectName: proj.projectName,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Detailed Log"),
                            ),
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
