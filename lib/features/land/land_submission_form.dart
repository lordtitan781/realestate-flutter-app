import 'package:flutter/material.dart';
import '../../models/land.dart';
import '../../services/api_service.dart';

class LandSubmissionForm extends StatefulWidget {
  const LandSubmissionForm({Key? key}) : super(key: key);

  @override
  _LandSubmissionFormState createState() => _LandSubmissionFormState();
}

class _LandSubmissionFormState extends State<LandSubmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _sizeController = TextEditingController();
  final _zoningController = TextEditingController();
  final _stageController = TextEditingController();
  final _legalController = TextEditingController();
  final _utilitiesController = TextEditingController(); // comma separated
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _sizeController.dispose();
    _zoningController.dispose();
    _stageController.dispose();
    _legalController.dispose();
    _utilitiesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final utilities = _utilitiesController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final land = Land(
        name: _nameController.text,
        location: _locationController.text,
        size: double.tryParse(_sizeController.text) ?? 0.0,
        zoning: _zoningController.text,
        stage: _stageController.text,
        legalDocuments: _legalController.text.isEmpty ? null : _legalController.text,
        utilities: utilities,
        reviewStatus: 'PENDING',
      );

      final saved = await ApiService.submitLand(land);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Land submitted (id: ${saved.id})')));
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit land: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Submit Land')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Title / short name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter a title' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
              ),
              TextFormField(
                controller: _sizeController,
                decoration: InputDecoration(labelText: 'Size (e.g., 5 for acres)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _zoningController,
                decoration: InputDecoration(labelText: 'Zoning'),
              ),
              TextFormField(
                controller: _stageController,
                decoration: InputDecoration(labelText: 'Stage (e.g., Submitted)'),
              ),
              TextFormField(
                controller: _legalController,
                decoration: InputDecoration(labelText: 'Legal documents (URL or note)'),
              ),
              TextFormField(
                controller: _utilitiesController,
                decoration: InputDecoration(labelText: 'Utilities (comma separated, e.g., water,electricity)'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? CircularProgressIndicator() : Text('Submit Land'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
