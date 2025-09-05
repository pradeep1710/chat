import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

class StatusViewerController extends GetxController {
  final List<dynamic> statuses;
  final int initialIndex;
  
  // Controllers
  late PageController pageController;
  final TextEditingController replyController = TextEditingController();
  
  // Observable variables
  final RxInt _currentIndex = 0.obs;
  final RxDouble _progress = 0.0.obs;
  final RxBool _isLiked = false.obs;
  final RxBool _isPaused = false.obs;
  
  // Timer for auto-advancing
  Timer? _timer;
  Timer? _progressTimer;
  
  // Video controllers
  final Map<int, VideoPlayerController> _videoControllers = {};
  
  // Getters
  int get currentIndex => _currentIndex.value;
  double get progress => _progress.value;
  bool get isLiked => _isLiked.value;
  bool get isPaused => _isPaused.value;
  dynamic get currentStatus => statuses[_currentIndex.value];
  VideoPlayerController? get currentVideoController => _videoControllers[_currentIndex.value];

  StatusViewerController({
    required this.statuses,
    required this.initialIndex,
  });

  @override
  void onInit() {
    super.onInit();
    _currentIndex.value = initialIndex;
    pageController = PageController(initialPage: initialIndex);
    _startStatusTimer();
    _initializeCurrentVideo();
  }

  @override
  void onClose() {
    _timer?.cancel();
    _progressTimer?.cancel();
    pageController.dispose();
    replyController.dispose();
    
    // Dispose all video controllers
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    _videoControllers.clear();
    
    super.onClose();
  }

  void onPageChanged(int index) {
    _currentIndex.value = index;
    _progress.value = 0.0;
    _isLiked.value = false; // Reset like status for new status
    
    _timer?.cancel();
    _progressTimer?.cancel();
    
    // Pause previous video if any
    _pauseAllVideos();
    
    // Initialize current video if needed
    _initializeCurrentVideo();
    
    // Start timer for current status
    _startStatusTimer();
  }

  void _startStatusTimer() {
    final currentStatusData = currentStatus;
    final duration = _getStatusDuration(currentStatusData);
    
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPaused.value) {
        _progress.value += 0.05 / duration;
        
        if (_progress.value >= 1.0) {
          _progress.value = 1.0;
          timer.cancel();
          _moveToNextStatus();
        }
      }
    });
  }

  int _getStatusDuration(dynamic status) {
    switch (status['type']) {
      case 'text':
        return 5; // 5 seconds for text status
      case 'image':
        return 5; // 5 seconds for image status
      case 'video':
        final videoController = _videoControllers[_currentIndex.value];
        if (videoController != null && videoController.value.isInitialized) {
          return videoController.value.duration.inSeconds;
        }
        return 10; // Default 10 seconds if video not initialized
      default:
        return 5;
    }
  }

  void _moveToNextStatus() {
    if (_currentIndex.value < statuses.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // End of statuses, go back
      Get.back();
    }
  }

  void pauseTimer() {
    _isPaused.value = true;
    
    // Pause video if playing
    final videoController = _videoControllers[_currentIndex.value];
    if (videoController != null && videoController.value.isPlaying) {
      videoController.pause();
    }
  }

  void resumeTimer() {
    _isPaused.value = false;
    
    // Resume video if it was playing
    final videoController = _videoControllers[_currentIndex.value];
    if (videoController != null && videoController.value.isInitialized) {
      final status = currentStatus;
      if (status['type'] == 'video') {
        videoController.play();
      }
    }
  }

  void _initializeCurrentVideo() {
    final status = currentStatus;
    if (status['type'] == 'video' && status['media']?['url'] != null) {
      final index = _currentIndex.value;
      
      if (!_videoControllers.containsKey(index)) {
        final controller = VideoPlayerController.networkUrl(
          Uri.parse(status['media']['url']),
        );
        
        _videoControllers[index] = controller;
        
        controller.initialize().then((_) {
          controller.play();
          update(); // Trigger UI update
        }).catchError((error) {
          print('Error initializing video: $error');
        });
      } else {
        // Video already initialized, just play it
        _videoControllers[index]?.play();
      }
    }
  }

  void _pauseAllVideos() {
    for (var controller in _videoControllers.values) {
      if (controller.value.isPlaying) {
        controller.pause();
      }
    }
  }

  void toggleVideoPlayback() {
    final videoController = _videoControllers[_currentIndex.value];
    if (videoController != null && videoController.value.isInitialized) {
      if (videoController.value.isPlaying) {
        videoController.pause();
        pauseTimer();
      } else {
        videoController.play();
        resumeTimer();
      }
    }
  }

  void toggleLike() {
    _isLiked.value = !_isLiked.value;
    
    // TODO: Send like/unlike to server
    final status = currentStatus;
    print('${_isLiked.value ? 'Liked' : 'Unliked'} status: ${status['id']}');
  }

  void sendReply(String message) {
    if (message.trim().isEmpty) return;
    
    // TODO: Send reply to server
    final status = currentStatus;
    print('Reply to status ${status['id']}: $message');
    
    replyController.clear();
    Get.snackbar('Sent', 'Reply sent successfully');
  }

  // Navigation methods
  void goToPrevious() {
    if (_currentIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToNext() {
    if (_currentIndex.value < statuses.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }
}