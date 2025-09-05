import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../routes/app_routes.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SettingsController());
    final authController = Get.find<AuthController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Section
            _buildProfileSection(authController),
            
            const SizedBox(height: 20),
            
            // Settings Sections
            _buildSettingsSection(
              'Account',
              [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Edit Profile',
                  subtitle: 'Change your name, status, and photo',
                  onTap: () => Get.toNamed(AppRoutes.editProfile),
                ),
                _buildSettingsTile(
                  icon: Icons.qr_code,
                  title: 'QR Code',
                  subtitle: 'Share your QR code with friends',
                  onTap: () => Get.toNamed(AppRoutes.qrCode),
                ),
              ],
            ),
            
            _buildSettingsSection(
              'Privacy',
              [
                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Privacy',
                  subtitle: 'Control who can see your info',
                  onTap: () => Get.toNamed(AppRoutes.privacy),
                ),
                _buildSettingsTile(
                  icon: Icons.security,
                  title: 'Security',
                  subtitle: 'Two-step verification, change number',
                  onTap: () => Get.toNamed(AppRoutes.security),
                ),
                _buildSettingsTile(
                  icon: Icons.block,
                  title: 'Blocked Contacts',
                  subtitle: 'Manage blocked users',
                  onTap: () => Get.toNamed(AppRoutes.blocked),
                ),
              ],
            ),
            
            _buildSettingsSection(
              'Chats',
              [
                _buildSettingsTile(
                  icon: Icons.archive_outlined,
                  title: 'Archived Chats',
                  subtitle: 'View archived conversations',
                  onTap: () => Get.toNamed(AppRoutes.archived),
                ),
                _buildSettingsTile(
                  icon: Icons.star_outline,
                  title: 'Starred Messages',
                  subtitle: 'View your starred messages',
                  onTap: () => Get.toNamed(AppRoutes.starred),
                ),
                _buildSettingsTile(
                  icon: Icons.backup_outlined,
                  title: 'Chat Backup',
                  subtitle: 'Backup and restore your chats',
                  onTap: () => _showComingSoon('Chat Backup'),
                ),
              ],
            ),
            
            _buildSettingsSection(
              'Notifications',
              [
                _buildSettingsTile(
                  icon: Icons.notifications_outline,
                  title: 'Notifications',
                  subtitle: 'Message, group & call tones',
                  onTap: () => Get.toNamed(AppRoutes.notifications),
                ),
              ],
            ),
            
            _buildSettingsSection(
              'Storage and Data',
              [
                _buildSettingsTile(
                  icon: Icons.storage_outlined,
                  title: 'Storage Usage',
                  subtitle: 'Network usage, auto-download',
                  onTap: () => Get.toNamed(AppRoutes.storage),
                ),
              ],
            ),
            
            _buildSettingsSection(
              'Help',
              [
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Help',
                  subtitle: 'FAQ, contact us, privacy policy',
                  onTap: () => Get.toNamed(AppRoutes.help),
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About',
                  subtitle: 'App info and version',
                  onTap: () => Get.toNamed(AppRoutes.about),
                ),
              ],
            ),
            
            // Logout Section
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(authController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(AuthController authController) {
    return Obx(() {
      final user = authController.currentUser;
      if (user == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
        ),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppColors.primary,
                  backgroundImage: user.profilePicture != null
                      ? CachedNetworkImageProvider(user.profilePicture!)
                      : null,
                  child: user.profilePicture == null
                      ? Text(
                          user.username[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.profilePicture),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.phoneNumber,
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              user.status,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSettingsSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.onSurface,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      trailing: trailing ?? const Icon(
        Icons.chevron_right,
        color: AppColors.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }

  void _showComingSoon(String feature) {
    Get.snackbar(
      'Coming Soon',
      '$feature feature will be available soon!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _showLogoutDialog(AuthController authController) {
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
              authController.logout();
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