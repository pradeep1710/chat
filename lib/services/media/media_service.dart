import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final ImagePicker _imagePicker = ImagePicker();
  
  // Image picking
  Future<File?> pickImageFromGallery() async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Gallery permission denied');
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }
  
  Future<File?> pickImageFromCamera() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      return image != null ? File(image.path) : null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }
  
  // Video picking
  Future<File?> pickVideoFromGallery() async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Gallery permission denied');
      }
      
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(minutes: 5),
      );
      
      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('Error picking video from gallery: $e');
      return null;
    }
  }
  
  Future<File?> pickVideoFromCamera() async {
    try {
      final permission = await Permission.camera.request();
      if (!permission.isGranted) {
        throw Exception('Camera permission denied');
      }
      
      final XFile? video = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(minutes: 5),
      );
      
      return video != null ? File(video.path) : null;
    } catch (e) {
      debugPrint('Error picking video from camera: $e');
      return null;
    }
  }
  
  // File picking
  Future<File?> pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'],
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error picking document: $e');
      return null;
    }
  }
  
  Future<File?> pickAudio() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.audio,
        allowMultiple: false,
      );
      
      if (result != null && result.files.isNotEmpty) {
        return File(result.files.first.path!);
      }
      
      return null;
    } catch (e) {
      debugPrint('Error picking audio: $e');
      return null;
    }
  }
  
  // Multiple file picking
  Future<List<File>> pickMultipleImages() async {
    try {
      final permission = await Permission.photos.request();
      if (!permission.isGranted) {
        throw Exception('Gallery permission denied');
      }
      
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );
      
      return images.map((image) => File(image.path)).toList();
    } catch (e) {
      debugPrint('Error picking multiple images: $e');
      return [];
    }
  }
  
  // File operations
  Future<String> getTemporaryDirectoryPath() async {
    final directory = await getTemporaryDirectory();
    return directory.path;
  }
  
  Future<String> getApplicationDocumentsDirectoryPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  Future<int> getFileSize(File file) async {
    try {
      return await file.length();
    } catch (e) {
      debugPrint('Error getting file size: $e');
      return 0;
    }
  }
  
  String getFileExtension(File file) {
    return file.path.split('.').last.toLowerCase();
  }
  
  String getFileName(File file) {
    return file.path.split('/').last;
  }
  
  bool isImageFile(File file) {
    final extension = getFileExtension(file);
    return ['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension);
  }
  
  bool isVideoFile(File file) {
    final extension = getFileExtension(file);
    return ['mp4', 'avi', 'mov', 'mkv', 'webm'].contains(extension);
  }
  
  bool isAudioFile(File file) {
    final extension = getFileExtension(file);
    return ['mp3', 'wav', 'aac', 'm4a', 'ogg'].contains(extension);
  }
  
  bool isDocumentFile(File file) {
    final extension = getFileExtension(file);
    return ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'].contains(extension);
  }
  
  // Permission checking
  Future<bool> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }
  
  Future<bool> checkGalleryPermission() async {
    final status = await Permission.photos.status;
    return status.isGranted;
  }
  
  Future<bool> checkMicrophonePermission() async {
    final status = await Permission.microphone.status;
    return status.isGranted;
  }
  
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }
  
  Future<bool> requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }
  
  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }
}