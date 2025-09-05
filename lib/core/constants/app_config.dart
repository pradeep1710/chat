class AppConfig {
  // API Configuration
  static const String baseUrl = 'http://192.168.1.37:3000/api';
  static const String socketUrl = 'http://192.168.1.37:3000';
  
  // For production, use your actual server URL:
  // static const String baseUrl = 'https://your-server.com/api';
  // static const String socketUrl = 'https://your-server.com';
  
  // App Information
  static const String appName = 'ChatApp';
  static const String appVersion = '1.0.0';
  
  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String settingsKey = 'app_settings';
  static const String chatCacheKey = 'chat_cache';
  
  // File Upload Configuration
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const List<String> allowedVideoTypes = ['mp4', 'avi', 'mov', 'mkv'];
  static const List<String> allowedAudioTypes = ['mp3', 'wav', 'aac', 'm4a'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx', 'ppt', 'pptx'];
  
  // Chat Configuration
  static const int messagesPerPage = 50;
  static const int chatsPerPage = 20;
  static const int statusExpiryHours = 24;
  
  // Socket Events
  static const String socketConnect = 'connect';
  static const String socketDisconnect = 'disconnect';
  static const String socketError = 'error';
  static const String joinChat = 'join_chat';
  static const String leaveChat = 'leave_chat';
  static const String sendMessage = 'send_message';
  static const String newMessage = 'new_message';
  static const String messageDelivered = 'message_delivered';
  static const String messageRead = 'message_read';
  static const String typingStart = 'typing_start';
  static const String typingStop = 'typing_stop';
  static const String userTyping = 'user_typing';
  static const String userStoppedTyping = 'user_stopped_typing';
  static const String userOnlineStatus = 'user_online_status_updated';
  static const String userOffline = 'user_offline';
  
  // Notification Configuration
  static const String notificationChannelId = 'chat_notifications';
  static const String notificationChannelName = 'Chat Notifications';
  static const String notificationChannelDescription = 'Notifications for new messages and updates';
  
  // Theme Configuration
  static const double borderRadius = 12.0;
  static const double messageBorderRadius = 18.0;
  static const double cardElevation = 2.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxRetryAttempts = 3;
  
  // Cache Configuration
  static const Duration cacheExpiry = Duration(hours: 24);
  static const int maxCacheSize = 100; // Number of items to cache
}