import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:async';

import '../../controllers/auth_controller.dart';
import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/loading_button.dart';

class OtpVerificationScreen extends GetView<AuthController> {
  const OtpVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String phoneNumber = Get.arguments?['phoneNumber'] ?? '';
    final TextEditingController otpController = TextEditingController();
    final TextEditingController usernameController = TextEditingController();
    final FocusNode otpFocusNode = FocusNode();
    final FocusNode usernameFocusNode = FocusNode();
    
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
                'Verify your number',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subtitle
              Text(
                'We\'ve sent a 6-digit code to $phoneNumber',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              
              const SizedBox(height: 48),
              
              // OTP Input
              CustomTextField(
                controller: otpController,
                focusNode: otpFocusNode,
                hintText: '123456',
                labelText: 'Verification Code',
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                prefixIcon: Icons.security_rounded,
                maxLength: 6,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the verification code';
                  }
                  if (value.length != 6) {
                    return 'Verification code must be 6 digits';
                  }
                  return null;
                },
                onSubmitted: (_) => usernameFocusNode.requestFocus(),
              ),
              
              const SizedBox(height: 24),
              
              // Username Input
              CustomTextField(
                controller: usernameController,
                focusNode: usernameFocusNode,
                hintText: 'johndoe',
                labelText: 'Username',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.person_rounded,
                textCapitalization: TextCapitalization.none,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_]')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  if (value.length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  return null;
                },
                onSubmitted: (_) => _verifyOtp(otpController.text.trim(), usernameController.text.trim()),
              ),
              
              const SizedBox(height: 24),
              
              // Resend OTP section
              _ResendOtpWidget(phoneNumber: phoneNumber),
              
              const Spacer(),
              
              // Verify button
              Obx(() => LoadingButton(
                onPressed: () => _verifyOtp(otpController.text.trim(), usernameController.text.trim()),
                isLoading: controller.isLoading,
                text: 'Verify & Continue',
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              )),
              
              const SizedBox(height: 16),
              
              // Help text
              Center(
                child: Text(
                  'Didn\'t receive the code? Check your SMS or try again.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOtp(String otp, String username) async {
    if (otp.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter the verification code',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    if (username.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a username',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    await controller.verifyOtp(otp, username);
  }
}

class _ResendOtpWidget extends StatefulWidget {
  final String phoneNumber;

  const _ResendOtpWidget({required this.phoneNumber});

  @override
  State<_ResendOtpWidget> createState() => _ResendOtpWidgetState();
}

class _ResendOtpWidgetState extends State<_ResendOtpWidget> {
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = 60;
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _resendOtp() async {
    final authController = Get.find<AuthController>();
    final success = await authController.sendOtp(widget.phoneNumber);
    
    if (success) {
      _startTimer();
      Get.snackbar(
        'Code Sent',
        'A new verification code has been sent',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Didn\'t receive the code? ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        if (_canResend)
          GestureDetector(
            onTap: _resendOtp,
            child: const Text(
              'Resend',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Text(
            'Resend in ${_remainingSeconds}s',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
      ],
    );
  }
}