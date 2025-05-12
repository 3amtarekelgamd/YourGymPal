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
        title: const Text('Health & Progress'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Health Tips',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildHealthTipCard(
              icon: Icons.local_drink,
              color: Colors.blue[100]!,
              title: "Stay Hydrated",
              description:
                  "Drink at least 3-4 liters of water daily to maintain optimal body function and muscle recovery.",
            ),
            const SizedBox(height: 16),
            _buildHealthTipCard(
              icon: Icons.nightlight_round,
              color: Colors.purple[100]!,
              title: "Quality Sleep",
              description:
                  "Aim for 7-9 hours of sleep. Muscle recovery happens during deep sleep cycles.",
            ),
            const SizedBox(height: 16),
            _buildHealthTipCard(
              icon: Icons.restaurant,
              color: Colors.green[100]!,
              title: "Balanced Nutrition",
              description:
                  "Consume proteins, complex carbs, and healthy fats in every meal for sustained energy.",
            ),
            const SizedBox(height: 16),
            _buildHealthTipCard(
              icon: Icons.repeat,
              color: Colors.orange[100]!,
              title: "Consistency Matters",
              description:
                  "3 moderate workouts per week are better than 1 intense session followed by weeks of inactivity.",
            ),
            const SizedBox(height: 16),
            _buildHealthTipCard(
              icon: Icons.self_improvement,
              color: Colors.red[100]!,
              title: "Listen to Your Body",
              description:
                  "Rest when needed. Overtraining can lead to injuries and setbacks.",
            ),
            const SizedBox(height: 24),
            const Text(
              'Your Progress Summary',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ProgressSummaryTab(controller: Get.find<WorkoutController>()),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipCard({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
      final totalWorkouts = controller.workoutHistory.length;

      // Count workouts by type
      final workoutCounts = <String, int>{};
      for (var entry in controller.workoutHistory) {
        final type = entry.workoutType;
        workoutCounts[type] = (workoutCounts[type] ?? 0) + 1;
      }

      // Calculate streak
      int currentStreak = calculateStreak();

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
                    '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
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

  int calculateStreak() {
    if (controller.workoutHistory.isEmpty) return 0;

    // Sort workouts by date (newest first)
    final sortedWorkouts = List.of(controller.workoutHistory)
      ..sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime currentDate = DateTime.now();
    final today =
        DateTime(currentDate.year, currentDate.month, currentDate.day);

    // Check if today has workout
    final lastWorkoutDate = DateTime(sortedWorkouts.first.date.year,
        sortedWorkouts.first.date.month, sortedWorkouts.first.date.day);

    if (lastWorkoutDate == today) {
      streak++;
      currentDate = currentDate.subtract(const Duration(days: 1));
    } else {
      // No workout today - streak is 0
      return 0;
    }

    for (var workout in sortedWorkouts.skip(1)) {
      final workoutDate =
          DateTime(workout.date.year, workout.date.month, workout.date.day);

      // Skip future dates (if any)
      if (workoutDate.isAfter(today)) continue;

      // Check consecutive days
      while (true) {
        final previousDate =
            DateTime(currentDate.year, currentDate.month, currentDate.day);

        if (workoutDate == previousDate) {
          streak++;
          currentDate = currentDate.subtract(const Duration(days: 1));
          break;
        } else if (workoutDate.isBefore(previousDate)) {
          // Found a gap - streak ends
          return streak;
        } else {
          // Move to next day
          currentDate = currentDate.subtract(const Duration(days: 1));
        }
      }
    }

    return streak;
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
