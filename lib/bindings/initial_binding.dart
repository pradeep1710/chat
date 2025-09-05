import 'package:get/get.dart';

import '../controllers/app_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/storage_controller.dart';
import '../controllers/network_controller.dart';
import '../controllers/theme_controller.dart';
import '../services/api/api_service.dart';
import '../services/socket/socket_service.dart';
import '../services/storage/storage_service.dart';
import '../services/media/media_service.dart';
import '../services/notifications/notification_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core Services (Permanent)
    Get.put<StorageService>(StorageService(), permanent: true);
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<SocketService>(SocketService(), permanent: true);
    Get.put<MediaService>(MediaService(), permanent: true);
    Get.put<NotificationService>(NotificationService(), permanent: true);
    
    // Core Controllers (Permanent)
    Get.put<AppController>(AppController(), permanent: true);
    Get.put<AuthController>(AuthController(), permanent: true);
    Get.put<StorageController>(StorageController(), permanent: true);
    Get.put<NetworkController>(NetworkController(), permanent: true);
    Get.put<ThemeController>(ThemeController(), permanent: true);
  }
}