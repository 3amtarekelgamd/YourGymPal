// ignore_for_file: unused_element

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Utility class for showing toast messages
class StatusToast {
  // Queue for messages to prevent duplicates and stacking
  static final List<_ToastMessage> _messageQueue = [];
  static bool _isShowingToast = false;

  /// Show an informational toast message
  static void showInfo(String message) {
    Get.snackbar(
      'Info',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      isDismissible: true,
    );
  }

  /// Show an error toast message
  static void showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }

  /// Show a success toast message
  static void showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.withOpacity(0.7),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
      isDismissible: true,
    );
  }

  /// Process the next toast in queue
  static void _processNextToast() {
    // If queue is empty or already showing, return
    if (_messageQueue.isEmpty) {
      _isShowingToast = false;
      return;
    }

    _isShowingToast = true;
    final nextToast = _messageQueue.removeAt(0);

    // Show the toast
    Get.snackbar(
      nextToast.title,
      nextToast.message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: nextToast.backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: nextToast.durationSeconds),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutCirc,
      snackStyle: SnackStyle.FLOATING,
      onTap: (_) {
        Get.closeCurrentSnackbar();
        Future.delayed(const Duration(milliseconds: 300), _processNextToast);
      },
      overlayBlur: 0,
    ).future.then((_) {
      // When this toast is done, process the next one
      Future.delayed(const Duration(milliseconds: 300), _processNextToast);
    });
  }

  /// Clear all pending toasts
  static void clearAll() {
    _messageQueue.clear();
    if (_isShowingToast) {
      Get.closeCurrentSnackbar();
    }
    _isShowingToast = false;
  }
}

/// Internal class to represent a toast message
class _ToastMessage {
  final String title;
  final String message;
  final Color backgroundColor;
  final int durationSeconds;

  _ToastMessage(
      {required this.title,
      required this.message,
      required this.backgroundColor,
      required this.durationSeconds});
}
