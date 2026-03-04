import 'package:flutter/material.dart';

class MilestoneTile extends StatelessWidget {
  final String title;
  final bool completed;
  final bool inProgress;

  MilestoneTile({
    required this.title,
    this.completed = false,
    this.inProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    if (completed) {
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (inProgress) {
      icon = Icons.autorenew;
      color = Colors.orange;
    } else {
      icon = Icons.radio_button_unchecked;
      color = Colors.grey;
    }

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
    );
  }
}