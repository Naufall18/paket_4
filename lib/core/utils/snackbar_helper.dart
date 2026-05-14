import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SnackbarHelper {
  static void showSuccess(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF065F46) : const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle_rounded, color: Get.isDarkMode ? const Color(0xFF34D399) : const Color(0xFF059669), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Get.isDarkMode ? Colors.white : const Color(0xFF1F2937))),
          ),
        ],
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 44),
        child: Text(message, style: TextStyle(fontSize: 13, color: Get.isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563))),
      ),
      backgroundColor: Get.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(Get.isDarkMode ? 0.4 : 0.08), blurRadius: 20, offset: const Offset(0, 6)),
        BoxShadow(color: const Color(0xFF059669).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
      barBlur: 5,
      duration: const Duration(seconds: 3),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  static void showError(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF7F1D1D) : const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.error_outline_rounded, color: Get.isDarkMode ? const Color(0xFFF87171) : const Color(0xFFDC2626), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Get.isDarkMode ? Colors.white : const Color(0xFF1F2937))),
          ),
        ],
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 44),
        child: Text(message, style: TextStyle(fontSize: 13, color: Get.isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563))),
      ),
      backgroundColor: Get.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(Get.isDarkMode ? 0.4 : 0.08), blurRadius: 20, offset: const Offset(0, 6)),
        BoxShadow(color: const Color(0xFFDC2626).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
      barBlur: 5,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }

  static void showWarning(String title, String message) {
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();
    Get.snackbar(
      '',
      '',
      titleText: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Get.isDarkMode ? const Color(0xFF78350F) : const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.warning_amber_rounded, color: Get.isDarkMode ? const Color(0xFFFBBF24) : const Color(0xFFD97706), size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Get.isDarkMode ? Colors.white : const Color(0xFF1F2937))),
          ),
        ],
      ),
      messageText: Padding(
        padding: EdgeInsets.only(left: 44),
        child: Text(message, style: TextStyle(fontSize: 13, color: Get.isDarkMode ? const Color(0xFFD1D5DB) : const Color(0xFF4B5563))),
      ),
      backgroundColor: Get.isDarkMode ? const Color(0xFF1F2937) : Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      boxShadows: [
        BoxShadow(color: Colors.black.withOpacity(Get.isDarkMode ? 0.4 : 0.08), blurRadius: 20, offset: const Offset(0, 6)),
        BoxShadow(color: const Color(0xFFD97706).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
      ],
      barBlur: 5,
      duration: const Duration(seconds: 4),
      animationDuration: const Duration(milliseconds: 400),
      forwardAnimationCurve: Curves.easeOutCubic,
    );
  }
}
