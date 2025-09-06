import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/chat_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../models/chat_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/empty_state.dart';

class ChatsTab extends GetView<ChatController> {
  const ChatsTab({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ChatController());

    return Scaffold(
      body: Column(
        children: [
          // Archived chats section
          _buildArchivedSection(),
          
          // Chat list
          Expanded(
            child: Obx(() {
              if (controller.isLoading.isTrue && controller.chats.isEmpty) {
                return _buildShimmerLoading();
              }

              if (controller.chats.isEmpty) {
                return const EmptyState(
                  icon: Icons.chat_bubble_outline,
                  title: 'No chats yet',
                  message: 'Start a conversation by tapping the chat button',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshChats,
                color: AppColors.primary,
                child: ListView.builder(
                  itemCount: controller.chats.length + 
                             (controller.hasMore.isTrue ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.chats.length) {
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

                    final chat = controller.chats[index];
                    return _buildChatTile(chat);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildArchivedSection() {
    final authController = Get.find<AuthController>();
    final currentUser = authController.currentUser;
    
    if (currentUser?.archivedChats.isEmpty ?? true) {
      return const SizedBox.shrink();
    }

    return Container(
      color: AppColors.surfaceVariant,
      child: ListTile(
        leading: const Icon(
          Icons.archive,
          color: AppColors.onSurfaceVariant,
        ),
        title: const Text(
          'Archived',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${currentUser!.archivedChats.length}',
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        onTap: () => Get.toNamed(AppRoutes.archived),
      ),
    );
  }

  Widget _buildChatTile(ChatModel chat) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id ?? '';
    
    return Dismissible(
      key: Key(chat.id),
      background: _buildSwipeBackground(isArchive: true),
      secondaryBackground: _buildSwipeBackground(isArchive: false),
      onDismissed: (direction) {
        if (direction == DismissDirection.startToEnd) {
          controller.archiveChat(chat.id);
        } else {
          controller.deleteChat(chat.id);
        }
      },
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: _buildChatAvatar(chat, currentUserId),
        title: _buildChatTitle(chat, currentUserId),
        subtitle: _buildChatSubtitle(chat, currentUserId),
        trailing: _buildChatTrailing(chat, currentUserId),
        onTap: () => _openChat(chat),
        onLongPress: () => _showChatOptions(chat),
      ),
    );
  }

  Widget _buildChatAvatar(ChatModel chat, String currentUserId) {
    final displayPicture = chat.getDisplayPicture(currentUserId);
    final displayName = chat.getDisplayName(currentUserId);
    final isOnline = chat.isOnline();

    return Stack(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary,
          backgroundImage: displayPicture != null 
              ? CachedNetworkImageProvider(displayPicture)
              : null,
          child: displayPicture == null
              ? Text(
                  displayName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                )
              : null,
        ),
        if (chat.type == ChatType.private && isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.onlineStatus,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildChatTitle(ChatModel chat, String currentUserId) {
    final displayName = chat.getDisplayName(currentUserId);
    final unreadCount = chat.getUnreadCountForUser(currentUserId);

    return Row(
      children: [
        Expanded(
          child: Text(
            displayName,
            style: TextStyle(
              fontWeight: unreadCount > 0 
                  ? FontWeight.w600 
                  : FontWeight.w500,
              fontSize: 16,
              color: AppColors.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (chat.isMuted)
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Icon(
              Icons.volume_off,
              size: 16,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildChatSubtitle(ChatModel chat, String currentUserId) {
    final lastMessage = chat.lastMessage;
    final draftMessage = chat.getDraftMessage(currentUserId);
    
    if (draftMessage != null && draftMessage.isNotEmpty) {
      return Text(
        'Draft: $draftMessage',
        style: const TextStyle(
          color: AppColors.error,
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (lastMessage == null) {
      return const Text(
        'No messages yet',
        style: TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
      );
    }

    return _buildLastMessagePreview(lastMessage, currentUserId);
  }

  Widget _buildLastMessagePreview(dynamic lastMessage, String currentUserId) {
    String prefix = '';
    String content = lastMessage.content ?? '';
    
    // Add sender prefix for group chats
    if (lastMessage.sender?.id == currentUserId) {
      prefix = 'You: ';
    } else if (lastMessage.sender?.username != null) {
      prefix = '${lastMessage.sender!.username}: ';
    }

    // Handle different message types
    switch (lastMessage.type?.toString() ?? 'text') {
      case 'image':
        content = '📷 Photo';
        break;
      case 'video':
        content = '🎥 Video';
        break;
      case 'audio':
        content = '🎵 Audio';
        break;
      case 'voice':
        content = '🎤 Voice message';
        break;
      case 'document':
        content = '📄 Document';
        break;
      case 'location':
        content = '📍 Location';
        break;
    }

    return Text(
      '$prefix$content',
      style: TextStyle(
        color: AppColors.onSurfaceVariant,
        fontSize: 14,
        fontWeight: lastMessage.hasUnreadMessages(currentUserId) 
            ? FontWeight.w500 
            : FontWeight.normal,
      ),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildChatTrailing(ChatModel chat, String currentUserId) {
    final unreadCount = chat.getUnreadCountForUser(currentUserId);
    final lastMessageAt = chat.lastMessageAt;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (lastMessageAt != null)
          Text(
            _formatTime(lastMessageAt),
            style: TextStyle(
              color: unreadCount > 0 
                  ? AppColors.primary 
                  : AppColors.onSurfaceVariant,
              fontSize: 12,
              fontWeight: unreadCount > 0 
                  ? FontWeight.w600 
                  : FontWeight.normal,
            ),
          ),
        const SizedBox(height: 4),
        if (unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            constraints: const BoxConstraints(minWidth: 20),
            child: Text(
              unreadCount > 99 ? '99+' : unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildSwipeBackground({required bool isArchive}) {
    return Container(
      color: isArchive ? AppColors.warning : AppColors.error,
      alignment: isArchive 
          ? Alignment.centerLeft 
          : Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(
        isArchive ? Icons.archive : Icons.delete,
        color: Colors.white,
        size: 24,
      ),
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
            leading: CircleAvatar(radius: 28),
            title: SizedBox(
              height: 16,
              width: double.infinity,
            ),
            subtitle: SizedBox(
              height: 14,
              width: double.infinity,
            ),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 12, width: 40),
                SizedBox(height: 4),
                SizedBox(height: 20, width: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  void _openChat(ChatModel chat) {
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: {'chat': chat},
    );
  }

  void _showChatOptions(ChatModel chat) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id ?? '';
    
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
              leading: Icon(
                chat.isMuted ? Icons.volume_up : Icons.volume_off,
                color: AppColors.onSurface,
              ),
              title: Text(chat.isMuted ? 'Unmute' : 'Mute'),
              onTap: () {
                Get.back();
                controller.toggleMuteChat(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.archive, color: AppColors.onSurface),
              title: const Text('Archive'),
              onTap: () {
                Get.back();
                controller.archiveChat(chat.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info, color: AppColors.onSurface),
              title: const Text('Chat info'),
              onTap: () {
                Get.back();
                Get.toNamed(
                  AppRoutes.chatInfo,
                  arguments: {'chat': chat},
                );
              },
            ),
            if (chat.type == ChatType.private)
              ListTile(
                leading: const Icon(Icons.block, color: AppColors.error),
                title: const Text('Block user'),
                onTap: () {
                  Get.back();
                  _showBlockUserDialog(chat, currentUserId);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete chat'),
              onTap: () {
                Get.back();
                _showDeleteChatDialog(chat);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showBlockUserDialog(ChatModel chat, String currentUserId) {
    final otherUser = chat.getOtherUser(currentUserId);
    if (otherUser == null) return;

    Get.dialog(
      AlertDialog(
        title: const Text('Block User'),
        content: Text('Are you sure you want to block ${otherUser.username}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.blockUser(otherUser.id);
            },
            child: const Text(
              'Block',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog(ChatModel chat) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Chat'),
        content: const Text('Are you sure you want to delete this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteChat(chat.id);
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
