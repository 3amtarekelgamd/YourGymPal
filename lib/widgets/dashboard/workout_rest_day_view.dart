import 'package:flutter/material.dart';

class WorkoutRestDayView extends StatelessWidget {
  const WorkoutRestDayView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Today is your rest day. Take it easy!',
        style: TextStyle(
          fontSize: 16,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
} 