import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/themes/app_colors.dart';
import '../../models/message_model.dart';
import '../../controllers/auth_controller.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final MessageModel? previousMessage;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MessageBubble({
    super.key,
    required this.message,
    this.previousMessage,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final currentUserId = authController.currentUser?.id ?? '';
    final isMe = message.sender.id == currentUserId;
    final showAvatar = _shouldShowAvatar(isMe);
    final showTimestamp = _shouldShowTimestamp();

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 64 : 8,
        right: isMe ? 8 : 64,
        top: showTimestamp ? 8 : 2,
        bottom: 2,
      ),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (showTimestamp) _buildTimestamp(),
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isMe && showAvatar) _buildAvatar(),
              if (!isMe && !showAvatar) const SizedBox(width: 32),
              Flexible(
                child: GestureDetector(
                  onTap: onTap,
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isMe 
                          ? AppColors.chatBubbleOutgoing 
                          : AppColors.chatBubbleIncoming,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isMe && message.type != MessageType.text)
                          _buildSenderName(),
                        _buildMessageContent(),
                        const SizedBox(height: 2),
                        _buildMessageFooter(isMe),
                      ],
                    ),
                  ),
                ),
              ),
              if (isMe && showAvatar) _buildAvatar(),
              if (isMe && !showAvatar) const SizedBox(width: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black12,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatTimestamp(message.createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      margin: const EdgeInsets.only(left: 4, right: 4, bottom: 4),
      child: CircleAvatar(
        radius: 12,
        backgroundColor: AppColors.primary,
        backgroundImage: message.sender.profilePicture != null
            ? CachedNetworkImageProvider(message.sender.profilePicture!)
            : null,
        child: message.sender.profilePicture == null
            ? Text(
                message.sender.username[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildSenderName() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        message.sender.username,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return _buildTextMessage();
      case MessageType.image:
        return _buildImageMessage();
      case MessageType.video:
        return _buildVideoMessage();
      case MessageType.audio:
        return _buildAudioMessage();
      case MessageType.voice:
        return _buildVoiceMessage();
      case MessageType.document:
        return _buildDocumentMessage();
      case MessageType.location:
        return _buildLocationMessage();
      case MessageType.contact:
        return _buildContactMessage();
      default:
        return _buildTextMessage();
    }
  }

  Widget _buildTextMessage() {
    return Text(
      message.content,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (message.media?.url != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: message.media!.url!,
              width: 200,
              height: 200,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 200,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
          ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVideoMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (message.media?.thumbnail != null)
                CachedNetworkImage(
                  imageUrl: message.media!.thumbnail!,
                  width: 200,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
        ),
        if (message.content.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            message.content,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurface,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAudioMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.audiotrack,
          color: AppColors.audioColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.media?.filename ?? 'Audio',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (message.media?.duration != null)
              Text(
                _formatDuration(message.media!.duration!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildVoiceMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.mic,
          color: AppColors.voiceColor,
          size: 20,
        ),
        const SizedBox(width: 8),
        Container(
          width: 100,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.voiceColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text(
              'Voice message',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.voiceColor,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        if (message.media?.duration != null)
          Text(
            _formatDuration(message.media!.duration!),
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }

  Widget _buildDocumentMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.insert_drive_file,
          color: AppColors.documentColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.media?.filename ?? 'Document',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (message.media?.size != null)
              Text(
                _formatFileSize(message.media!.size!),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_on,
          color: AppColors.locationColor,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContactMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.person,
          color: AppColors.primary,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text(
          'Contact',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageFooter(bool isMe) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited)
          const Text(
            'edited • ',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        Text(
          _formatTime(message.createdAt),
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (isMe) ...[
          const SizedBox(width: 4),
          _buildMessageStatusIcon(),
        ],
      ],
    );
  }

  Widget _buildMessageStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return const SizedBox(
          width: 12,
          height: 12,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.onSurfaceVariant),
          ),
        );
      case MessageStatus.sent:
        return const Icon(
          Icons.check,
          size: 16,
          color: AppColors.messageSent,
        );
      case MessageStatus.delivered:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: AppColors.messageDelivered,
        );
      case MessageStatus.read:
        return const Icon(
          Icons.done_all,
          size: 16,
          color: AppColors.messageRead,
        );
      case MessageStatus.failed:
        return const Icon(
          Icons.error_outline,
          size: 16,
          color: AppColors.messageFailed,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  bool _shouldShowAvatar(bool isMe) {
    if (previousMessage == null) return true;
    
    // Show avatar if sender changed or if there's a time gap
    return previousMessage!.sender.id != message.sender.id ||
           message.createdAt.difference(previousMessage!.createdAt).inMinutes > 5;
  }

  bool _shouldShowTimestamp() {
    if (previousMessage == null) return true;
    
    // Show timestamp if there's more than 1 hour gap
    return message.createdAt.difference(previousMessage!.createdAt).inHours >= 1;
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else if (now.difference(dateTime).inDays < 7) {
      const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[dateTime.weekday - 1];
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}