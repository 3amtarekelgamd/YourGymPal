import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/workout_controller.dart';
import '../models/workout_status.dart';
import '../widgets/progress/progress_charts.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress'),
      ),
      body: const Center(
        child: Text('Progress Screen'),
      ),
    );
  }
}

class ProgressSummaryTab extends StatelessWidget {
  final WorkoutController controller;

  const ProgressSummaryTab({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Calculate summary statistics
      final totalWorkouts = controller.workoutHistory.length;

      // Count workouts by type
      final workoutCounts = <String, int>{};
      for (var entry in controller.workoutHistory) {
        final type = entry.workoutType;
        workoutCounts[type] = (workoutCounts[type] ?? 0) + 1;
      }

      // Calculate streak (consecutive days with workouts)
      int currentStreak = 0;
      // (Streak calculation logic would go here)

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Total Workouts',
                    totalWorkouts.toString(),
                    Icons.fitness_center,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'Current Streak',
                    '$currentStreak days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Workout Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Workout type distribution
            SizedBox(
              height: 200,
              child: WorkoutTypeDistributionChart(
                workoutCounts: workoutCounts,
                controller: controller,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Recent workouts list
            ...controller.workoutHistory.take(5).map((entry) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        controller.getWorkoutColor(entry.workoutType),
                    child:
                        const Icon(Icons.fitness_center, color: Colors.white),
                  ),
                  title: Text(entry.workoutType),
                  subtitle: Text(
                    '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                  ),
                  trailing: entry.status == WorkoutStatus.completed
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : const Icon(Icons.cancel, color: Colors.red),
                ))
          ],
        ),
      );
    });
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
