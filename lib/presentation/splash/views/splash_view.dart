import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';
import '../../../core/theme/app_colors.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 24),
            Text(
              'Perpustakaan Digital',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.indigo,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            const CircularProgressIndicator(color: AppColors.indigo),
          ],
        ),
      ),
    );
  }
}
