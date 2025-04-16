import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color textColor;

  const StatusChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: backgroundColor,
      labelStyle: TextStyle(
        color: backgroundColor != null ? textColor : null,
        fontSize: 10,
      ),
    );
  }
} 