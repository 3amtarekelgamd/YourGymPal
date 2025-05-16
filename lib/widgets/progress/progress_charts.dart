import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../controllers/workout_controller.dart';

class WorkoutDurationChart extends StatelessWidget {
  const WorkoutDurationChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock data for duration trend
    final durationData = [
      const FlSpot(0, 45), // Day 1: 45 mins
      const FlSpot(1, 50), // Day 2: 50 mins
      const FlSpot(2, 48), // Day 3: 48 mins
      const FlSpot(3, 55), // Day 4: 55 mins
      const FlSpot(4, 60), // Day 5: 60 mins
      const FlSpot(5, 65), // Day 6: 65 mins
      const FlSpot(6, 63), // Day 7: 63 mins
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()} min',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                // Show day numbers
                return Text(
                  'Day ${(value + 1).toInt()}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 6,
        minY: 30, // Start at 30 mins to show better detail
        maxY: 70,
        lineBarsData: [
          LineChartBarData(
            spots: durationData,
            isCurved: true,
            color: Colors.orange,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.orange.withOpacity(0.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chart showing distribution of workout types
class WorkoutTypeDistributionChart extends StatelessWidget {
  final Map<String, int> workoutCounts;
  final WorkoutController controller;

  const WorkoutTypeDistributionChart({
    super.key,
    required this.workoutCounts,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    // If there's no data, show a placeholder
    if (workoutCounts.isEmpty) {
      return const Center(
        child: Text(
          'No workout data yet',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    // Prepare data for pie chart
    final List<PieChartSectionData> sections = [];

    for (var entry in workoutCounts.entries) {
      final color = controller.getWorkoutColor(entry.key);
      sections.add(
        PieChartSectionData(
          color: color,
          value: entry.value.toDouble(),
          title: '${entry.value}',
          radius: 50,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    }

    return Row(
      children: [
        // Pie chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              startDegreeOffset: 180,
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: workoutCounts.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: controller.getWorkoutColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
