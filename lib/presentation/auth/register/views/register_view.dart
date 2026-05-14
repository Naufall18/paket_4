import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/register_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/glassmorphism.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Blobs mimicking Laravel CSS body::before & after
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 450,
              height: 450,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.indigo.withOpacity(Get.isDarkMode ? 0.15 : 0.1),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.indigo.withOpacity(Get.isDarkMode ? 0.12 : 0.07),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.0),
              child: GlassContainer(
                padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Logo Area
                    Center(
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: AppColors.indigo.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 40,
                              height: 40,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Buat Akun Baru',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daftar untuk mengakses perpustakaan',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 32),

                    // Forms
                    TextField(
                      controller: controller.nisController,
                      style: TextStyle(color: AppColors.textDark),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'NISN',
                        prefixIcon: Icon(
                          Icons.pin_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller.nameController,
                      style: TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        prefixIcon: Icon(
                          Icons.badge_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller.usernameController,
                      style: TextStyle(color: AppColors.textDark),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(
                          Icons.person_outline,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller.emailController,
                      style: TextStyle(color: AppColors.textDark),
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        const kelasList = [
                          'X RPL 1', 'X RPL 2',
                          'X TKJ 1', 'X TKJ 2',
                          'X MM 1', 'X MM 2',
                          'X AKL 1', 'X AKL 2',
                          'X OTKP 1', 'X OTKP 2',
                          'X BDP 1', 'X BDP 2',
                          'XI RPL 1', 'XI RPL 2',
                          'XI TKJ 1', 'XI TKJ 2',
                          'XI MM 1', 'XI MM 2',
                          'XI AKL 1', 'XI AKL 2',
                          'XI OTKP 1', 'XI OTKP 2',
                          'XI BDP 1', 'XI BDP 2',
                          'XII RPL 1', 'XII RPL 2',
                          'XII TKJ 1', 'XII TKJ 2',
                          'XII MM 1', 'XII MM 2',
                          'XII AKL 1', 'XII AKL 2',
                          'XII OTKP 1', 'XII OTKP 2',
                          'XII BDP 1', 'XII BDP 2',
                        ];
                        if (textEditingValue.text.isEmpty) return kelasList;
                        return kelasList.where(
                          (k) => k.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          ),
                        );
                      },
                      onSelected: (String selection) {
                        controller.kelasController.text = selection;
                      },
                      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                        textEditingController.text = controller.kelasController.text;
                        textEditingController.addListener(() {
                          controller.kelasController.text = textEditingController.text;
                        });
                        return TextField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: TextStyle(color: AppColors.textDark),
                          decoration: InputDecoration(
                            labelText: 'Kelas',
                            prefixIcon: Icon(
                              Icons.class_outlined,
                              color: AppColors.textMuted,
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller.noHpController,
                      style: TextStyle(color: AppColors.textDark),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'No. HP (Opsional)',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: controller.adminCodeController,
                      style: TextStyle(color: AppColors.textDark),
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Kode Admin (Opsional)',
                        prefixIcon: Icon(
                          Icons.admin_panel_settings_outlined,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => TextField(
                        controller: controller.passwordController,
                        style: TextStyle(color: AppColors.textDark),
                        obscureText: controller.isPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textMuted,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Obx(
                      () => TextField(
                        controller: controller.confirmPasswordController,
                        style: TextStyle(color: AppColors.textDark),
                        obscureText: controller.isConfirmPasswordHidden.value,
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: Icon(
                            Icons.lock_reset,
                            color: AppColors.textMuted,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.textMuted,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Button
                    Obx(
                      () => ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () => controller.register(),
                        child: controller.isLoading.value
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: AppColors.textLight,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Daftar',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    SizedBox(height: 24),

                    // Go to Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Sudah punya akun? ',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                        GestureDetector(
                          onTap: () => Get.back(),
                          child: Text(
                            'Masuk',
                            style: TextStyle(
                              color: AppColors.indigo,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
