import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../../core/constants/app_config.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  Future<void> initialize() async {
    try {
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
      
      await _createNotificationChannels();
      await _requestPermissions();
      
      debugPrint('Notification service initialized');
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }
  
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel messageChannel = AndroidNotificationChannel(
      'messages',
      'Messages',
      description: 'Notifications for new messages',
      importance: Importance.high,
      sound: RawResourceAndroidNotificationSound('message_tone'),
    );
    
    const AndroidNotificationChannel callChannel = AndroidNotificationChannel(
      'calls',
      'Calls',
      description: 'Notifications for incoming calls',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('ringtone'),
    );
    
    const AndroidNotificationChannel generalChannel = AndroidNotificationChannel(
      'general',
      'General',
      description: 'General notifications',
      importance: Importance.defaultImportance,
    );
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(messageChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(callChannel);
    
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(generalChannel);
  }
  
  Future<void> _requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  void _onNotificationTapped(NotificationResponse response) {
    try {
      final payload = response.payload;
      if (payload != null) {
        _handleNotificationPayload(payload);
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }
  
  void _handleNotificationPayload(String payload) {
    // Parse payload and navigate accordingly
    // Example: {"type": "message", "chatId": "123"}
    try {
      final Map<String, dynamic> data = {};
      payload.split(',').forEach((pair) {
        final parts = pair.split(':');
        if (parts.length == 2) {
          data[parts[0].trim()] = parts[1].trim();
        }
      });
      
      final type = data['type'];
      switch (type) {
        case 'message':
          final chatId = data['chatId'];
          if (chatId != null) {
            Get.toNamed('/chat-detail', arguments: {'chatId': chatId});
          }
          break;
        case 'call':
          // Handle call notification
          break;
        default:
          // Handle other types
          break;
      }
    } catch (e) {
      debugPrint('Error parsing notification payload: $e');
    }
  }
  
  // Show message notification
  Future<void> showMessageNotification({
    required int id,
    required String title,
    required String body,
    required String chatId,
    String? profilePicture,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'messages',
        'Messages',
        channelDescription: 'Notifications for new messages',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        largeIcon: profilePicture != null 
            ? FilePathAndroidBitmap(profilePicture)
            : null,
        styleInformation: const BigTextStyleInformation(''),
        actions: [
          const AndroidNotificationAction(
            'reply',
            'Reply',
            inputs: [AndroidNotificationActionInput(label: 'Reply')],
          ),
          const AndroidNotificationAction('mark_read', 'Mark as read'),
        ],
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'message_tone.aiff',
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: 'type:message,chatId:$chatId',
      );
    } catch (e) {
      debugPrint('Error showing message notification: $e');
    }
  }
  
  // Show call notification
  Future<void> showCallNotification({
    required int id,
    required String callerName,
    required String callId,
    bool isVideo = false,
  }) async {
    try {
      final androidDetails = AndroidNotificationDetails(
        'calls',
        'Calls',
        channelDescription: 'Notifications for incoming calls',
        importance: Importance.max,
        priority: Priority.max,
        category: AndroidNotificationCategory.call,
        fullScreenIntent: true,
        ongoing: true,
        autoCancel: false,
        actions: [
          const AndroidNotificationAction('accept', 'Accept', showsUserInterface: true),
          const AndroidNotificationAction('decline', 'Decline', cancelNotification: true),
        ],
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'ringtone.aiff',
        categoryIdentifier: 'call',
      );
      
      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(
        id,
        'Incoming ${isVideo ? 'Video' : 'Voice'} Call',
        callerName,
        details,
        payload: 'type:call,callId:$callId,isVideo:$isVideo',
      );
    } catch (e) {
      debugPrint('Error showing call notification: $e');
    }
  }
  
  // Show general notification
  Future<void> showGeneralNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'general',
        'General',
        channelDescription: 'General notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      );
      
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      
      await _notifications.show(id, title, body, details, payload: payload);
    } catch (e) {
      debugPrint('Error showing general notification: $e');
    }
  }
  
  // Cancel notification
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      debugPrint('Error canceling notification: $e');
    }
  }
  
  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
    } catch (e) {
      debugPrint('Error canceling all notifications: $e');
    }
  }
  
  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }
  
  // Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.areNotificationsEnabled() ?? false;
      }
      
      final ios = _notifications.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final settings = await ios.checkPermissions();
        return settings?.isEnabled ?? false;
      }
      
      return false;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }
}