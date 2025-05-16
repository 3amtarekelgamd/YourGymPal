import 'package:flutter/material.dart';
import '../../models/models.dart';

/// Workout type label with colored indicator
class WorkoutTypeLabel extends StatelessWidget {
  final String workoutType;
  final bool isCompact;
  
  const WorkoutTypeLabel({
    super.key,
    required this.workoutType,
    this.isCompact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8.0 : 12.0,
        vertical: isCompact ? 4.0 : 6.0,
      ),
      decoration: BoxDecoration(
        color: WorkoutType.getColorForType(workoutType).withOpacity(0.2),
        borderRadius: BorderRadius.circular(isCompact ? 12.0 : 16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: isCompact ? 8.0 : 12.0,
            height: isCompact ? 8.0 : 12.0,
            decoration: BoxDecoration(
              color: WorkoutType.getColorForType(workoutType),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: isCompact ? 4.0 : 8.0),
          Text(
            workoutType,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isCompact ? 12.0 : 14.0,
            ),
          ),
        ],
      ),
    );
  }
} 