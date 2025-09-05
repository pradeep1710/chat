import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/community_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/empty_state.dart';

class CommunitiesTab extends GetView<CommunityController> {
  const CommunitiesTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<CommunityController>()) {
      Get.put(CommunityController());
    }

    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search communities...',
                prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
                filled: true,
                fillColor: AppColors.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              onChanged: controller.searchCommunities,
            ),
          ),
          
          // Communities list
          Expanded(
            child: Obx(() {
              if (controller.isLoading && controller.communities.isEmpty) {
                return _buildShimmerLoading();
              }

              if (controller.communities.isEmpty) {
                return const EmptyState(
                  icon: Icons.public_outlined,
                  title: 'No communities found',
                  message: 'Create or discover communities to connect with people who share your interests',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshCommunities,
                color: AppColors.primary,
                child: ListView.builder(
                  itemCount: controller.communities.length + 
                             (controller.hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.communities.length) {
                      // Loading indicator for pagination
                      return const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    final community = controller.communities[index];
                    return _buildCommunityTile(community);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityTile(dynamic community) {
    final isMember = community.isMember ?? false;
    final memberCount = community.memberCount ?? 0;
    final isPublic = community.isPublic ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.surfaceVariant,
              backgroundImage: community.profilePicture != null
                  ? CachedNetworkImageProvider(community.profilePicture!)
                  : null,
              child: community.profilePicture == null
                  ? Icon(
                      Icons.public,
                      size: 28,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            if (!isPublic)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 10,
                  ),
                ),
              ),
          ],
        ),
        title: Text(
          community.name ?? 'Unknown Community',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (community.description != null && community.description!.isNotEmpty)
              Text(
                community.description!,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '$memberCount ${memberCount == 1 ? 'member' : 'members'}',
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
                if (community.tags != null && community.tags!.isNotEmpty) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.local_offer,
                    size: 16,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      community.tags!.take(2).join(', '),
                      style: const TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        trailing: _buildCommunityAction(community),
        onTap: () => _openCommunity(community),
        onLongPress: () => _showCommunityOptions(community),
      ),
    );
  }

  Widget _buildCommunityAction(dynamic community) {
    final isMember = community.isMember ?? false;
    
    if (isMember) {
      return const Icon(
        Icons.check_circle,
        color: AppColors.primary,
      );
    } else {
      return OutlinedButton(
        onPressed: () => controller.joinCommunity(community.id),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primary),
          foregroundColor: AppColors.primary,
        ),
        child: const Text('Join'),
      );
    }
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: const ShimmerLoading(
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: CircleAvatar(radius: 28),
              title: SizedBox(height: 16, width: double.infinity),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 14, width: double.infinity),
                  SizedBox(height: 4),
                  SizedBox(height: 12, width: 100),
                ],
              ),
              trailing: SizedBox(height: 32, width: 60),
            ),
          ),
        );
      },
    );
  }

  void _openCommunity(dynamic community) {
    Get.toNamed(
      AppRoutes.communityDetail,
      arguments: {'community': community},
    );
  }

  void _showCommunityOptions(dynamic community) {
    final isMember = community.isMember ?? false;
    
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
              leading: const Icon(Icons.info, color: AppColors.onSurface),
              title: const Text('Community info'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.communityInfo,
                  arguments: {'community': community},
                );
              },
            ),
            if (isMember) ...[
              ListTile(
                leading: const Icon(Icons.volume_off, color: AppColors.onSurface),
                title: const Text('Mute community'),
                onTap: () {
                  Get.back();
                  controller.muteCommunity(community.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: AppColors.error),
                title: const Text('Leave community'),
                onTap: () {
                  Get.back();
                  _showLeaveCommunityDialog(community);
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.group_add, color: AppColors.primary),
                title: const Text('Join community'),
                onTap: () {
                  Get.back();
                  controller.joinCommunity(community.id);
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.share, color: AppColors.onSurface),
              title: const Text('Share community'),
              onTap: () {
                Get.back();
                // TODO: Implement share functionality
                Get.snackbar('Coming Soon', 'Share feature coming soon!');
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLeaveCommunityDialog(dynamic community) {
    Get.dialog(
      AlertDialog(
        title: const Text('Leave Community'),
        content: Text('Are you sure you want to leave ${community.name}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.leaveCommunity(community.id);
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}