import 'package:flutter/material.dart';
import '../../models/eoi.dart';
import '../../services/api_service.dart';

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
      final eoi = Eoi(
        investorName: _nameController.text,
        message: _messageController.text,
        contactInfo: _contactController.text,
      );
      final res = await ApiService.submitEoi(widget.projectId, eoi);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('EOI submitted (id: ${res.id})')));
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
