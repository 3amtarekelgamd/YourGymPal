import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/settings_controller.dart';
import '../../models/workout_template.dart';
import 'dart:io';

/// A reusable card widget for displaying workout information
class WorkoutCard extends StatelessWidget {
  final WorkoutTemplate template;
  final VoidCallback? onEdit;
  final VoidCallback? onStart;
  final VoidCallback? onDelete;
  final Color? cardColor;

  const WorkoutCard({
    super.key,
    required this.template,
    this.onEdit,
    this.onStart,
    this.onDelete,
    this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();

    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cover image if available
          if (template.coverImagePath != null)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: FileImage(File(template.coverImagePath!)),
                  onError: (_, __) => const Icon(Icons.broken_image),
                ),
              ),
            ),

          // Header with workout type
          Container(
            width: double.infinity,
            color: cardColor?.withOpacity(0.8) ?? Colors.blue.withOpacity(0.8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              template.name,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  template.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Exercise count
                Text(
                  'Exercises: ${template.exercises.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),

                // Exercise summary
                if (template.exercises.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (var i = 0;
                            i < 3 && i < template.exercises.length;
                            i++)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${template.exercises[i].name} - ${template.exercises[i].targetSets}×${template.exercises[i].targetReps} ${template.exercises[i].weight > 0 ? '(${settingsController.getFormattedWeight(template.exercises[i].weight)})' : ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        if (template.exercises.length > 3)
                          Text(
                            '... and ${template.exercises.length - 3} more',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontStyle: FontStyle.italic,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),

                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (onEdit != null)
                      OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                      )
                    else
                      const SizedBox.shrink(),
                    if (onDelete != null)
                      OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, color: Colors.red),
                        label: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    if (onStart != null)
                      ElevatedButton.icon(
                        onPressed: onStart,
                        icon: const Icon(Icons.fitness_center),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
