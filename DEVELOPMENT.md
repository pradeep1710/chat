# Development Guide

This guide explains how to extend and customize the ChatApp Flutter application.

## 🏗 Architecture Overview

The app follows a clean architecture pattern with GetX for state management:

```
Presentation Layer (Screens/Widgets)
         ↓
Controller Layer (GetX Controllers)
         ↓
Service Layer (API, Socket, Storage, etc.)
         ↓
Data Layer (Models, Local Storage)
```

## 🎯 Adding New Features

### 1. Creating a New Screen

1. **Create the screen file**:
   ```dart
   // lib/screens/feature/feature_screen.dart
   import 'package:flutter/material.dart';
   import 'package:get/get.dart';
   import '../../controllers/feature_controller.dart';

   class FeatureScreen extends GetView<FeatureController> {
     const FeatureScreen({super.key});

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text('Feature')),
         body: Obx(() => 
           controller.isLoading
             ? const Center(child: CircularProgressIndicator())
             : _buildContent(),
         ),
       );
     }

     Widget _buildContent() {
       return const Center(
         child: Text('Feature Screen Content'),
       );
     }
   }
   ```

2. **Create the controller**:
   ```dart
   // lib/controllers/feature_controller.dart
   import 'package:get/get.dart';

   class FeatureController extends GetxController {
     final RxBool _isLoading = false.obs;
     
     bool get isLoading => _isLoading.value;

     @override
     void onInit() {
       super.onInit();
       _loadData();
     }

     Future<void> _loadData() async {
       try {
         _isLoading.value = true;
         // Load data logic
       } catch (e) {
         Get.snackbar('Error', 'Failed to load data: $e');
       } finally {
         _isLoading.value = false;
       }
     }
   }
   ```

3. **Create the binding**:
   ```dart
   // lib/bindings/feature_binding.dart
   import 'package:get/get.dart';
   import '../controllers/feature_controller.dart';

   class FeatureBinding extends Bindings {
     @override
     void dependencies() {
       Get.lazyPut<FeatureController>(() => FeatureController());
     }
   }
   ```

4. **Add the route**:
   ```dart
   // lib/routes/app_routes.dart
   static const String feature = '/feature';

   // lib/routes/app_pages.dart
   GetPage(
     name: AppRoutes.feature,
     page: () => const FeatureScreen(),
     binding: FeatureBinding(),
     transition: Transition.rightToLeft,
   ),
   ```

### 2. Adding API Endpoints

1. **Add to API service**:
   ```dart
   // lib/services/api/api_service.dart
   Future<Map<String, dynamic>> getFeatureData() async {
     try {
       final response = await _dio.get('/feature');
       return response.data;
     } catch (e) {
       throw _handleDioException(e);
     }
   }

   Future<Map<String, dynamic>> createFeature(Map<String, dynamic> data) async {
     try {
       final response = await _dio.post('/feature', data: data);
       return response.data;
     } catch (e) {
       throw _handleDioException(e);
     }
   }
   ```

2. **Use in controller**:
   ```dart
   // In your controller
   final ApiService _apiService = Get.find<ApiService>();

   Future<void> loadFeatureData() async {
     try {
       final response = await _apiService.getFeatureData();
       // Process response
     } catch (e) {
       Get.snackbar('Error', 'Failed to load feature data');
     }
   }
   ```

### 3. Adding Socket.IO Events

1. **Add event handlers to SocketService**:
   ```dart
   // lib/services/socket/socket_service.dart
   void _setupSocketListeners() {
     // Existing listeners...
     
     _socket?.on('feature_event', (data) {
       print('Feature event received: $data');
       _handleFeatureEvent(data);
     });
   }

   void _handleFeatureEvent(dynamic data) {
     try {
       if (Get.isRegistered<FeatureController>()) {
         Get.find<FeatureController>().onFeatureEvent(data);
       }
     } catch (e) {
       print('Error handling feature event: $e');
     }
   }

   void emitFeatureAction(Map<String, dynamic> data) {
     if (_socket?.connected == true) {
       _socket?.emit('feature_action', data);
     }
   }
   ```

2. **Handle in controller**:
   ```dart
   // In your controller
   void onFeatureEvent(dynamic data) {
     // Handle the socket event
     print('Received feature event: $data');
     // Update UI state
   }
   ```

### 4. Creating Custom Widgets

1. **Create reusable widget**:
   ```dart
   // lib/widgets/common/custom_feature_widget.dart
   import 'package:flutter/material.dart';
   import '../../core/themes/app_colors.dart';

   class CustomFeatureWidget extends StatelessWidget {
     final String title;
     final String description;
     final VoidCallback? onTap;
     final IconData? icon;

     const CustomFeatureWidget({
       super.key,
       required this.title,
       required this.description,
       this.onTap,
       this.icon,
     });

     @override
     Widget build(BuildContext context) {
       return Card(
         child: InkWell(
           onTap: onTap,
           child: Padding(
             padding: const EdgeInsets.all(16.0),
             child: Row(
               children: [
                 if (icon != null) ...[
                   Icon(icon, color: AppColors.primary),
                   const SizedBox(width: 16),
                 ],
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         title,
                         style: Theme.of(context).textTheme.titleMedium,
                       ),
                       const SizedBox(height: 4),
                       Text(
                         description,
                         style: Theme.of(context).textTheme.bodySmall,
                       ),
                     ],
                   ),
                 ),
               ],
             ),
           ),
         ),
       );
     }
   }
   ```

## 🎨 UI Customization

### 1. Updating Themes

1. **Modify colors**:
   ```dart
   // lib/core/themes/app_colors.dart
   class AppColors {
     static const Color primary = Color(0xFF25D366); // Change this
     static const Color secondary = Color(0xFF128C7E);
     // Add new colors
     static const Color customColor = Color(0xFF123456);
   }
   ```

2. **Update theme data**:
   ```dart
   // lib/core/themes/app_theme.dart
   static ThemeData get lightTheme {
     return ThemeData(
       // Update theme properties
       primarySwatch: MaterialColor(0xFF25D366, {
         50: AppColors.primary.withOpacity(0.1),
         100: AppColors.primary.withOpacity(0.2),
         // ... more shades
       }),
     );
   }
   ```

### 2. Custom Components

1. **Create component variations**:
   ```dart
   // lib/widgets/common/custom_button.dart
   class CustomButton extends StatelessWidget {
     final String text;
     final VoidCallback? onPressed;
     final ButtonStyle? style;
     final bool isLoading;

     const CustomButton({
       super.key,
       required this.text,
       this.onPressed,
       this.style,
       this.isLoading = false,
     });

     @override
     Widget build(BuildContext context) {
       return ElevatedButton(
         onPressed: isLoading ? null : onPressed,
         style: style ?? _defaultStyle(context),
         child: isLoading
           ? const SizedBox(
               width: 20,
               height: 20,
               child: CircularProgressIndicator(strokeWidth: 2),
             )
           : Text(text),
       );
     }

     ButtonStyle _defaultStyle(BuildContext context) {
       return ElevatedButton.styleFrom(
         backgroundColor: AppColors.primary,
         foregroundColor: Colors.white,
         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(12),
         ),
       );
     }
   }
   ```

## 🔧 Configuration Management

### 1. Environment-specific Configuration

1. **Create environment files**:
   ```dart
   // lib/core/config/dev_config.dart
   class DevConfig {
     static const String baseUrl = 'http://localhost:3000/api';
     static const String socketUrl = 'http://localhost:3000';
     static const bool enableLogging = true;
   }

   // lib/core/config/prod_config.dart
   class ProdConfig {
     static const String baseUrl = 'https://api.yourapp.com/api';
     static const String socketUrl = 'https://api.yourapp.com';
     static const bool enableLogging = false;
   }
   ```

2. **Use configuration**:
   ```dart
   // lib/core/config/app_config.dart
   import 'dev_config.dart';
   import 'prod_config.dart';

   class AppConfig {
     static bool get isDevelopment => kDebugMode;
     
     static String get baseUrl => isDevelopment 
       ? DevConfig.baseUrl 
       : ProdConfig.baseUrl;
     
     static String get socketUrl => isDevelopment 
       ? DevConfig.socketUrl 
       : ProdConfig.socketUrl;
   }
   ```

### 2. Feature Flags

1. **Create feature flags**:
   ```dart
   // lib/core/config/feature_flags.dart
   class FeatureFlags {
     static const bool enableVoiceCalls = true;
     static const bool enableVideoCalls = false;
     static const bool enableStories = true;
     static const bool enableCommunities = true;
   }
   ```

2. **Use in code**:
   ```dart
   if (FeatureFlags.enableVoiceCalls) {
     // Show voice call button
   }
   ```

## 🧪 Testing

### 1. Unit Testing

1. **Test controllers**:
   ```dart
   // test/controllers/feature_controller_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:get/get.dart';
   import '../lib/controllers/feature_controller.dart';

   void main() {
     group('FeatureController', () {
       late FeatureController controller;

       setUp(() {
         Get.testMode = true;
         controller = FeatureController();
       });

       tearDown(() {
         Get.reset();
       });

       test('should initialize with loading false', () {
         expect(controller.isLoading, false);
       });

       test('should load data successfully', () async {
         await controller.loadData();
         expect(controller.isLoading, false);
         expect(controller.hasData, true);
       });
     });
   }
   ```

2. **Test services**:
   ```dart
   // test/services/api_service_test.dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:mockito/mockito.dart';
   import '../lib/services/api/api_service.dart';

   void main() {
     group('ApiService', () {
       late ApiService apiService;

       setUp(() {
         apiService = ApiService();
       });

       test('should handle successful API response', () async {
         // Mock API response
         final result = await apiService.getFeatureData();
         expect(result['success'], true);
       });
     });
   }
   ```

### 2. Widget Testing

1. **Test screens**:
   ```dart
   // test/screens/feature_screen_test.dart
   import 'package:flutter/material.dart';
   import 'package:flutter_test/flutter_test.dart';
   import 'package:get/get.dart';
   import '../lib/screens/feature/feature_screen.dart';
   import '../lib/controllers/feature_controller.dart';

   void main() {
     group('FeatureScreen', () {
       testWidgets('should display loading indicator', (tester) async {
         Get.put(FeatureController());
         
         await tester.pumpWidget(
           GetMaterialApp(
             home: const FeatureScreen(),
           ),
         );

         expect(find.byType(CircularProgressIndicator), findsOneWidget);
       });
     });
   }
   ```

## 🚀 Performance Optimization

### 1. Lazy Loading

1. **Use lazy loading for controllers**:
   ```dart
   // In bindings
   Get.lazyPut<FeatureController>(() => FeatureController());
   ```

2. **Lazy load heavy resources**:
   ```dart
   class FeatureController extends GetxController {
     List<Data>? _cachedData;
     
     List<Data> get data {
       _cachedData ??= _loadHeavyData();
       return _cachedData!;
     }
   }
   ```

### 2. Memory Management

1. **Dispose resources properly**:
   ```dart
   class FeatureController extends GetxController {
     StreamSubscription? _subscription;

     @override
     void onInit() {
       super.onInit();
       _subscription = someStream.listen((data) {
         // Handle data
       });
     }

     @override
     void onClose() {
       _subscription?.cancel();
       super.onClose();
     }
   }
   ```

### 3. Image Optimization

1. **Use cached network images**:
   ```dart
   CachedNetworkImage(
     imageUrl: imageUrl,
     placeholder: (context, url) => const CircularProgressIndicator(),
     errorWidget: (context, url, error) => const Icon(Icons.error),
     memCacheWidth: 300, // Optimize memory usage
     memCacheHeight: 300,
   )
   ```

## 🔒 Security Best Practices

### 1. Data Validation

1. **Validate inputs**:
   ```dart
   bool isValidEmail(String email) {
     return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
   }

   bool isValidPhoneNumber(String phone) {
     return RegExp(r'^\+[1-9]\d{1,14}$').hasMatch(phone);
   }
   ```

2. **Sanitize data**:
   ```dart
   String sanitizeInput(String input) {
     return input.trim().replaceAll(RegExp(r'[<>]'), '');
   }
   ```

### 2. Secure Storage

1. **Use secure storage for sensitive data**:
   ```dart
   // For sensitive data like tokens
   await FlutterSecureStorage().write(key: 'auth_token', value: token);
   
   // For regular app data
   await GetStorage().write('user_preferences', preferences);
   ```

## 📱 Platform-specific Considerations

### 1. Android

1. **Handle Android-specific permissions**:
   ```dart
   Future<bool> requestAndroidPermission() async {
     if (Platform.isAndroid) {
       final status = await Permission.camera.request();
       return status.isGranted;
     }
     return true;
   }
   ```

### 2. iOS

1. **Handle iOS-specific features**:
   ```dart
   Future<void> setupiOSSpecific() async {
     if (Platform.isIOS) {
       // iOS-specific setup
       await setupiOSNotifications();
     }
   }
   ```

## 🐛 Debugging Tips

### 1. Logging

1. **Use structured logging**:
   ```dart
   class Logger {
     static void info(String message, [dynamic data]) {
       if (kDebugMode) {
         print('[INFO] $message ${data != null ? ': $data' : ''}');
       }
     }

     static void error(String message, [dynamic error]) {
       if (kDebugMode) {
         print('[ERROR] $message ${error != null ? ': $error' : ''}');
       }
     }
   }
   ```

### 2. GetX Debugging

1. **Enable GetX logging**:
   ```dart
   void main() {
     Get.config(
       enableLog: kDebugMode,
       defaultTransition: Transition.cupertino,
       logWriterCallback: (text, {isError = false}) {
         print('[GetX] $text');
       },
     );
     runApp(const ChatApp());
   }
   ```

## 📚 Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [GetX Documentation](https://github.com/jonataslaw/getx)
- [Material Design 3](https://m3.material.io/)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)

---

This development guide provides the foundation for extending the ChatApp with new features while maintaining code quality and consistency.