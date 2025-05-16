import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Service to handle playing sound effects in the app
class SoundService extends GetxService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final RxBool isInitialized = false.obs;
  
  // Store loaded sounds to prevent reloading
  final Map<String, Source> _soundSources = {};

  /// Initialize the service and preload sounds
  Future<SoundService> init() async {
    try {
      // Preload common sounds
      await _preloadSound('beep.mp3');
      await _preloadSound('timer_complete.mp3');
      
      isInitialized.value = true;
      debugPrint('Sound service initialized successfully');
    } catch (e) {
      debugPrint('Error initializing sound service: $e');
      // Service can still work even if preloading fails
    }
    return this;
  }
  
  /// Preload a sound file
  Future<void> _preloadSound(String fileName) async {
    try {
      final source = AssetSource('sounds/$fileName');
      _soundSources[fileName] = source;
      debugPrint('Preloaded sound: $fileName');
    } catch (e) {
      debugPrint('Error preloading sound $fileName: $e');
    }
  }

  /// Play the beep sound
  Future<void> playBeep() async {
    _playSound('beep.mp3');
  }

  /// Play the timer completion sound
  Future<void> playTimerComplete() async {
    _playSound('timer_complete.mp3');
  }
  
  /// Play a sound file with error handling
  Future<void> _playSound(String fileName) async {
    try {
      Source source;
      if (_soundSources.containsKey(fileName)) {
        source = _soundSources[fileName]!;
      } else {
        source = AssetSource('sounds/$fileName');
        _soundSources[fileName] = source;
      }
      
      await _audioPlayer.play(source);
    } catch (e) {
      debugPrint('Error playing sound $fileName: $e');
    }
  }

  /// Dispose resources when service is no longer needed
  @override
  void onClose() {
    try {
      _audioPlayer.dispose();
      _soundSources.clear();
    } catch (e) {
      debugPrint('Error disposing sound service: $e');
    }
    super.onClose();
  }
}
