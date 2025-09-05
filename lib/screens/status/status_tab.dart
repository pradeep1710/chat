import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/status_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/empty_state.dart';

class StatusTab extends GetView<StatusController> {
  const StatusTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<StatusController>()) {
      Get.put(StatusController());
    }

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading && controller.statuses.isEmpty) {
          return _buildShimmerLoading();
        }

        return RefreshIndicator(
          onRefresh: controller.refreshStatuses,
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              // My Status Section
              SliverToBoxAdapter(
                child: _buildMyStatusSection(),
              ),
              
              // Recent Updates Section
              if (controller.statuses.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Recent updates',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              
              // Status List
              controller.statuses.isEmpty
                  ? const SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.auto_stories_outlined,
                        title: 'No status updates',
                        message: 'Share your first status to let others know what\'s on your mind',
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == controller.statuses.length) {
                            return controller.hasMore
                                ? const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink();
                          }

                          final status = controller.statuses[index];
                          return _buildStatusTile(status);
                        },
                        childCount: controller.statuses.length + 
                                   (controller.hasMore ? 1 : 0),
                      ),
                    ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMyStatusSection() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser;

    return Container(
      color: AppColors.surfaceVariant.withOpacity(0.3),
      child: Obx(() {
        final myStatuses = controller.myStatuses;
        final hasStatus = myStatuses.isNotEmpty;

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.primary,
                backgroundImage: currentUser?.profilePicture != null
                    ? CachedNetworkImageProvider(currentUser!.profilePicture!)
                    : null,
                child: currentUser?.profilePicture == null
                    ? Text(
                        currentUser?.username[0].toUpperCase() ?? 'U',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
              if (hasStatus)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                )
              else
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            hasStatus ? 'My status' : 'My status',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            hasStatus
                ? 'Tap to view or add to status'
                : 'Tap to add status update',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
          onTap: () {
            if (hasStatus) {
              Get.toNamed(
                AppRoutes.statusViewer,
                arguments: {'statuses': myStatuses, 'initialIndex': 0},
              );
            } else {
              Get.toNamed(AppRoutes.statusCreate);
            }
          },
        );
      }),
    );
  }

  Widget _buildStatusTile(dynamic status) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Stack(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: status.user?.profilePicture != null
                  ? CachedNetworkImageProvider(status.user!.profilePicture!)
                  : null,
              child: status.user?.profilePicture == null
                  ? Text(
                      status.user?.username[0].toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                    )
                  : null,
            ),
          ),
          if (status.type == 'image' || status.type == 'video')
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: status.type == 'video' 
                      ? AppColors.videoColor 
                      : AppColors.imageColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                ),
                child: Icon(
                  status.type == 'video' ? Icons.videocam : Icons.camera_alt,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        status.user?.username ?? 'Unknown',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        timeago.format(status.createdAt ?? DateTime.now()),
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
      ),
      onTap: () => _viewStatus(status),
      onLongPress: () => _showStatusOptions(status),
    );
  }

  Widget _buildShimmerLoading() {
    return Column(
      children: [
        // My status shimmer
        Container(
          color: AppColors.surfaceVariant.withOpacity(0.3),
          child: const ShimmerLoading(
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(radius: 28),
              title: SizedBox(height: 16, width: 100),
              subtitle: SizedBox(height: 14, width: 150),
            ),
          ),
        ),
        
        // Status list shimmer
        Expanded(
          child: ListView.builder(
            itemCount: 8,
            itemBuilder: (context, index) {
              return const ShimmerLoading(
                child: ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(radius: 28),
                  title: SizedBox(height: 16, width: 120),
                  subtitle: SizedBox(height: 14, width: 80),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _viewStatus(dynamic status) {
    Get.toNamed(
      AppRoutes.statusViewer,
      arguments: {
        'statuses': [status],
        'initialIndex': 0,
      },
    );
  }

  void _showStatusOptions(dynamic status) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id ?? '';
    final isMyStatus = status.user?.id == currentUserId;

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
              leading: const Icon(Icons.visibility, color: AppColors.onSurface),
              title: const Text('View status'),
              onTap: () {
                Get.back();
                _viewStatus(status);
              },
            ),
            if (isMyStatus) ...[
              ListTile(
                leading: const Icon(Icons.people, color: AppColors.onSurface),
                title: const Text('Status info'),
                onTap: () {
                  Get.back();
                  // TODO: Show status viewers
                  Get.snackbar('Coming Soon', 'Status info feature coming soon!');
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete status'),
                onTap: () {
                  Get.back();
                  _showDeleteStatusDialog(status);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteStatusDialog(dynamic status) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Status'),
        content: const Text('Are you sure you want to delete this status?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteStatus(status.id);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}