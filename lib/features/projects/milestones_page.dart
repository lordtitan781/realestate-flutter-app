import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/project_milestone.dart';
import '../../services/api_service.dart';

class MilestonesPage extends StatefulWidget {
  final int projectId;
  final String? projectName;

  const MilestonesPage({Key? key, required this.projectId, this.projectName}) : super(key: key);

  @override
  State<MilestonesPage> createState() => _MilestonesPageState();
}

class _MilestonesPageState extends State<MilestonesPage> {
  late Future<List<ProjectMilestone>> _future;

  final _formKey = GlobalKey<FormState>();
  final _milestoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  String _status = 'PENDING';
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _load();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    setState(() {
      _isAdmin = role == 'ADMIN';
    });
  }

  void _load() {
    setState(() {
      _future = ApiService.getProjectMilestones(widget.projectId);
    });
  }

  @override
  void dispose() {
    _milestoneController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final milestone = ProjectMilestone(
      projectId: widget.projectId,
      milestone: _milestoneController.text.trim(),
      description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
      date: _dateController.text.trim().isEmpty ? null : _dateController.text.trim(),
      status: _status,
    );

    try {
      await ApiService.addProjectMilestone(milestone);
      _milestoneController.clear();
      _descriptionController.clear();
      _dateController.clear();
      _status = 'PENDING';
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add milestone: $e')));
    }
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _milestoneController,
            decoration: const InputDecoration(labelText: 'Milestone'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 2,
          ),
          TextFormField(
            controller: _dateController,
            decoration: const InputDecoration(labelText: 'Date (yyyy-MM-dd)'),
          ),
          DropdownButtonFormField<String>(
            value: _status,
            items: const [
              DropdownMenuItem(value: 'PENDING', child: Text('PENDING')),
              DropdownMenuItem(value: 'COMPLETED', child: Text('COMPLETED')),
              DropdownMenuItem(value: 'CANCELLED', child: Text('CANCELLED')),
            ],
            onChanged: (v) => setState(() => _status = v ?? 'PENDING'),
            decoration: const InputDecoration(labelText: 'Status'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _submit, child: const Text('Add Milestone')),
        ],
      ),
    );
  }

  Future<void> _updateStatus(int milestoneId, String status) async {
    try {
      await ApiService.updateMilestoneStatus(milestoneId, status);
      _load();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projectName ?? 'Milestones')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<List<ProjectMilestone>>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
                  final list = snap.data ?? [];
                  if (list.isEmpty) return const Center(child: Text('No milestones yet'));
                  return ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final m = list[i];
                      return Card(
                        child: ListTile(
                          title: Text(m.milestone),
                          subtitle: Text('${m.description ?? ''}\n${m.date ?? ''}'),
                          isThreeLine: true,
                          trailing: _isAdmin
                              ? PopupMenuButton<String>(
                                  onSelected: (val) => _updateStatus(m.id!, val),
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'PENDING', child: Text('Set PENDING')),
                                    const PopupMenuItem(value: 'COMPLETED', child: Text('Set COMPLETED')),
                                    const PopupMenuItem(value: 'CANCELLED', child: Text('Set CANCELLED')),
                                  ],
                                )
                              : null,
                          leading: CircleAvatar(child: Text(m.status[0])),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),
            if (_isAdmin) _buildForm(),
          ],
        ),
      ),
    );
  }
}
