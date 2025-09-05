import 'package:get/get.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/phone_auth_screen.dart';
import '../screens/auth/otp_verification_screen.dart';
import '../screens/auth/profile_setup_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/chat/chat_info_screen.dart';
import '../screens/groups/group_create_screen.dart';
import '../screens/groups/group_detail_screen.dart';
import '../screens/groups/group_info_screen.dart';
import '../screens/communities/community_list_screen.dart';
import '../screens/communities/community_create_screen.dart';
import '../screens/communities/community_detail_screen.dart';
import '../screens/status/status_create_screen.dart';
import '../screens/status/status_viewer_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/privacy_screen.dart';
import '../screens/settings/notifications_screen.dart';
import '../screens/media/camera_screen.dart';
import '../screens/media/gallery_screen.dart';
import '../screens/search/search_screen.dart';

import '../bindings/splash_binding.dart';
import '../bindings/auth_binding.dart';
import '../bindings/home_binding.dart';
import '../bindings/chat_binding.dart';
import '../bindings/group_binding.dart';
import '../bindings/community_binding.dart';
import '../bindings/status_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/settings_binding.dart';
import '../bindings/media_binding.dart';

import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    // Authentication Pages
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.phoneAuth,
      page: () => const PhoneAuthScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.otpVerification,
      page: () => const OtpVerificationScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profileSetup,
      page: () => const ProfileSetupScreen(),
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Main App Pages
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Chat Pages
    GetPage(
      name: AppRoutes.chatDetail,
      page: () => const ChatDetailScreen(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.chatInfo,
      page: () => const ChatInfoScreen(),
      binding: ChatBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Group Pages
    GetPage(
      name: AppRoutes.groupCreate,
      page: () => const GroupCreateScreen(),
      binding: GroupBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupDetail,
      page: () => const GroupDetailScreen(),
      binding: GroupBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.groupInfo,
      page: () => const GroupInfoScreen(),
      binding: GroupBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Community Pages
    GetPage(
      name: AppRoutes.communityList,
      page: () => const CommunityListScreen(),
      binding: CommunityBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.communityCreate,
      page: () => const CommunityCreateScreen(),
      binding: CommunityBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.communityDetail,
      page: () => const CommunityDetailScreen(),
      binding: CommunityBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Status Pages
    GetPage(
      name: AppRoutes.statusCreate,
      page: () => const StatusCreateScreen(),
      binding: StatusBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.statusViewer,
      page: () => const StatusViewerScreen(),
      binding: StatusBinding(),
      transition: Transition.fadeIn,
    ),
    
    // Profile Pages
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: ProfileBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Settings Pages
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.privacy,
      page: () => const PrivacyScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.notifications,
      page: () => const NotificationsScreen(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Media Pages
    GetPage(
      name: AppRoutes.camera,
      page: () => const CameraScreen(),
      binding: MediaBinding(),
      transition: Transition.downToUp,
    ),
    GetPage(
      name: AppRoutes.gallery,
      page: () => const GalleryScreen(),
      binding: MediaBinding(),
      transition: Transition.rightToLeft,
    ),
    
    // Search Pages
    GetPage(
      name: AppRoutes.search,
      page: () => const SearchScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}