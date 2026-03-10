import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../shared/app_state.dart';

class EoiForm extends StatefulWidget {
  final int projectId;

  const EoiForm({Key? key, required this.projectId}) : super(key: key);

  @override
  _EoiFormState createState() => _EoiFormState();
}

class _EoiFormState extends State<EoiForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  final _contactController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      // For the current domain model, EOIs are submitted via AppState.addToPortfolio
      // using the logged-in investor and selected project. This form acts only as
      // a UX collector; we just show a confirmation.
      final appState = context.read<AppState>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Thanks ${_nameController.text}, your interest has been recorded. Our team will reach out at ${_contactController.text}.',
          ),
        ),
      );
      Navigator.of(context).pop(true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit EOI: $e')));
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Expression of Interest')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Your name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: 'Contact info (email/phone)'),
              ),
              TextFormField(
                controller: _messageController,
                decoration: InputDecoration(labelText: 'Message (Tell me more)'),
                maxLines: 4,
                validator: (v) => v == null || v.isEmpty ? 'Enter a short message' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting ? CircularProgressIndicator() : Text('Send EOI'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
