import 'package:get/get.dart';
import '../routes/app_routes.dart';
import 'auth_controller.dart';
import 'app_controller.dart';

class SplashController extends GetxController {
  final RxBool _isLoading = true.obs;
  
  bool get isLoading => _isLoading.value;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Wait for app initialization
      await Future.delayed(const Duration(seconds: 2));
      
      // Check authentication status
      final authController = Get.find<AuthController>();
      
      if (authController.isAuthenticated) {
        // User is already logged in, go to home
        Get.offAllNamed(AppRoutes.home);
      } else {
        // User is not logged in, check if first time
        final appController = Get.find<AppController>();
        
        if (appController.isFirstTime) {
          // First time user, show onboarding
          Get.offAllNamed(AppRoutes.onboarding);
        } else {
          // Returning user, show phone auth
          Get.offAllNamed(AppRoutes.phoneAuth);
        }
      }
    } catch (e) {
      print('Error initializing app: $e');
      // If there's an error, go to phone auth
      Get.offAllNamed(AppRoutes.phoneAuth);
    } finally {
      _isLoading.value = false;
    }
  }
}