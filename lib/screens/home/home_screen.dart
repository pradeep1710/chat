import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/chat_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../routes/app_routes.dart';
import '../chat/chats_tab.dart';
import '../status/status_tab.dart';
import '../calls/calls_tab.dart';
import '../communities/communities_tab.dart';

class HomeScreen extends GetView<AuthController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ChatApp',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: () => Get.toNamed(AppRoutes.search),
              icon: const Icon(Icons.search),
            ),
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'new_group',
                  child: Row(
                    children: [
                      Icon(Icons.group_add, color: AppColors.onSurface),
                      SizedBox(width: 12),
                      Text('New group'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'new_community',
                  child: Row(
                    children: [
                      Icon(Icons.public, color: AppColors.onSurface),
                      SizedBox(width: 12),
                      Text('New community'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'starred_messages',
                  child: Row(
                    children: [
                      Icon(Icons.star, color: AppColors.onSurface),
                      SizedBox(width: 12),
                      Text('Starred messages'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: AppColors.onSurface),
                      SizedBox(width: 12),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 12),
                      Text('Logout', style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(fontWeight: FontWeight.w600),
            tabs: [
              Tab(text: 'Chats'),
              Tab(text: 'Status'),
              Tab(text: 'Calls'),
              Tab(text: 'Communities'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            ChatsTab(),
            StatusTab(),
            CallsTab(),
            CommunitiesTab(),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      return DefaultTabController(
        length: 4,
        child: Builder(
          builder: (context) {
            final tabController = DefaultTabController.of(context);
            return AnimatedBuilder(
              animation: tabController,
              builder: (context, child) {
                final tabIndex = tabController.index;

                switch (tabIndex) {
                  case 0: // Chats
                    return FloatingActionButton(
                      onPressed: () => Get.toNamed(AppRoutes.contactPicker),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.chat, color: Colors.white),
                    );
                  case 1: // Status
                    return FloatingActionButton(
                      onPressed: () => Get.toNamed(AppRoutes.statusCreate),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    );
                  case 2: // Calls
                    return FloatingActionButton(
                      onPressed: () => _showCallOptions(),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.add_call, color: Colors.white),
                    );
                  case 3: // Communities
                    return FloatingActionButton(
                      onPressed: () => Get.toNamed(AppRoutes.communityCreate),
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.add, color: Colors.white),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            );
          },
        ),
      );
    });
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new_group':
        Get.toNamed(AppRoutes.groupCreate);
        break;
      case 'new_community':
        Get.toNamed(AppRoutes.communityCreate);
        break;
      case 'starred_messages':
        Get.toNamed(AppRoutes.starred);
        break;
      case 'settings':
        Get.toNamed(AppRoutes.settings);
        break;
      case 'logout':
        _showLogoutDialog();
        break;
    }
  }

  void _showCallOptions() {
    Get.bottomSheet(
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
              leading: const Icon(Icons.videocam, color: AppColors.primary),
              title: const Text('Video call'),
              onTap: () {
                Get.back();
                // TODO: Implement video call
                Get.snackbar('Coming Soon', 'Video call feature coming soon!');
              },
            ),
            ListTile(
              leading: const Icon(Icons.call, color: AppColors.primary),
              title: const Text('Voice call'),
              onTap: () {
                Get.back();
                // TODO: Implement voice call
                Get.snackbar('Coming Soon', 'Voice call feature coming soon!');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
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
