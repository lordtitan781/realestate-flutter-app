import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/land.dart';
import '../../shared/app_state.dart';

class AddLandScreen extends StatefulWidget {
  const AddLandScreen({super.key});

  @override
  State<AddLandScreen> createState() => _AddLandScreenState();
}

class _AddLandScreenState extends State<AddLandScreen> {
  final _nameCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _sizeCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _sizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Land')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              const Text(
                "Add New Land",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: "Land Name",
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: "Location",
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _sizeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Size (Acres)",
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final currentUserId = context.read<AppState>().currentUserId;
                  final newLand = Land(
                    ownerId: currentUserId,
                    name: _nameCtrl.text,
                    location: _locationCtrl.text,
                    size: double.tryParse(_sizeCtrl.text) ?? 0,
                    zoning: '',
                    stage: 'Pending Approval',
                  );

                  context.read<AppState>().addLand(newLand);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Land submitted for evaluation')),
                  );

                  _nameCtrl.clear();
                  _locationCtrl.clear();
                  _sizeCtrl.clear();
                },
                child: const Text("Submit for Evaluation"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
