import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';
import '../../services/media/media_service.dart';

class ProfileSetupScreen extends GetView<AuthController> {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController statusController = TextEditingController(
      text: 'Hey there! I am using ChatApp',
    );
    final FocusNode statusFocusNode = FocusNode();
    final RxString profilePicturePath = ''.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Set up your profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'Add a profile picture and status to let others know about you.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Profile picture section
              Center(
                child: Column(
                  children: [
                    Obx(() => GestureDetector(
                      onTap: () => _showImagePicker(profilePicturePath),
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.surfaceVariant,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                          image: profilePicturePath.value.isNotEmpty
                              ? DecorationImage(
                                  image: FileImage(File(profilePicturePath.value)),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: profilePicturePath.value.isEmpty
                            ? const Icon(
                                Icons.camera_alt_rounded,
                                size: 40,
                                color: AppColors.onSurfaceVariant,
                              )
                            : null,
                      ),
                    )),
                    
                    const SizedBox(height: 16),
                    
                    Text(
                      profilePicturePath.value.isEmpty 
                          ? 'Tap to add profile picture' 
                          : 'Tap to change picture',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Status input
              CustomTextField(
                controller: statusController,
                focusNode: statusFocusNode,
                hintText: 'Enter your status',
                labelText: 'Status',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.info_outline_rounded,
                maxLength: 100,
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a status';
                  }
                  return null;
                },
                onSubmitted: (_) => _completeSetup(
                  statusController.text.trim(),
                  profilePicturePath.value,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Privacy info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Your profile picture and status will be visible to your contacts',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Complete setup button
              Obx(() => LoadingButton(
                onPressed: () => _completeSetup(
                  statusController.text.trim(),
                  profilePicturePath.value,
                ),
                isLoading: controller.isLoading,
                text: 'Complete Setup',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              )),
              
              const SizedBox(height: 16),
              
              // Skip button
              Center(
                child: TextButton(
                  onPressed: () => Get.offAllNamed(AppRoutes.home),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImagePicker(RxString profilePicturePath) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConfig.borderRadius * 2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ImagePickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: () async {
                    Get.back();
                    final mediaService = Get.find<MediaService>();
                    final file = await mediaService.pickImageFromCamera();
                    if (file != null) {
                      profilePicturePath.value = file.path;
                    }
                  },
                ),
                
                _ImagePickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: () async {
                    Get.back();
                    final mediaService = Get.find<MediaService>();
                    final file = await mediaService.pickImageFromGallery();
                    if (file != null) {
                      profilePicturePath.value = file.path;
                    }
                  },
                ),
                
                if (profilePicturePath.value.isNotEmpty)
                  _ImagePickerOption(
                    icon: Icons.delete_rounded,
                    label: 'Remove',
                    color: AppColors.error,
                    onTap: () {
                      Get.back();
                      profilePicturePath.value = '';
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _completeSetup(String status, String profilePicturePath) async {
    if (status.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a status',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.updateProfile(
      status: status,
      profilePicture: profilePicturePath.isNotEmpty ? profilePicturePath : null,
    );

    if (success) {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}

class _ImagePickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _ImagePickerOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: effectiveColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: effectiveColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: effectiveColor,
              size: 28,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: effectiveColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}