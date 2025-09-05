import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controllers/splash_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.primaryGradient,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo/Animation
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black26,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // App Name
              const Text(
                AppConfig.appName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // App Tagline
              const Text(
                'Connect • Chat • Share',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              
              const SizedBox(height: 80),
              
              // Loading Indicator
              Obx(() => controller.isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    )
                  : const SizedBox.shrink()),
              
              const SizedBox(height: 100),
              
              // Version Info
              const Text(
                'Version ${AppConfig.appVersion}',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}