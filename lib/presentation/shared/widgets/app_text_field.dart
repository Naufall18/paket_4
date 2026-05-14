import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Reusable labeled text field used across admin and student forms.
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool isNumber;
  final bool isPassword;
  final bool isEmail;
  final bool? obscureText;
  final Widget? suffixIcon;
  final Color? fillColor;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.isNumber = false,
    this.isPassword = false,
    this.isEmail = false,
    this.obscureText,
    this.suffixIcon,
    this.fillColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isNumber ? TextInputType.number : TextInputType.text),
      obscureText: obscureText ?? isPassword,
      style: TextStyle(fontSize: 14, color: AppColors.textDark),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 18, color: AppColors.textMuted),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: fillColor ?? AppColors.inputFill,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.indigo),
        ),
      ),
    );
  }
}
