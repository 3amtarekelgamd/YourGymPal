import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ImageService extends GetxService {
  final ImagePicker _picker = ImagePicker();

  // Method to pick image from gallery
  Future<String?> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        return null;
      }

      return await _saveImageLocally(pickedFile);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  // Method to save image to local storage
  Future<String> _saveImageLocally(XFile image) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      final uniqueFileName =
          '${const Uuid().v4()}${path.extension(image.path)}';
      final savedImage =
          await File(image.path).copy('${imagesDir.path}/$uniqueFileName');

      return savedImage.path;
    } catch (e) {
      debugPrint('Error saving image: $e');
      return image.path;
    }
  }

  // Method to create directory for images if it doesn't exist
  Future<void> init() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images');

      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }
    } catch (e) {
      debugPrint('Error initializing image service: $e');
    }
  }

  // Method to delete an image
  Future<void> deleteImage(String? imagePath) async {
    if (imagePath == null) return;

    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }
}
