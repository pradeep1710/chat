import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../controllers/status_create_controller.dart';
import '../../core/themes/app_colors.dart';

class StatusCreateScreen extends GetView<StatusCreateController> {
  const StatusCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(StatusCreateController());

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: const Icon(Icons.close),
        ),
        actions: [
          Obx(() => controller.selectedMedia.value != null
              ? IconButton(
                  onPressed: controller.postStatus,
                  icon: controller.isPosting.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send),
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Column(
        children: [
          // Media preview or text input
          Expanded(
            child: Obx(() => _buildMainContent()),
          ),
          
          // Bottom controls
          _buildBottomControls(),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (controller.selectedMedia.value != null) {
      return _buildMediaPreview();
    } else {
      return _buildTextStatusEditor();
    }
  }

  Widget _buildMediaPreview() {
    final media = controller.selectedMedia.value!;
    
    return Stack(
      children: [
        Center(
          child: media.type == 'image'
              ? Image.file(
                  File(media.path),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                )
              : _buildVideoPlayer(media.path),
        ),
        
        // Caption input
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(25),
            ),
            child: TextField(
              controller: controller.captionController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: TextStyle(color: Colors.white70),
                border: InputBorder.none,
              ),
              maxLines: 3,
              minLines: 1,
            ),
          ),
        ),
        
        // Drawing tools (if image)
        if (media.type == 'image')
          Positioned(
            top: 20,
            right: 20,
            child: Column(
              children: [
                _buildToolButton(
                  icon: Icons.brush,
                  onTap: () => controller.toggleDrawing(),
                  isActive: controller.isDrawing.value,
                ),
                const SizedBox(height: 12),
                _buildToolButton(
                  icon: Icons.text_fields,
                  onTap: () => controller.addText(),
                ),
                const SizedBox(height: 12),
                _buildToolButton(
                  icon: Icons.emoji_emotions,
                  onTap: () => controller.addEmoji(),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVideoPlayer(String path) {
    return Obx(() {
      if (controller.videoController == null) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      }

      return AspectRatio(
        aspectRatio: controller.videoController!.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller.videoController!),
            if (!controller.videoController!.value.isPlaying)
              GestureDetector(
                onTap: () => controller.videoController!.play(),
                child: Container(
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
              ),
          ],
        ),
      );
    });
  }

  Widget _buildTextStatusEditor() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          
          // Background color selector
          Container(
            height: 60,
            margin: const EdgeInsets.only(bottom: 20),
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.backgroundColors.length,
              itemBuilder: (context, index) {
                final color = controller.backgroundColors[index];
                final isSelected = controller.selectedBackgroundIndex.value == index;
                
                return GestureDetector(
                  onTap: () => controller.selectBackground(index),
                  child: Container(
                    width: 60,
                    height: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      gradient: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 24,
                          )
                        : null,
                  ),
                );
              },
            )),
          ),
          
          // Text input
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: Obx(() => controller.selectedBackground),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: controller.textController,
                focusNode: controller.textFocusNode,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
                decoration: const InputDecoration(
                  hintText: 'Type a status...',
                  hintStyle: TextStyle(
                    color: Colors.white70,
                    fontSize: 24,
                  ),
                  border: InputBorder.none,
                ),
                textAlign: TextAlign.center,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Font selector
          Container(
            height: 50,
            margin: const EdgeInsets.only(top: 20),
            child: Obx(() => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.fonts.length,
              itemBuilder: (context, index) {
                final font = controller.fonts[index];
                final isSelected = controller.selectedFontIndex.value == index;
                
                return GestureDetector(
                  onTap: () => controller.selectFont(index),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.white24,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      'Aa',
                      style: TextStyle(
                        fontFamily: font['family'],
                        fontWeight: font['weight'],
                        color: isSelected ? Colors.black : Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: Icons.photo_library,
            label: 'Gallery',
            onTap: () => controller.pickFromGallery(),
          ),
          _buildControlButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: () => controller.pickFromCamera(),
          ),
          _buildControlButton(
            icon: Icons.text_fields,
            label: 'Text',
            onTap: () => controller.createTextStatus(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white24,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }
}