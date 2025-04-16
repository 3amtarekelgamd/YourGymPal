import 'package:flutter/material.dart';

class WorkoutExerciseList extends StatelessWidget {
  final List<String> exercises;

  const WorkoutExerciseList({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: exercises
          .map(
            (exercise) => Padding(
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
            ),
          )
          .toList(),
    );
  }
}
