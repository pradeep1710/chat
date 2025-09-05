import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../services/api/api_service.dart';
import '../controllers/status_controller.dart';

class StatusCreateController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  
  // Controllers
  final TextEditingController textController = TextEditingController();
  final TextEditingController captionController = TextEditingController();
  final FocusNode textFocusNode = FocusNode();
  
  // Observable variables
  final Rxn<MediaFile> _selectedMedia = Rxn<MediaFile>();
  final RxBool _isPosting = false.obs;
  final RxBool _isDrawing = false.obs;
  final RxInt _selectedBackgroundIndex = 0.obs;
  final RxInt _selectedFontIndex = 0.obs;
  
  // Video player
  VideoPlayerController? videoController;
  
  // Getters
  Rxn<MediaFile> get selectedMedia => _selectedMedia;
  bool get isPosting => _isPosting.value;
  bool get isDrawing => _isDrawing.value;
  int get selectedBackgroundIndex => _selectedBackgroundIndex.value;
  int get selectedFontIndex => _selectedFontIndex.value;
  
  // Background gradients
  final List<LinearGradient> backgroundColors = [
    const LinearGradient(
      colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFf093fb), Color(0xFFf5576c)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF4facfe), Color(0xFF00f2fe)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF43e97b), Color(0xFF38f9d7)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFfa709a), Color(0xFFfee140)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFFffecd2), Color(0xFFfcb69f)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    const LinearGradient(
      colors: [Color(0xFF89f7fe), Color(0xFF66a6ff)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  ];
  
  // Font styles
  final List<Map<String, dynamic>> fonts = [
    {'family': null, 'weight': FontWeight.normal},
    {'family': null, 'weight': FontWeight.bold},
    {'family': 'Roboto', 'weight': FontWeight.normal},
    {'family': 'Roboto', 'weight': FontWeight.bold},
  ];
  
  LinearGradient get selectedBackground => backgroundColors[_selectedBackgroundIndex.value];

  @override
  void onClose() {
    textController.dispose();
    captionController.dispose();
    textFocusNode.dispose();
    videoController?.dispose();
    super.onClose();
  }

  Future<void> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options for image or video
      final result = await Get.bottomSheet<String>(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.photo),
                title: const Text('Photo'),
                onTap: () => Get.back(result: 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () => Get.back(result: 'video'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
      
      if (result != null) {
        XFile? file;
        if (result == 'image') {
          file = await picker.pickImage(source: ImageSource.gallery);
        } else {
          file = await picker.pickVideo(source: ImageSource.gallery);
        }
        
        if (file != null) {
          _setSelectedMedia(file.path, result);
        }
      }
    } catch (e) {
      print('Error picking from gallery: $e');
      Get.snackbar('Error', 'Failed to pick media from gallery');
    }
  }

  Future<void> pickFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      
      // Show options for photo or video
      final result = await Get.bottomSheet<String>(
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take Photo'),
                onTap: () => Get.back(result: 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Record Video'),
                onTap: () => Get.back(result: 'video'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );
      
      if (result != null) {
        XFile? file;
        if (result == 'image') {
          file = await picker.pickImage(source: ImageSource.camera);
        } else {
          file = await picker.pickVideo(source: ImageSource.camera);
        }
        
        if (file != null) {
          _setSelectedMedia(file.path, result);
        }
      }
    } catch (e) {
      print('Error picking from camera: $e');
      Get.snackbar('Error', 'Failed to capture media');
    }
  }

  void createTextStatus() {
    _selectedMedia.value = null;
    videoController?.dispose();
    videoController = null;
    textFocusNode.requestFocus();
  }

  void _setSelectedMedia(String path, String type) {
    _selectedMedia.value = MediaFile(path: path, type: type);
    
    if (type == 'video') {
      _initVideoPlayer(path);
    }
  }

  void _initVideoPlayer(String path) {
    videoController?.dispose();
    videoController = VideoPlayerController.file(File(path));
    videoController!.initialize().then((_) {
      update(); // Trigger UI update
    });
  }

  void selectBackground(int index) {
    _selectedBackgroundIndex.value = index;
  }

  void selectFont(int index) {
    _selectedFontIndex.value = index;
  }

  void toggleDrawing() {
    _isDrawing.value = !_isDrawing.value;
    // TODO: Implement drawing functionality
    Get.snackbar('Coming Soon', 'Drawing feature coming soon!');
  }

  void addText() {
    // TODO: Implement text overlay functionality
    Get.snackbar('Coming Soon', 'Text overlay feature coming soon!');
  }

  void addEmoji() {
    // TODO: Implement emoji picker
    Get.snackbar('Coming Soon', 'Emoji picker feature coming soon!');
  }

  Future<void> postStatus() async {
    if (_isPosting.value) return;
    
    try {
      _isPosting.value = true;
      
      final media = _selectedMedia.value;
      String content = '';
      String type = 'text';
      String? mediaPath;
      
      if (media != null) {
        // Media status
        type = media.type;
        mediaPath = media.path;
        content = captionController.text.trim();
      } else {
        // Text status
        content = textController.text.trim();
        if (content.isEmpty) {
          Get.snackbar('Error', 'Please enter some text for your status');
          return;
        }
      }
      
      // Upload media if needed
      if (mediaPath != null) {
        final uploadResponse = await _apiService.uploadMedia(mediaPath);
        if (uploadResponse['success'] == true) {
          mediaPath = uploadResponse['url'];
        } else {
          throw Exception('Failed to upload media');
        }
      }
      
      // Create status
      final statusController = Get.find<StatusController>();
      await statusController.createStatus(
        type: type,
        content: content,
        privacy: 'public', // TODO: Add privacy selection
        mediaPath: mediaPath,
      );
      
      // Go back
      Get.back();
      
    } catch (e) {
      print('Error posting status: $e');
      Get.snackbar('Error', 'Failed to post status');
    } finally {
      _isPosting.value = false;
    }
  }
}

class MediaFile {
  final String path;
  final String type; // 'image' or 'video'
  
  MediaFile({required this.path, required this.type});
}