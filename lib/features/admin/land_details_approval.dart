import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../models/land.dart';
import '../../shared/app_state.dart';

class LandDetailsApproval extends StatefulWidget {
  final Land land;

  const LandDetailsApproval({super.key, required this.land});

  @override
  State<LandDetailsApproval> createState() => _LandDetailsApprovalState();
}

class _LandDetailsApprovalState extends State<LandDetailsApproval> {
  bool _isApproving = false;
  String? _rejectionReason;
  final _rejectionController = TextEditingController();
  
  // Financial data controllers
  final _estimatedCostController = TextEditingController();
  final _expectedRevenueController = TextEditingController();
  final _evaluationYearsController = TextEditingController(text: '5');

  @override
  void dispose() {
    _rejectionController.dispose();
    _estimatedCostController.dispose();
    _expectedRevenueController.dispose();
    _evaluationYearsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final land = widget.land;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Land Details - Approval'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with Status Badge
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            land.name,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              land.reviewStatus,
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Location Section
              _buildSectionHeader(context, 'Location Details'),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: land.location,
              ),
              if (land.phoneNumber != null && land.phoneNumber!.isNotEmpty)
                _buildInfoCard(
                  icon: Icons.phone_outlined,
                  label: 'Phone Number',
                  value: land.phoneNumber!,
                ),
              _buildInfoCard(
                icon: Icons.landscape_outlined,
                label: 'Land Size',
                value: '${land.size} acres',
              ),
              const SizedBox(height: 24),

              // Zoning & Properties
              _buildSectionHeader(context, 'Property Details'),
              const SizedBox(height: 12),
              _buildInfoCard(
                icon: Icons.domain_outlined,
                label: 'Zoning Type',
                value: land.zoning,
              ),
              _buildInfoCard(
                icon: Icons.description_outlined,
                label: 'Development Stage',
                value: land.stage,
              ),
              const SizedBox(height: 24),

              // Utilities
              if (land.utilities != null && land.utilities!.isNotEmpty) ...[
                _buildSectionHeader(context, 'Available Utilities'),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: land.utilities!
                      .map((utility) => Chip(
                    label: Text(utility),
                    avatar: const Icon(Icons.check_circle, size: 20),
                    backgroundColor: Colors.green.shade100,
                    labelStyle: TextStyle(
                      color: Colors.green.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ))
                      .toList(),
                ),
                const SizedBox(height: 24),
              ],

              // Project Files
              if (land.legalDocuments != null && land.legalDocuments!.isNotEmpty) ...[
                _buildSectionHeader(context, 'Project Files'),
                const SizedBox(height: 12),
                _buildProjectFilesDisplay(land.legalDocuments!),
                const SizedBox(height: 24),
              ],

              // Admin Notes (if any)
              if (land.adminNotes != null && land.adminNotes!.isNotEmpty) ...[
                _buildSectionHeader(context, 'Admin Notes'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber.shade300),
                  ),
                  child: Text(
                    land.adminNotes!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Summary Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Land Owner ID:', style: Theme.of(context).textTheme.bodySmall),
                        Text('${land.ownerId}', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Submission Status:', style: Theme.of(context).textTheme.bodySmall),
                        Text(land.reviewStatus, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
              if (land.reviewStatus == 'PENDING') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isApproving
                            ? null
                            : () {
                          _showFinancialDataDialog(context);
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve Land'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _isApproving
                            ? null
                            : () {
                          _showRejectionDialog(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Reject'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // If already approved/rejected, show status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: land.reviewStatus == 'APPROVED'
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: land.reviewStatus == 'APPROVED'
                          ? Colors.green.shade300
                          : Colors.red.shade300,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        land.reviewStatus == 'APPROVED'
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: land.reviewStatus == 'APPROVED'
                            ? Colors.green
                            : Colors.red,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        land.reviewStatus == 'APPROVED'
                            ? 'This land has been approved'
                            : 'This land has been rejected',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFilesDisplay(String filePathsString) {
    // Parse pipe-delimited file paths
    final filePaths = filePathsString.split('|')
        .where((path) => path.trim().isNotEmpty)
        .toList();

    if (filePaths.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Center(
          child: Text(
            'No files uploaded',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          // File count header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_open, color: Colors.blue.shade700, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${filePaths.length} file(s) uploaded',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
          // File list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filePaths.length,
            itemBuilder: (context, index) {
              final filePath = filePaths[index].trim();
              final fileName = filePath.split('/').last;
              
              // Try to get file size if file exists
              String fileSizeText = '';
              try {
                final file = File(filePath);
                if (file.existsSync()) {
                  final sizeInBytes = file.lengthSync();
                  final sizeInMB = (sizeInBytes / (1024 * 1024)).toStringAsFixed(2);
                  fileSizeText = '$sizeInMB MB';
                }
              } catch (e) {
                fileSizeText = 'File not found';
              }

              return Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: index < filePaths.length - 1 ? 1 : 0,
                    ),
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: Colors.blue.shade600,
                    size: 28,
                  ),
                  title: Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    fileSizeText.isNotEmpty ? fileSizeText : filePath,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.download, color: Colors.blue.shade600),
                    onPressed: () {
                      // TODO: Implement download functionality
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Download feature coming soon for: $fileName'),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showRejectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reject Land Submission'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Please provide a reason for rejection:'),
                const SizedBox(height: 12),
                TextField(
                  controller: _rejectionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Enter rejection reason...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_rejectionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a rejection reason')),
                  );
                  return;
                }

                if (widget.land.id != null) {
                  try {
                    await context.read<AppState>().adminRejectLand(
                      widget.land.id!,
                      adminNotes: _rejectionController.text.trim(),
                    );
                    if (mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.land.name} rejected'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      Navigator.pop(context, true); // Return to approval screen
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error rejecting land: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showFinancialDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Financial Details for Project'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Enter financial information for the project:'),
                const SizedBox(height: 16),
                
                // Estimated Cost
                TextField(
                  controller: _estimatedCostController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Estimated Project Cost (₹)',
                    hintText: 'E.g., 10000000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.currency_rupee),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Expected Annual Revenue
                TextField(
                  controller: _expectedRevenueController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Expected Annual Revenue (₹)',
                    hintText: 'E.g., 1500000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.trending_up),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Evaluation Years
                TextField(
                  controller: _evaluationYearsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Evaluation Period (Years)',
                    hintText: 'E.g., 5',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Financial calculations will be performed:',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Expected ROI (Return on Investment)'),
                      const Text('• IRR (Internal Rate of Return)'),
                      const Text('• Payback Period'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_estimatedCostController.text.trim().isEmpty ||
                    _expectedRevenueController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill in all required fields')),
                  );
                  return;
                }

                if (widget.land.id != null) {
                  try {
                    setState(() => _isApproving = true);
                    
                    double estimatedCost = double.tryParse(_estimatedCostController.text) ?? 0.0;
                    double expectedRevenue = double.tryParse(_expectedRevenueController.text) ?? 0.0;
                    int years = int.tryParse(_evaluationYearsController.text) ?? 5;

                    // Call the conversion endpoint
                    await context.read<AppState>().convertLandToProject(
                      widget.land.id!,
                      {
                        'title': '${widget.land.name} Project',
                        'estimatedCost': estimatedCost,
                        'expectedAnnualRevenue': expectedRevenue,
                        'evaluationYears': years,
                      },
                    );

                    if (mounted) {
                      Navigator.pop(context); // Close dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${widget.land.name} approved! Project created with financial details.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context, true); // Return to approval screen
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error approving land: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } finally {
                    if (mounted) setState(() => _isApproving = false);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Create Project', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
