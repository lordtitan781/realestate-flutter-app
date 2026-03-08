import 'package:flutter/material.dart';
import '../../models/land.dart';
import '../../models/project.dart';
import '../../services/api_service.dart';

class PendingLandsPage extends StatefulWidget {
  const PendingLandsPage({super.key});

  @override
  State<PendingLandsPage> createState() => _PendingLandsPageState();
}

class _PendingLandsPageState extends State<PendingLandsPage> {
  late Future<List<Land>> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    _future = ApiService.getPendingLands();
    setState(() {});
  }

  void _approve(Land land) async {
    try {
      await ApiService.approveLand(land.id ?? 0, adminNotes: 'Approved by admin');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Land approved')));
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Approve failed: $e')));
    }
  }

  void _reject(Land land) async {
    try {
      await ApiService.rejectLand(land.id ?? 0, adminNotes: 'Rejected by admin');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Land rejected')));
      _refresh();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Reject failed: $e')));
    }
  }

  void _evaluateAndConvert(Land land) async {
    final titleCtrl = TextEditingController(text: '${land.name} Project');
    final costCtrl = TextEditingController();
    final revenueCtrl = TextEditingController();
    final yearsCtrl = TextEditingController(text: '5');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Evaluate & Convert'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Project Title')),
              TextField(controller: costCtrl, decoration: const InputDecoration(labelText: 'Estimated Cost'), keyboardType: TextInputType.number),
              TextField(controller: revenueCtrl, decoration: const InputDecoration(labelText: 'Expected Annual Revenue'), keyboardType: TextInputType.number),
              TextField(controller: yearsCtrl, decoration: const InputDecoration(labelText: 'Evaluation Years'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Convert'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        final payload = {
          'title': titleCtrl.text,
          'estimatedCost': double.tryParse(costCtrl.text) ?? 0.0,
          'expectedAnnualRevenue': double.tryParse(revenueCtrl.text) ?? 0.0,
          'evaluationYears': int.tryParse(yearsCtrl.text) ?? 5,
        };
        Project project = await ApiService.convertLandToProject(land.id ?? 0, payload);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Project created: ${project.title}')));
        _refresh();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Conversion failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin — Pending Lands')),
      body: FutureBuilder<List<Land>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final lands = snapshot.data ?? [];
          if (lands.isEmpty) return const Center(child: Text('No pending lands'));
          return RefreshIndicator(
            onRefresh: () async => _refresh(),
            child: ListView.builder(
              itemCount: lands.length,
              itemBuilder: (context, index) {
                final land = lands[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListTile(
                    title: Text(land.name),
                    subtitle: Text('Location: ${land.location}\nSize: ${land.size} acres\nUtilities: ${land.utilities?.join(', ') ?? 'N/A'}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'approve') _approve(land);
                        if (value == 'reject') _reject(land);
                        if (value == 'convert') _evaluateAndConvert(land);
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'approve', child: Text('Approve')),
                        const PopupMenuItem(value: 'reject', child: Text('Reject')),
                        const PopupMenuItem(value: 'convert', child: Text('Evaluate & Convert')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
