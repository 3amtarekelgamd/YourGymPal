import 'package:flutter/material.dart';

class ExerciseListItem extends StatelessWidget {
  final String exercise;

  const ExerciseListItem({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(exercise),
          ),
        ],
      ),
    );
  }
}
