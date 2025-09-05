import 'package:flutter/material.dart' hide SearchController;
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../controllers/search_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/shimmer_loading.dart';
import '../../widgets/common/empty_state.dart';

class SearchScreen extends GetView<SearchController> {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    Get.put(SearchController());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: TextField(
          controller: controller.searchController,
          focusNode: controller.searchFocusNode,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search chats, messages, users...',
            hintStyle: TextStyle(color: Colors.white70),
            border: InputBorder.none,
          ),
          style: const TextStyle(color: Colors.white, fontSize: 16),
          onChanged: controller.onSearchChanged,
          onSubmitted: controller.performSearch,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            color: AppColors.primary,
            child: TabBar(
              controller: controller.tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Chats'),
                Tab(text: 'Messages'),
                Tab(text: 'Users'),
                Tab(text: 'Communities'),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Recent searches or suggestions
          Obx(() => controller.searchQuery.isEmpty
              ? _buildRecentSearches()
              : const SizedBox.shrink()),
          
          // Search results
          Expanded(
            child: Obx(() => _buildSearchResults()),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches() {
    if (controller.recentSearches.isEmpty) {
      return const Expanded(
        child: EmptyState(
          icon: Icons.search,
          title: 'Search ChatApp',
          message: 'Find chats, messages, users, and communities',
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent searches',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              TextButton(
                onPressed: controller.clearRecentSearches,
                child: const Text(
                  'Clear all',
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.recentSearches.length,
          itemBuilder: (context, index) {
            final search = controller.recentSearches[index];
            return ListTile(
              leading: const Icon(
                Icons.history,
                color: AppColors.onSurfaceVariant,
              ),
              title: Text(search),
              trailing: IconButton(
                onPressed: () => controller.removeRecentSearch(search),
                icon: const Icon(
                  Icons.close,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              onTap: () => controller.performSearch(search),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    if (controller.searchQuery.isEmpty) {
      return const SizedBox.shrink();
    }

    if (controller.isLoading) {
      return _buildShimmerLoading();
    }

    return TabBarView(
      controller: controller.tabController,
      children: [
        _buildAllResults(),
        _buildChatResults(),
        _buildMessageResults(),
        _buildUserResults(),
        _buildCommunityResults(),
      ],
    );
  }

  Widget _buildAllResults() {
    final hasResults = controller.allResults.isNotEmpty;
    
    if (!hasResults) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No results found',
        message: 'Try searching with different keywords',
      );
    }

    return ListView.builder(
      itemCount: controller.allResults.length,
      itemBuilder: (context, index) {
        final result = controller.allResults[index];
        return _buildResultTile(result);
      },
    );
  }

  Widget _buildChatResults() {
    final results = controller.chatResults;
    
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.chat_outlined,
        title: 'No chats found',
        message: 'No chats match your search',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final chat = results[index];
        return _buildChatTile(chat);
      },
    );
  }

  Widget _buildMessageResults() {
    final results = controller.messageResults;
    
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.message_outlined,
        title: 'No messages found',
        message: 'No messages match your search',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final message = results[index];
        return _buildMessageTile(message);
      },
    );
  }

  Widget _buildUserResults() {
    final results = controller.userResults;
    
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.person_outlined,
        title: 'No users found',
        message: 'No users match your search',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final user = results[index];
        return _buildUserTile(user);
      },
    );
  }

  Widget _buildCommunityResults() {
    final results = controller.communityResults;
    
    if (results.isEmpty) {
      return const EmptyState(
        icon: Icons.public_outlined,
        title: 'No communities found',
        message: 'No communities match your search',
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final community = results[index];
        return _buildCommunityTile(community);
      },
    );
  }

  Widget _buildResultTile(dynamic result) {
    switch (result['type']) {
      case 'chat':
        return _buildChatTile(result);
      case 'message':
        return _buildMessageTile(result);
      case 'user':
        return _buildUserTile(result);
      case 'community':
        return _buildCommunityTile(result);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildChatTile(dynamic chat) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.primary,
        backgroundImage: chat['profilePicture'] != null
            ? CachedNetworkImageProvider(chat['profilePicture'])
            : null,
        child: chat['profilePicture'] == null
            ? Text(
                (chat['name'] ?? 'C')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      title: Text(
        chat['name'] ?? 'Unknown Chat',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        chat['lastMessage'] ?? 'No messages',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: chat['unreadCount'] != null && chat['unreadCount'] > 0
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 20),
              child: Text(
                chat['unreadCount'].toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : null,
      onTap: () => _openChat(chat),
    );
  }

  Widget _buildMessageTile(dynamic message) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: AppColors.primary,
        backgroundImage: message['sender']?['profilePicture'] != null
            ? CachedNetworkImageProvider(message['sender']['profilePicture'])
            : null,
        child: message['sender']?['profilePicture'] == null
            ? Text(
                (message['sender']?['username'] ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            : null,
      ),
      title: Text(
        message['sender']?['username'] ?? 'Unknown User',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message['content'] ?? '',
            style: const TextStyle(
              color: AppColors.onSurface,
              fontSize: 16,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            'in ${message['chatName'] ?? 'Unknown Chat'}',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Text(
        _formatMessageTime(message['createdAt']),
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
      onTap: () => _openMessage(message),
    );
  }

  Widget _buildUserTile(dynamic user) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.primary,
            backgroundImage: user['profilePicture'] != null
                ? CachedNetworkImageProvider(user['profilePicture'])
                : null,
            child: user['profilePicture'] == null
                ? Text(
                    (user['username'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          if (user['isOnline'] == true)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.onlineStatus,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        user['username'] ?? 'Unknown User',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        user['status'] ?? 'No status',
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        onPressed: () => _startChat(user),
        icon: const Icon(
          Icons.chat_bubble_outline,
          color: AppColors.primary,
        ),
      ),
      onTap: () => _viewUserProfile(user),
    );
  }

  Widget _buildCommunityTile(dynamic community) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.surfaceVariant,
        backgroundImage: community['profilePicture'] != null
            ? CachedNetworkImageProvider(community['profilePicture'])
            : null,
        child: community['profilePicture'] == null
            ? const Icon(
                Icons.public,
                size: 24,
                color: AppColors.primary,
              )
            : null,
      ),
      title: Text(
        community['name'] ?? 'Unknown Community',
        style: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (community['description'] != null && community['description'].isNotEmpty)
            Text(
              community['description'],
              style: const TextStyle(
                color: AppColors.onSurfaceVariant,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 2),
          Text(
            '${community['memberCount'] ?? 0} members',
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: community['isMember'] == true
          ? const Icon(
              Icons.check_circle,
              color: AppColors.primary,
            )
          : OutlinedButton(
              onPressed: () => _joinCommunity(community),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                foregroundColor: AppColors.primary,
              ),
              child: const Text('Join'),
            ),
      onTap: () => _openCommunity(community),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 10,
      itemBuilder: (context, index) {
        return const ShimmerLoading(
          child: ListTile(
            leading: CircleAvatar(radius: 24),
            title: SizedBox(height: 16, width: double.infinity),
            subtitle: SizedBox(height: 14, width: double.infinity),
          ),
        );
      },
    );
  }

  String _formatMessageTime(dynamic timestamp) {
    if (timestamp == null) return '';
    
    final dateTime = DateTime.parse(timestamp.toString());
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else {
      return '${difference.inDays}d';
    }
  }

  void _openChat(dynamic chat) {
    Get.back();
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: {'chat': chat},
    );
  }

  void _openMessage(dynamic message) {
    Get.back();
    Get.toNamed(
      AppRoutes.chatDetail,
      arguments: {
        'chat': {'id': message['chatId']},
        'messageId': message['id'],
      },
    );
  }

  void _viewUserProfile(dynamic user) {
    Get.toNamed(
      AppRoutes.profile,
      arguments: {'userId': user['id']},
    );
  }

  void _startChat(dynamic user) {
    Get.back();
    // TODO: Create private chat and navigate to it
    Get.snackbar('Coming Soon', 'Starting chat feature coming soon!');
  }

  void _openCommunity(dynamic community) {
    Get.toNamed(
      AppRoutes.communityDetail,
      arguments: {'community': community},
    );
  }

  void _joinCommunity(dynamic community) {
    // TODO: Join community
    Get.snackbar('Coming Soon', 'Join community feature coming soon!');
  }
}