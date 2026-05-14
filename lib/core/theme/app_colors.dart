import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppColors {
  // Primary (Indigo)
  static const Color indigo = Color(0xFF6366f1);
  static const Color indigoLight = Color(0xFF818cf8);
  static const Color indigoDark = Color(0xFF4f46e5);

  // Dynamic Backgrounds
  static Color get background =>
      Get.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9);
  static Color get cardLight =>
      Get.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFFFFFFF);

  static const Color darkSlate = Color(0xFF1E293B);
  static const Color darkerSlate = Color(0xFF0F172A);

  // Dynamic Text Colors
  static Color get textDark =>
      Get.isDarkMode ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textMuted =>
      Get.isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  static Color get textLight =>
      Get.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

  // Status
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Glass Elements
  static const Color glassWhite = Color(0xBFFFFFFF);
  static const Color glassBorder = Color(0x66FFFFFF);

  // Dynamic borders & fills for Dark Mode compatibility
  static Color get border =>
      Get.isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  static Color get inputFill =>
      Get.isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  static Color get divider =>
      Get.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
  static Color get chipBg =>
      Get.isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);
}
