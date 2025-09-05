import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:video_player/video_player.dart';

import '../../controllers/status_viewer_controller.dart';
import '../../core/themes/app_colors.dart';

class StatusViewerScreen extends GetView<StatusViewerController> {
  const StatusViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<dynamic> statuses = Get.arguments['statuses'];
    final int initialIndex = Get.arguments['initialIndex'] ?? 0;
    
    Get.put(StatusViewerController(statuses: statuses, initialIndex: initialIndex));

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Status content
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.statuses.length,
            itemBuilder: (context, index) {
              final status = controller.statuses[index];
              return _buildStatusContent(status);
            },
          ),
          
          // Top overlay
          _buildTopOverlay(),
          
          // Bottom overlay
          _buildBottomOverlay(),
          
          // Progress indicators
          _buildProgressIndicators(),
        ],
      ),
    );
  }

  Widget _buildStatusContent(dynamic status) {
    switch (status['type']) {
      case 'image':
        return _buildImageStatus(status);
      case 'video':
        return _buildVideoStatus(status);
      default:
        return _buildTextStatus(status);
    }
  }

  Widget _buildImageStatus(dynamic status) {
    return GestureDetector(
      onTapDown: (details) => controller.pauseTimer(),
      onTapUp: (details) => controller.resumeTimer(),
      onTapCancel: () => controller.resumeTimer(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: status['media']?['url'] != null
            ? CachedNetworkImage(
                imageUrl: status['media']['url'],
                fit: BoxFit.contain,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.error, color: Colors.white, size: 64),
                ),
              )
            : Container(
                color: Colors.grey[900],
                child: const Center(
                  child: Icon(Icons.image, color: Colors.white, size: 64),
                ),
              ),
      ),
    );
  }

  Widget _buildVideoStatus(dynamic status) {
    return Obx(() {
      final videoController = controller.currentVideoController;
      
      if (videoController == null || !videoController.value.isInitialized) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return GestureDetector(
        onTap: () => controller.toggleVideoPlayback(),
        child: AspectRatio(
          aspectRatio: videoController.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(videoController),
              if (!videoController.value.isPlaying)
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTextStatus(dynamic status) {
    return GestureDetector(
      onTapDown: (details) => controller.pauseTimer(),
      onTapUp: (details) => controller.resumeTimer(),
      onTapCancel: () => controller.resumeTimer(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF667eea), Color(0xFF764ba2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              status['content'] ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Obx(() {
                  final currentStatus = controller.currentStatus;
                  return Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary,
                          backgroundImage: currentStatus['user']?['profilePicture'] != null
                              ? CachedNetworkImageProvider(currentStatus['user']['profilePicture'])
                              : null,
                          child: currentStatus['user']?['profilePicture'] == null
                              ? Text(
                                  (currentStatus['user']?['username'] ?? 'U')[0].toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentStatus['user']?['username'] ?? 'Unknown',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _formatTime(currentStatus['createdAt']),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onSelected: (value) => _handleMenuAction(value),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Text('Report'),
                    ),
                    const PopupMenuItem(
                      value: 'block',
                      child: Text('Block'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black54, Colors.transparent],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.replyController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Reply to status...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.white24,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: controller.sendReply,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.toggleLike(),
                  child: Obx(() => Icon(
                    controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                    color: controller.isLiked.value ? Colors.red : Colors.white,
                    size: 28,
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicators() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Container(
          height: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(() => Row(
            children: List.generate(
              controller.statuses.length,
              (index) => Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: LinearProgressIndicator(
                    value: _getProgressValue(index),
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          )),
        ),
      ),
    );
  }

  double _getProgressValue(int index) {
    final currentIndex = controller.currentIndex.value;
    
    if (index < currentIndex) {
      return 1.0; // Completed
    } else if (index == currentIndex) {
      return controller.progress.value; // Current progress
    } else {
      return 0.0; // Not started
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    final dateTime = DateTime.parse(timestamp.toString());
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'report':
        // TODO: Implement report functionality
        Get.snackbar('Coming Soon', 'Report feature coming soon!');
        break;
      case 'block':
        // TODO: Implement block functionality
        Get.snackbar('Coming Soon', 'Block feature coming soon!');
        break;
    }
  }
}