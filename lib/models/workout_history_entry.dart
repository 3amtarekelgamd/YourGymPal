import 'workout_status.dart';

/// Workout History entry
class WorkoutHistoryEntry {
  final DateTime date;
  final String workoutType;
  final WorkoutStatus status;
  final List<Map<String, dynamic>>? exercises;
  final int totalSets;
  final int completedSets;
  final Duration? duration;

  WorkoutHistoryEntry({
    required this.date,
    required this.workoutType,
    required this.status,
    this.exercises,
    this.totalSets = 0,
    this.completedSets = 0,
    this.duration,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toString(),
      'type': workoutType,
      'status': status.toString().split('.').last,
      if (exercises != null) 'exercises': exercises,
      'totalSets': totalSets,
      'completedSets': completedSets,
      if (duration != null) 'duration': duration!.inSeconds,
    };
  }

  factory WorkoutHistoryEntry.fromJson(Map<String, dynamic> json) {
    return WorkoutHistoryEntry(
      date: DateTime.parse(json['date']),
      workoutType: json['type'],
      status: WorkoutStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => WorkoutStatus.active,
      ),
      exercises: json['exercises'] != null
          ? List<Map<String, dynamic>>.from(json['exercises'])
          : null,
      totalSets: json['totalSets'] ?? 0,
      completedSets: json['completedSets'] ?? 0,
      duration:
          json['duration'] != null ? Duration(seconds: json['duration']) : null,
    );
  }

  // Utility method to check if this entry is from today
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }
}
