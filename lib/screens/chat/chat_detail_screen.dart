import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../controllers/chat_detail_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/message_model.dart';
import '../../routes/app_routes.dart';
import '../../widgets/chat/message_bubble.dart';
import '../../widgets/chat/typing_indicator.dart';
import '../../widgets/common/shimmer_loading.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatModel chat = Get.arguments['chat'];
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id ?? '';
    
    // Initialize controller with chat data
    Get.put(ChatDetailController(chat: chat));

    return Scaffold(
      appBar: _buildAppBar(chat, currentUserId),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() => _buildMessagesList()),
          ),
          
          // Typing indicator
          Obx(() => _buildTypingIndicator()),
          
          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(ChatModel chat, String currentUserId) {
    final displayName = chat.getDisplayName(currentUserId);
    final displayPicture = chat.getDisplayPicture(currentUserId);
    final otherUser = chat.getOtherUser(currentUserId);

    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 1,
      titleSpacing: 0,
      title: InkWell(
        onTap: () => Get.toNamed(
          AppRoutes.chatInfo,
          arguments: {'chat': chat},
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white,
              backgroundImage: displayPicture != null
                  ? CachedNetworkImageProvider(displayPicture)
                  : null,
              child: displayPicture == null
                  ? Text(
                      displayName[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
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
                    displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (chat.type == ChatType.private && otherUser != null)
                    Text(
                      _getOnlineStatus(otherUser),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _makeCall(false),
          icon: const Icon(Icons.call),
        ),
        IconButton(
          onPressed: () => _makeCall(true),
          icon: const Icon(Icons.videocam),
        ),
        PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, chat),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view_contact',
              child: Text('View contact'),
            ),
            const PopupMenuItem(
              value: 'media',
              child: Text('Media, links, and docs'),
            ),
            const PopupMenuItem(
              value: 'search',
              child: Text('Search'),
            ),
            PopupMenuItem(
              value: chat.isMuted ? 'unmute' : 'mute',
              child: Text(chat.isMuted ? 'Unmute notifications' : 'Mute notifications'),
            ),
            const PopupMenuItem(
              value: 'more',
              child: Text('More'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    if (controller.isLoading.value && controller.messages.isEmpty) {
      return _buildShimmerLoading();
    }

    if (controller.messages.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.onSurfaceVariant,
            ),
            SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Send a message to start the conversation',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF0F0F0),
      ),
      child: ListView.builder(
        reverse: true,
        controller: controller.scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.messages.length + 
                   (controller.hasMore.value ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == controller.messages.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            );
          }

          final message = controller.messages[controller.messages.length - 1 - index];
          final previousMessage = index < controller.messages.length - 1
              ? controller.messages[controller.messages.length - index]
              : null;
          
          return MessageBubble(
            message: message,
            previousMessage: previousMessage,
            onTap: () => _handleMessageTap(message),
            onLongPress: () => _handleMessageLongPress(message),
          );
        },
      ),
    );
  }

  Widget _buildTypingIndicator() {
    if (controller.typingUsers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const TypingIndicator(),
          const SizedBox(width: 8),
          Text(
            _getTypingText(),
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _showEmojiPicker(),
                    icon: const Icon(
                      Icons.emoji_emotions_outlined,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: controller.messageController,
                      focusNode: controller.messageFocusNode,
                      maxLines: 5,
                      minLines: 1,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                      onChanged: controller.onMessageChanged,
                      onSubmitted: (_) => controller.sendMessage(),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _showAttachmentOptions(),
                    icon: const Icon(
                      Icons.attach_file,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  Obx(() => controller.messageText.value.trim().isEmpty
                      ? IconButton(
                          onPressed: () => _openCamera(),
                          icon: const Icon(
                            Icons.camera_alt,
                            color: AppColors.onSurfaceVariant,
                          ),
                        )
                      : const SizedBox.shrink()),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() => FloatingActionButton(
            mini: true,
            onPressed: controller.messageText.value.trim().isEmpty
                ? () => _recordVoiceMessage()
                : controller.sendMessage,
            backgroundColor: AppColors.primary,
            child: Icon(
              controller.messageText.value.trim().isEmpty
                  ? Icons.mic
                  : Icons.send,
              color: Colors.white,
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) const CircleAvatar(radius: 16),
              if (!isMe) const SizedBox(width: 8),
              ShimmerLoading(
                child: Container(
                  width: 200,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              if (isMe) const SizedBox(width: 8),
              if (isMe) const CircleAvatar(radius: 16),
            ],
          ),
        );
      },
    );
  }

  String _getOnlineStatus(dynamic user) {
    if (user.isOnline == true) {
      return 'online';
    } else if (user.lastSeen != null) {
      final lastSeen = DateTime.parse(user.lastSeen.toString());
      return 'last seen ${timeago.format(lastSeen)}';
    } else {
      return 'offline';
    }
  }

  String _getTypingText() {
    if (controller.typingUsers.length == 1) {
      return '${controller.typingUsers.first} is typing...';
    } else {
      return '${controller.typingUsers.length} people are typing...';
    }
  }

  void _makeCall(bool isVideo) {
    Get.snackbar(
      'Coming Soon',
      '${isVideo ? 'Video' : 'Voice'} calling feature coming soon!',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _handleMenuAction(String action, ChatModel chat) {
    switch (action) {
      case 'view_contact':
        Get.toNamed(AppRoutes.profile, arguments: {'userId': chat.participants.first.id});
        break;
      case 'media':
        Get.snackbar('Coming Soon', 'Media gallery coming soon!');
        break;
      case 'search':
        Get.snackbar('Coming Soon', 'Search in chat coming soon!');
        break;
      case 'mute':
      case 'unmute':
        controller.toggleMute();
        break;
      case 'more':
        _showMoreOptions(chat);
        break;
    }
  }

  void _showMoreOptions(ChatModel chat) {
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
              leading: const Icon(Icons.clear_all, color: AppColors.error),
              title: const Text('Clear chat'),
              onTap: () {
                Get.back();
                _showClearChatDialog();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppColors.error),
              title: const Text('Delete chat'),
              onTap: () {
                Get.back();
                _showDeleteChatDialog();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear Chat'),
        content: const Text('Are you sure you want to clear this chat? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.clearChat();
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteChatDialog() {
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
              controller.deleteChat();
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

  void _handleMessageTap(MessageModel message) {
    if (message.media != null) {
      Get.toNamed(
        AppRoutes.mediaViewer,
        arguments: {'message': message},
      );
    }
  }

  void _handleMessageLongPress(MessageModel message) {
    HapticFeedback.lightImpact();
    _showMessageOptions(message);
  }

  void _showMessageOptions(MessageModel message) {
    final authController = Get.find<AuthController>();
    final isMyMessage = message.sender.id == authController.currentUser?.id;

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
              leading: const Icon(Icons.reply, color: AppColors.onSurface),
              title: const Text('Reply'),
              onTap: () {
                Get.back();
                controller.replyToMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppColors.onSurface),
              title: const Text('Copy'),
              onTap: () {
                Get.back();
                Clipboard.setData(ClipboardData(text: message.content));
                Get.snackbar('Copied', 'Message copied to clipboard');
              },
            ),
            if (isMyMessage)
              ListTile(
                leading: const Icon(Icons.delete, color: AppColors.error),
                title: const Text('Delete'),
                onTap: () {
                  Get.back();
                  _showDeleteMessageDialog(message);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showDeleteMessageDialog(MessageModel message) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteMessage(message.id);
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

  void _showEmojiPicker() {
    Get.snackbar('Coming Soon', 'Emoji picker coming soon!');
  }

  void _showAttachmentOptions() {
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
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 3,
              padding: const EdgeInsets.all(16),
              children: [
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file,
                  label: 'Document',
                  color: AppColors.documentColor,
                  onTap: () {
                    Get.back();
                    controller.pickDocument();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: AppColors.imageColor,
                  onTap: () {
                    Get.back();
                    controller.pickFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo,
                  label: 'Gallery',
                  color: AppColors.imageColor,
                  onTap: () {
                    Get.back();
                    controller.pickFromGallery();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _openCamera() {
    controller.pickFromCamera();
  }

  void _recordVoiceMessage() {
    Get.snackbar('Coming Soon', 'Voice message feature coming soon!');
  }
}