import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/calls_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/empty_state.dart';

class CallsTab extends GetView<CallsController> {
  const CallsTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not already done
    if (!Get.isRegistered<CallsController>()) {
      Get.put(CallsController());
    }

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading&& controller.calls.isEmpty) {
          return _buildShimmerLoading();
        }

        if (controller.calls.isEmpty) {
          return const EmptyState(
            icon: Icons.call_outlined,
            title: 'No calls yet',
            message: 'Start a voice or video call by tapping the call button',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshCalls,
          color: AppColors.primary,
          child: ListView.builder(
            itemCount: controller.calls.length + 
                       (controller.hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.calls.length) {
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

              final call = controller.calls[index];
              return _buildCallTile(call);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCallTile(dynamic call) {
    final isVideoCall = call.type == 'video';
    final isIncoming = call.direction == 'incoming';
    final isMissed = call.status == 'missed';
    final isAnswered = call.status == 'answered';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.surfaceVariant,
            backgroundImage: call.user?.profilePicture != null
                ? CachedNetworkImageProvider(call.user!.profilePicture!)
                : null,
            child: call.user?.profilePicture == null
                ? Text(
                    call.user?.username[0].toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  )
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: isVideoCall ? AppColors.videoColor : AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Icon(
                isVideoCall ? Icons.videocam : Icons.call,
                color: Colors.white,
                size: 10,
              ),
            ),
          ),
        ],
      ),
      title: Text(
        call.user?.username ?? 'Unknown',
        style: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
          color: isMissed ? AppColors.error : AppColors.onSurface,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(
            _getCallIcon(call),
            size: 16,
            color: _getCallIconColor(call),
          ),
          const SizedBox(width: 4),
          Text(
            _getCallSubtitle(call),
            style: TextStyle(
              color: isMissed ? AppColors.error : AppColors.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: () => _makeCall(call.user, isVideoCall),
        icon: Icon(
          isVideoCall ? Icons.videocam : Icons.call,
          color: AppColors.primary,
        ),
      ),
      onTap: () => _showCallDetails(call),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const ShimmerLoading(
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            leading: CircleAvatar(radius: 26),
            title: SizedBox(height: 16, width: 120),
            subtitle: SizedBox(height: 14, width: 80),
            trailing: Icon(Icons.call),
          ),
        );
      },
    );
  }

  IconData _getCallIcon(dynamic call) {
    final isIncoming = call.direction == 'incoming';
    final isMissed = call.status == 'missed';

    if (isMissed) {
      return isIncoming ? Icons.call_received : Icons.call_made;
    } else {
      return isIncoming ? Icons.call_received : Icons.call_made;
    }
  }

  Color _getCallIconColor(dynamic call) {
    final isMissed = call.status == 'missed';
    
    if (isMissed) {
      return AppColors.error;
    } else {
      return AppColors.primary;
    }
  }

  String _getCallSubtitle(dynamic call) {
    final isIncoming = call.direction == 'incoming';
    final isMissed = call.status == 'missed';
    final duration = call.duration ?? 0;
    final callTime = timeago.format(call.createdAt ?? DateTime.now());

    String prefix = '';
    if (isMissed) {
      prefix = 'Missed • ';
    } else if (isIncoming) {
      prefix = 'Incoming • ';
    } else {
      prefix = 'Outgoing • ';
    }

    if (duration > 0) {
      final durationText = _formatDuration(duration);
      return '$prefix$durationText • $callTime';
    } else {
      return '$prefix$callTime';
    }
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      final remainingSeconds = seconds % 60;
      return '${hours}:${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    }
  }

  void _makeCall(dynamic user, bool isVideo) {
    // TODO: Implement actual calling functionality
    Get.snackbar(
      'Coming Soon',
      'Calling feature will be available soon!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _showCallDetails(dynamic call) {
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.surfaceVariant,
                    backgroundImage: call.user?.profilePicture != null
                        ? CachedNetworkImageProvider(call.user!.profilePicture!)
                        : null,
                    child: call.user?.profilePicture == null
                        ? Text(
                            call.user?.username[0].toUpperCase() ?? 'U',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    call.user?.username ?? 'Unknown',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCallSubtitle(call),
                    style: const TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'voice_call',
                  onPressed: () {
                    Get.back();
                    _makeCall(call.user, false);
                  },
                  backgroundColor: AppColors.primary,
                  child: const Icon(Icons.call, color: Colors.white),
                ),
                FloatingActionButton(
                  heroTag: 'video_call',
                  onPressed: () {
                    Get.back();
                    _makeCall(call.user, true);
                  },
                  backgroundColor: AppColors.videoColor,
                  child: const Icon(Icons.videocam, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}