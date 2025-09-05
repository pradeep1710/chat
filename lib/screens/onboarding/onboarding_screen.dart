import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../routes/app_routes.dart';
import '../../controllers/app_controller.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'Welcome to ChatApp',
      description: 'Connect with friends and family through secure messaging, voice calls, and video calls.',
      icon: Icons.chat_bubble_outline_rounded,
      color: AppColors.primary,
    ),
    OnboardingPage(
      title: 'Stay Connected',
      description: 'Share photos, videos, documents, and your location with end-to-end encryption.',
      icon: Icons.security_rounded,
      color: AppColors.secondary,
    ),
    OnboardingPage(
      title: 'Create Communities',
      description: 'Join public communities or create your own to discuss topics you love.',
      icon: Icons.groups_rounded,
      color: AppColors.info,
    ),
    OnboardingPage(
      title: 'Share Your Stories',
      description: 'Share your moments with status updates that disappear after 24 hours.',
      icon: Icons.auto_stories_rounded,
      color: AppColors.warning,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            
            // Page indicator and navigation
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => _buildIndicator(index),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: _previousPage,
                          child: const Text(
                            'Previous',
                            style: TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 80),
                      
                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: _currentPage == _pages.length - 1 ? _getStarted : _nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _pages[_currentPage].color,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                          ),
                        ),
                        child: Text(
                          _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            page.description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: AppConfig.shortAnimation,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? _pages[_currentPage].color 
            : AppColors.onSurfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: AppConfig.mediumAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: AppConfig.mediumAnimation,
      curve: Curves.easeInOut,
    );
  }

  void _skip() {
    _getStarted();
  }

  void _getStarted() async {
    // Mark onboarding as completed
    final appController = Get.find<AppController>();
    await appController.setFirstTimeComplete();
    
    // Navigate to phone auth
    Get.offAllNamed(AppRoutes.phoneAuth);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}