import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/project.dart';
import '../../shared/app_state.dart';

class CreateProjectScreen extends StatefulWidget {
  const CreateProjectScreen({super.key});

  @override
  State<CreateProjectScreen> createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _titleCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _themeCtrl = TextEditingController(text: 'Eco-Luxury');
  final _descCtrl = TextEditingController();
  final _irrCtrl = TextEditingController();
  final _capReqCtrl = TextEditingController();
  final _capRaisedCtrl = TextEditingController();
  final _landSizeCtrl = TextEditingController();
  final _expectedRoiCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _themeCtrl.dispose();
    _descCtrl.dispose();
    _irrCtrl.dispose();
    _capReqCtrl.dispose();
    _capRaisedCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitting = true;
    });
    final irr = double.tryParse(_irrCtrl.text) ?? 0;
    final capReq = double.tryParse(_capReqCtrl.text) ?? 0;
    final capRaised = double.tryParse(_capRaisedCtrl.text) ?? 0;
  final landSize = double.tryParse(_landSizeCtrl.text) ?? 0.0;
  final expectedRoi = double.tryParse(_expectedRoiCtrl.text) ?? 0.0;

    final newProject = Project(
      projectName: _titleCtrl.text,
      location: _locationCtrl.text,
      landSize: landSize,
      investmentRequired: capReq,
      expectedIRR: irr,
      expectedROI: expectedRoi,
      stage: 'Feasibility',
    );
    
    // Await the network call so the calling screen can refresh after creation
    await context.read<AppState>().addProject(newProject);
    setState(() {
      _isSubmitting = false;
    });
    Navigator.pop(context);
  }

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Project')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Project Title'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _landSizeCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Land Size (acres)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _themeCtrl,
              decoration: const InputDecoration(labelText: 'Theme (e.g. Wellness)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _irrCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Projected IRR (%)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _expectedRoiCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Expected ROI (%)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _capReqCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capital Required (₹Cr)'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _capRaisedCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Capital Raised (₹Cr)'),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Create'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
