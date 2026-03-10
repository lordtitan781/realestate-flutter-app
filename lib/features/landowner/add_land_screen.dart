import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
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
  final _phoneCtrl = TextEditingController();
  final List<String> _selectedUtilities = [];
  final List<File> _uploadedFiles = [];
  String _zoning = 'Tourism / Hospitality';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _locationCtrl.dispose();
    _sizeCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        // Remove size restrictions for high limit
      );

      if (result != null) {
        setState(() {
          for (var file in result.files) {
            if (file.path != null) {
              _uploadedFiles.add(File(file.path!));
            }
          }
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${result.files.length} file(s) added')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking files: $e')),
        );
      }
    }
  }

  void _removeFile(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
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
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Phone Number",
                  hintText: "E.g. +1234567890 or 9876543210",
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
              DropdownButtonFormField<String>(
                value: _zoning,
                items: const [
                  DropdownMenuItem(
                    value: "Tourism / Hospitality",
                    child: Text("Tourism / Hospitality"),
                  ),
                  DropdownMenuItem(
                    value: "Mixed Use",
                    child: Text("Mixed Use"),
                  ),
                  DropdownMenuItem(
                    value: "Agricultural (to be converted)",
                    child: Text("Agricultural (to be converted)"),
                  ),
                ],
                onChanged: (v) => setState(() => _zoning = v ?? _zoning),
                decoration: InputDecoration(
                  labelText: "Zoning",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Project Files Upload Section
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade50,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Project Files",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_uploadedFiles.length} file(s)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload all project-related documents (plans, surveys, legal docs, etc.)",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _pickFiles,
                      icon: const Icon(Icons.cloud_upload_outlined),
                      label: const Text("Add Files"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_uploadedFiles.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 12),
                      Text(
                        "Uploaded Files",
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                      const SizedBox(height: 8),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _uploadedFiles.length,
                        itemBuilder: (context, index) {
                          final file = _uploadedFiles[index];
                          final fileName =
                              file.path.split('/').last;
                          final fileSizeInMB =
                              (file.lengthSync() / (1024 * 1024))
                                  .toStringAsFixed(2);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.grey.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.description_outlined,
                                  color: Colors.blue.shade600,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fileName,
                                        maxLines: 1,
                                        overflow:
                                            TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '$fileSizeInMB MB',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close),
                                  iconSize: 20,
                                  color: Colors.red.shade600,
                                  onPressed: () =>
                                      _removeFile(index),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Utilities available",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _buildUtilityChip("Road Access"),
                  _buildUtilityChip("Water"),
                  _buildUtilityChip("Electricity"),
                  _buildUtilityChip("Sewage"),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Validate required fields
                  if (_nameCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter land name')),
                    );
                    return;
                  }
                  if (_locationCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter location')),
                    );
                    return;
                  }
                  if (_phoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter phone number')),
                    );
                    return;
                  }
                  if (_sizeCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter land size')),
                    );
                    return;
                  }

                  final currentUserId = context.read<AppState>().currentUserId;
                  
                  // Create document file paths list for backend processing
                  final documentPaths = _uploadedFiles.map((f) => f.path).toList();
                  final documentsJson = documentPaths.join('|'); // Serialize file paths

                  final newLand = Land(
                    ownerId: currentUserId,
                    name: _nameCtrl.text,
                    location: _locationCtrl.text,
                    size: double.tryParse(_sizeCtrl.text) ?? 0,
                    zoning: _zoning,
                    stage: 'Pending Approval',
                    legalDocuments: documentsJson.isNotEmpty ? documentsJson : null,
                    utilities: _selectedUtilities.toList(),
                    phoneNumber: _phoneCtrl.text.trim(),
                  );

                  context.read<AppState>().addLand(newLand);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Land submitted with ${_uploadedFiles.length} file(s)',
                      ),
                    ),
                  );

                  _nameCtrl.clear();
                  _locationCtrl.clear();
                  _sizeCtrl.clear();
                  _phoneCtrl.clear();
                  setState(() {
                    _selectedUtilities.clear();
                    _uploadedFiles.clear();
                    _zoning = 'Tourism / Hospitality';
                  });
                },
                child: const Text("Submit for Evaluation"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUtilityChip(String label) {
    final selected = _selectedUtilities.contains(label);
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (val) {
        setState(() {
          if (val) {
            _selectedUtilities.add(label);
          } else {
            _selectedUtilities.remove(label);
          }
        });
      },
    );
  }
}
