import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF25D366); // WhatsApp green
  static const Color primaryContainer = Color(0xFFE8F5E8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onPrimaryContainer = Color(0xFF1B5E20);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF128C7E);
  static const Color secondaryContainer = Color(0xFFE0F2F1);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color onSecondaryContainer = Color(0xFF004D40);
  
  // Surface Colors (Light Theme)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color onSurfaceVariant = Color(0xFF8E8E93);
  static const Color surfaceTint = Color(0xFF25D366);
  
  // Surface Colors (Dark Theme)
  static const Color darkSurface = Color(0xFF0B141B);
  static const Color darkSurfaceVariant = Color(0xFF1F2C34);
  static const Color darkOnSurface = Color(0xFFE1E1E1);
  static const Color darkOnSurfaceVariant = Color(0xFF8696A0);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color onBackground = Color(0xFF1C1C1E);
  static const Color darkBackground = Color(0xFF0B141B);
  static const Color darkOnBackground = Color(0xFFE1E1E1);
  
  // Error Colors
  static const Color error = Color(0xFFDC3545);
  static const Color errorContainer = Color(0xFFFFEDED);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color onErrorContainer = Color(0xFF5F2120);
  
  // Warning Colors
  static const Color warning = Color(0xFFFFC107);
  static const Color warningContainer = Color(0xFFFFF8E1);
  static const Color onWarning = Color(0xFF000000);
  static const Color onWarningContainer = Color(0xFF663C00);
  
  // Success Colors
  static const Color success = Color(0xFF28A745);
  static const Color successContainer = Color(0xFFE8F5E8);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color onSuccessContainer = Color(0xFF1B5E20);
  
  // Info Colors
  static const Color info = Color(0xFF17A2B8);
  static const Color infoContainer = Color(0xFFE1F5FE);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color onInfoContainer = Color(0xFF01579B);
  
  // Outline Colors
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineVariant = Color(0xFFF5F5F5);
  static const Color darkOutline = Color(0xFF3C4043);
  static const Color darkOutlineVariant = Color(0xFF1F2C34);
  
  // Inverse Colors
  static const Color inverseSurface = Color(0xFF2D2D2D);
  static const Color inverseOnSurface = Color(0xFFFFFFFF);
  static const Color inversePrimary = Color(0xFF90CAF9);
  
  // Shadow Colors
  static const Color shadow = Color(0x1F000000);
  static const Color scrim = Color(0x66000000);
  
  // Chat-specific Colors
  static const Color chatBubbleOutgoing = Color(0xFFDCF8C6); // Light green
  static const Color chatBubbleIncoming = Color(0xFFFFFFFF); // White
  static const Color chatBubbleOutgoingDark = Color(0xFF056162); // Dark green
  static const Color chatBubbleIncomingDark = Color(0xFF1F2C34); // Dark gray
  
  // Status Colors
  static const Color onlineStatus = Color(0xFF4CAF50);
  static const Color offlineStatus = Color(0xFF9E9E9E);
  static const Color awayStatus = Color(0xFFFF9800);
  static const Color busyStatus = Color(0xFFE91E63);
  
  // Message Status Colors
  static const Color messageSent = Color(0xFF9E9E9E);
  static const Color messageDelivered = Color(0xFF2196F3);
  static const Color messageRead = Color(0xFF25D366);
  static const Color messageFailed = Color(0xFFE91E63);
  
  // Typing Indicator Colors
  static const Color typingIndicator = Color(0xFF25D366);
  static const Color typingIndicatorDark = Color(0xFF8696A0);
  
  // Attachment Colors
  static const Color documentColor = Color(0xFF2196F3);
  static const Color imageColor = Color(0xFF4CAF50);
  static const Color videoColor = Color(0xFFE91E63);
  static const Color audioColor = Color(0xFFFF9800);
  static const Color voiceColor = Color(0xFF9C27B0);
  static const Color locationColor = Color(0xFF795548);
  
  // Shimmer Colors
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
  static const Color shimmerBaseDark = Color(0xFF1F2C34);
  static const Color shimmerHighlightDark = Color(0xFF3C4043);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF25D366), Color(0xFF128C7E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0B141B), Color(0xFF1F2C34)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Transparent Colors
  static const Color transparent = Colors.transparent;
  static const Color black12 = Colors.black12;
  static const Color black26 = Colors.black26;
  static const Color black38 = Colors.black38;
  static const Color black54 = Colors.black54;
  static const Color white10 = Color(0x1AFFFFFF);
  static const Color white24 = Color(0x3DFFFFFF);
  static const Color white38 = Color(0x61FFFFFF);
  static const Color white54 = Color(0x8AFFFFFF);
  
  // Helper methods
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'online':
        return onlineStatus;
      case 'away':
        return awayStatus;
      case 'busy':
        return busyStatus;
      default:
        return offlineStatus;
    }
  }
  
  static Color getMessageStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'sent':
        return messageSent;
      case 'delivered':
        return messageDelivered;
      case 'read':
        return messageRead;
      case 'failed':
        return messageFailed;
      default:
        return messageSent;
    }
  }
  
  static Color getAttachmentColor(String type) {
    switch (type.toLowerCase()) {
      case 'document':
        return documentColor;
      case 'image':
        return imageColor;
      case 'video':
        return videoColor;
      case 'audio':
        return audioColor;
      case 'voice':
        return voiceColor;
      case 'location':
        return locationColor;
      default:
        return primary;
    }
  }
}