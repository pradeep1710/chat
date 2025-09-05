import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class PhoneAuthScreen extends GetView<AuthController> {
  const PhoneAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController phoneController = TextEditingController();
    final FocusNode phoneFocusNode = FocusNode();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              
              // Back button
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_rounded),
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              
              const SizedBox(height: 40),
              
              // Title
              const Text(
                'Enter your phone number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              const Text(
                'We\'ll send you a verification code to confirm your phone number.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Phone number input
              CustomTextField(
                controller: phoneController,
                focusNode: phoneFocusNode,
                hintText: '+1 234 567 8900',
                labelText: 'Phone Number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.phone_rounded,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (!controller.isValidPhoneNumber(value)) {
                    return 'Please enter a valid phone number with country code';
                  }
                  return null;
                },
                onSubmitted: (_) => _sendOtp(phoneController.text.trim()),
              ),
              
              const SizedBox(height: 24),
              
              // Info text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConfig.borderRadius),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Make sure to include your country code (e.g., +1 for US, +44 for UK)',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.info,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Continue button
              Obx(() => LoadingButton(
                onPressed: () => _sendOtp(phoneController.text.trim()),
                isLoading: controller.isLoading,
                text: 'Send Verification Code',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              )),
              
              const SizedBox(height: 16),
              
              // Terms and privacy
              Text.rich(
                TextSpan(
                  text: 'By continuing, you agree to our ',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  children: [
                    TextSpan(
                      text: 'Terms of Service',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const TextSpan(text: ' and '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendOtp(String phoneNumber) async {
    if (phoneNumber.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter your phone number',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.sendOtp(phoneNumber);
    if (success) {
      Get.toNamed(AppRoutes.otpVerification, arguments: {
        'phoneNumber': phoneNumber,
      });
    }
  }
}