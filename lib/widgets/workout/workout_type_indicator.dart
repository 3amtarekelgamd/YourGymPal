import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Widget that displays a colored circle indicator for workout type
class WorkoutTypeIndicator extends StatelessWidget {
  final String workoutType;
  final double size;

  const WorkoutTypeIndicator({
    super.key,
    required this.workoutType,
    this.size = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(
        color: WorkoutType.getColorForType(workoutType),
        shape: BoxShape.circle,
      ),
    );
  }
} 