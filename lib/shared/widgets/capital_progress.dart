import 'package:flutter/material.dart';

class CapitalProgress extends StatelessWidget {
  final double progress; // 0 to 1
  final String label;

  const CapitalProgress({
    super.key,
    required this.progress,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 6),
        Text("${(progress * 100).toInt()}% Funded"),
      ],
    );
  }
}