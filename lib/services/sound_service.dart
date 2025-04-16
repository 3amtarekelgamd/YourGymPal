import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';

/// Service to handle playing sound effects in the app
class SoundService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  /// Initialize the service
  Future<SoundService> init() async {
    return this;
  }

  /// Play the beep sound
  Future<void> playBeep() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/beep.mp3'));
    } catch (e) {
      debugPrint('Error playing beep sound: $e');
    }
  }

  /// Play the timer completion sound
  Future<void> playTimerComplete() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/timer_complete.mp3'));
    } catch (e) {
      debugPrint('Error playing timer complete sound: $e');
    }
  }

  /// Dispose resources when service is no longer needed
  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }
}
