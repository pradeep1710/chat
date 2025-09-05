import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/themes/app_colors.dart';
import '../../core/constants/app_config.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? hintText;
  final String? labelText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final void Function()? onSuffixIconTap;
  final bool autofocus;
  final Color? fillColor;
  final Color? borderColor;
  final double? borderRadius;

  const CustomTextField({
    super.key,
    required this.controller,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.suffix,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onSuffixIconTap,
    this.autofocus = false,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _isObscured;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.labelText != null) ...[
          Text(
            widget.labelText!,
            style: theme.textTheme.labelMedium?.copyWith(
              color: _isFocused 
                  ? AppColors.primary 
                  : AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],
        
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: _isObscured,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          onTap: widget.onTap,
          autofocus: widget.autofocus,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor: widget.fillColor ?? 
                (widget.enabled 
                    ? AppColors.surfaceVariant 
                    : AppColors.surfaceVariant.withOpacity(0.5)),
            
            // Prefix icon
            prefixIcon: widget.prefixIcon != null
                ? Icon(
                    widget.prefixIcon,
                    color: _isFocused 
                        ? AppColors.primary 
                        : AppColors.onSurfaceVariant,
                    size: 20,
                  )
                : null,
            
            // Suffix icon/widget
            suffixIcon: _buildSuffixIcon(),
            suffix: widget.suffix,
            
            // Border styling
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: widget.borderColor != null
                  ? BorderSide(color: widget.borderColor!, width: 1)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                widget.borderRadius ?? AppConfig.borderRadius,
              ),
              borderSide: BorderSide.none,
            ),
            
            // Content padding
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            
            // Counter style
            counterStyle: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            
            // Helper text style
            helperStyle: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
            
            // Error text style
            errorStyle: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.error,
            ),
            
            // Hint text style
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (widget.obscureText) {
      return IconButton(
        onPressed: () {
          setState(() {
            _isObscured = !_isObscured;
          });
        },
        icon: Icon(
          _isObscured 
              ? Icons.visibility_off_rounded 
              : Icons.visibility_rounded,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
      );
    }
    
    if (widget.suffixIcon != null) {
      return IconButton(
        onPressed: widget.onSuffixIconTap,
        icon: Icon(
          widget.suffixIcon,
          color: AppColors.onSurfaceVariant,
          size: 20,
        ),
      );
    }
    
    return null;
  }
}