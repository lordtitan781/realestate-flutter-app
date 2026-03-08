import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:realestate/widgets/project_card.dart';
import '../../models/project.dart';
import '../../shared/app_state.dart';
import 'project_details.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String selectedTheme = 'All';
  final List<String> themes = ['All', 'Eco-Luxury', 'Wellness', 'Beachfront', 'Adventure'];
  List<Project> _allProjects = [];
  List<Project> _displayed = [];

  @override
  void initState() {
    super.initState();
    // Load all projects once when the screen appears
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAllProjects());
  }

  Future<void> _loadAllProjects() async {
    final appState = context.read<AppState>();
    await appState.fetchAll();
    setState(() {
      _allProjects = List.from(appState.projects);
      _applyThemeFilter();
    });
  }

  void _applyThemeFilter() {
    if (selectedTheme == 'All') {
      _displayed = List.from(_allProjects);
    } else {
      _displayed = _allProjects.where((p) => (p.theme ?? '').toLowerCase() == selectedTheme.toLowerCase() || (p.theme ?? '').contains(selectedTheme)).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Explore Themes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
                onPressed: () => _loadAllProjects(),
          ),
        ],
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return Column(
            children: [
              // Theme Selector
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: themes.length,
                  itemBuilder: (context, index) {
                    final theme = themes[index];
                    final isSelected = selectedTheme == theme;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(theme),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              selectedTheme = theme;
                              _applyThemeFilter();
                            });
                          }
                        },
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: appState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _displayed.isEmpty
                        ? const Center(child: Text("No projects found for this theme."))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            itemCount: _displayed.length,
                            itemBuilder: (context, index) {
                              final proj = _displayed[index];
                              return ProjectCard(
                                project: proj,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ProjectDetails(project: proj),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}
