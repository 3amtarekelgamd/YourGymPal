import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../controllers/workout_controller.dart';

class RestTimerWidget extends StatefulWidget {
  final WorkoutController controller;

  const RestTimerWidget({
    super.key,
    required this.controller,
  });

  @override
  State<RestTimerWidget> createState() => _RestTimerWidgetState();
}

class _RestTimerWidgetState extends State<RestTimerWidget> {
  late WorkoutController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;

    // Start timer
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _controller.decrementRestTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isSetRest = _controller.isSetRest.value;
      final timeRemaining = _controller.restTimeRemaining.value;

      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isSetRest ? 'Rest Between Sets' : 'Rest Between Exercises',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            // Timer display
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CircularProgressIndicator(
                    value: timeRemaining / (isSetRest ? 60 : 120),
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      timeRemaining <= 3 ? Colors.red : Colors.blue,
                    ),
                  ),
                ),

                // Time remaining in large font
                Text(
                  '$timeRemaining',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Skip button
            ElevatedButton.icon(
              onPressed: _controller.skipRestTimer,
              icon: const Icon(Icons.skip_next),
              label: const Text('SKIP REST'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
