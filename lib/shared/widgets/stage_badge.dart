import 'package:flutter/material.dart';

class StageBadge extends StatelessWidget {
  final String stage;

  const StageBadge({
    super.key,
    required this.stage,
  });

  @override
  Widget build(BuildContext context) {
    Color color;

    switch (stage) {
      case "Feasibility":
        color = Colors.orange;
        break;
      case "Construction":
        color = Colors.blue;
        break;
      case "Operational":
        color = Colors.green;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        stage,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }
}