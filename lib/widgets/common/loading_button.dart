import 'package:flutter/material.dart';

import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';

class LoadingButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? loadingColor;
  final double? width;
  final double? height;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;
  final bool expanded;

  const LoadingButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.backgroundColor,
    this.textColor,
    this.loadingColor,
    this.width,
    this.height,
    this.borderRadius,
    this.padding,
    this.icon,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.6),
        disabledForegroundColor: (textColor ?? Colors.white).withOpacity(0.6),
        elevation: isLoading ? 0 : 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConfig.borderRadius,
          ),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: Size(width ?? 0, height ?? 56),
      ),
      child: AnimatedSwitcher(
        duration: AppConfig.shortAnimation,
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingColor ?? textColor ?? Colors.white,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

class LoadingTextButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final String text;
  final Color? textColor;
  final Color? loadingColor;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  const LoadingTextButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.text,
    this.textColor,
    this.loadingColor,
    this.padding,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: textColor ?? AppColors.primary,
        disabledForegroundColor: (textColor ?? AppColors.primary).withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConfig.borderRadius),
        ),
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      child: AnimatedSwitcher(
        duration: AppConfig.shortAnimation,
        child: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    loadingColor ?? textColor ?? AppColors.primary,
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor ?? AppColors.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class LoadingIconButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData icon;
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? loadingColor;
  final double? size;
  final double? iconSize;

  const LoadingIconButton({
    super.key,
    required this.onPressed,
    required this.isLoading,
    required this.icon,
    this.backgroundColor,
    this.iconColor,
    this.loadingColor,
    this.size,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 48,
      height: size ?? 48,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: iconColor ?? Colors.white,
          disabledBackgroundColor: (backgroundColor ?? AppColors.primary).withOpacity(0.6),
          elevation: isLoading ? 0 : 2,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
        ),
        child: AnimatedSwitcher(
          duration: AppConfig.shortAnimation,
          child: isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      loadingColor ?? iconColor ?? Colors.white,
                    ),
                  ),
                )
              : Icon(
                  icon,
                  size: iconSize ?? 24,
                ),
        ),
      ),
    );
  }
}