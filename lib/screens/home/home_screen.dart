import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';

class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatApp'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showLogoutDialog(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final user = controller.currentUser;
        
        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Card(
                elevation: AppConfig.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Profile picture
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primary,
                            backgroundImage: user.profilePicture != null
                                ? NetworkImage(user.profilePicture!)
                                : null,
                            child: user.profilePicture == null
                                ? Text(
                                    user.username[0].toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome, ${user.username}!',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.onSurface,
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                Text(
                                  user.phoneNumber,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                                
                                const SizedBox(height: 4),
                                
                                Text(
                                  user.status,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.onSurfaceVariant,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Features section
              const Text(
                'Features',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    _FeatureCard(
                      icon: Icons.chat_bubble_rounded,
                      title: 'Chats',
                      description: 'Start conversations',
                      color: AppColors.primary,
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Chat feature will be available soon!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.info,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    
                    _FeatureCard(
                      icon: Icons.groups_rounded,
                      title: 'Groups',
                      description: 'Create group chats',
                      color: AppColors.secondary,
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Group feature will be available soon!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.info,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    
                    _FeatureCard(
                      icon: Icons.public_rounded,
                      title: 'Communities',
                      description: 'Join communities',
                      color: AppColors.info,
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Community feature will be available soon!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.info,
                          colorText: Colors.white,
                        );
                      },
                    ),
                    
                    _FeatureCard(
                      icon: Icons.auto_stories_rounded,
                      title: 'Status',
                      description: 'Share your story',
                      color: AppColors.warning,
                      onTap: () {
                        Get.snackbar(
                          'Coming Soon',
                          'Status feature will be available soon!',
                          snackPosition: SnackPosition.TOP,
                          backgroundColor: AppColors.info,
                          colorText: Colors.white,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConfig.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              const SizedBox(height: 4),
              
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}