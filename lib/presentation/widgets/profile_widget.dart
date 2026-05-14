import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/url_utils.dart';
import 'profile_controller.dart';
import '../../data/services/storage_service.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller natively so it's created when this widget is displayed
    final controller = Get.put(ProfileController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.indigo),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 10),
              // Profile Picture
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  GestureDetector(
                    onTap: () => _showZoomedImage(context, controller),
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surface,
                        border: Border.all(
                          color: AppColors.indigo.withOpacity(0.1),
                          width: 4,
                        ),
                        image: controller.selectedImagePath.value.isNotEmpty
                            ? DecorationImage(
                                image: FileImage(
                                  File(controller.selectedImagePath.value),
                                ),
                                fit: BoxFit.cover,
                              )
                            : (controller.user.value?.fotoProfilUrl != null &&
                                      controller
                                          .user
                                          .value!
                                          .fotoProfilUrl!
                                          .isNotEmpty
                                  ? DecorationImage(
                                      image: isLocalAsset(controller
                                              .user
                                              .value!
                                              .fotoProfilUrl)
                                          ? AssetImage(controller
                                              .user
                                              .value!
                                              .fotoProfilUrl!) as ImageProvider
                                          : NetworkImage(controller
                                                  .user
                                                  .value!
                                                  .fotoProfilUrl!)
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                      onError: (_, __) {},
                                    )
                                  : null),
                      ),
                      child:
                          (controller.selectedImagePath.value.isEmpty &&
                              (controller.user.value?.fotoProfilUrl == null ||
                                  controller
                                      .user
                                      .value!
                                      .fotoProfilUrl!
                                      .isEmpty ||
                                  (!isHttpImageUrl(
                                          controller.user.value?.fotoProfilUrl) &&
                                      !isLocalAsset(
                                          controller.user.value?.fotoProfilUrl))))
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: AppColors.textMuted,
                            )
                          : null,
                    ),
                  ),
                  GestureDetector(
                    onTap: controller.pickImage,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.indigo,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Role Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (controller.user.value?.role ?? 'User').toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Form fields
              _buildTextField(
                'Nama Lengkap',
                Icons.badge_outlined,
                controller.nameController,
              ),
              SizedBox(height: 16),
              _buildTextField(
                'Username',
                Icons.alternate_email,
                controller.usernameController,
              ),
              SizedBox(height: 16),
              _buildTextField(
                'Email',
                Icons.email_outlined,
                controller.emailController,
                isEmail: true,
              ),
              SizedBox(height: 16),
              _buildTextField(
                'No. Handphone (WhatsApp/SMS)',
                Icons.phone_android,
                controller.noHpController,
                isNumber: true,
              ),
              SizedBox(height: 16),
              Obx(() => _buildTextField(
                'Password Baru (Kosongkan jika tidak diubah)',
                Icons.lock_outline,
                controller.passwordController,
                isPassword: true,
                obscureText: !controller.isPasswordVisible.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.isPasswordVisible.value ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  onPressed: controller.togglePasswordVisibility,
                ),
              )),
              SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: controller.isSaving.value
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Simpan Perubahan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.cardLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.withOpacity(0.1)),
                ),
                child: Obx(() {
                  final currentTheme =
                      Get.find<StorageService>().themeMode.value;
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      'Tema Aplikasi',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                    subtitle: Text(
                      'Tema: $currentTheme',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    leading: Icon(
                      Icons.palette_outlined,
                      color: AppColors.indigo,
                      size: 28,
                    ),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: currentTheme,
                        dropdownColor: AppColors.cardLight,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.textMuted,
                        ),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.indigo,
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'system',
                            child: Text('Sistem (Otomatis)', style: TextStyle(color: AppColors.textDark)),
                          ),
                          DropdownMenuItem(
                            value: 'light',
                            child: Text('Cerah (Light)', style: TextStyle(color: AppColors.textDark)),
                          ),
                          DropdownMenuItem(
                            value: 'dark',
                            child: Text('Gelap (Dark)', style: TextStyle(color: AppColors.textDark)),
                          ),
                        ],
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            Get.find<StorageService>().saveThemeMode(newValue);
                            ThemeMode mode = ThemeMode.system;
                            if (newValue == 'light') mode = ThemeMode.light;
                            if (newValue == 'dark') mode = ThemeMode.dark;
                            Get.changeThemeMode(mode);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              Get.forceAppUpdate();
                            });
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 24),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              SizedBox(height: 24),

              // Logout Button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () => _showLogoutDialog(context, controller),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppColors.error),
                      SizedBox(width: 8),
                      Text(
                        'Keluar Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    TextEditingController textController, {
    bool isPassword = false,
    bool isEmail = false,
    bool isNumber = false,
    bool? obscureText,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: textController,
            obscureText: obscureText ?? isPassword,
            style: TextStyle(color: AppColors.textDark),
            keyboardType: isEmail
                ? TextInputType.emailAddress
                : (isNumber ? TextInputType.phone : TextInputType.text),
            decoration: InputDecoration(
              hintText: 'Masukkan $label',
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
              prefixIcon: Icon(icon, color: AppColors.textMuted, size: 20),
              suffixIcon: suffixIcon,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showZoomedImage(BuildContext context, ProfileController controller) {
    if (controller.selectedImagePath.value.isEmpty &&
        (controller.user.value?.fotoProfilUrl == null ||
            controller.user.value!.fotoProfilUrl!.isEmpty)) {
      return; // No image to zoom
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: Container(
                width: double.infinity,
                height: 400,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: controller.selectedImagePath.value.isNotEmpty
                      ? DecorationImage(
                          image: FileImage(
                            File(controller.selectedImagePath.value),
                          ),
                          fit: BoxFit.contain,
                        )
                      : (controller.user.value!.fotoProfilUrl != null &&
                          controller.user.value!.fotoProfilUrl!.isNotEmpty &&
                          (isHttpImageUrl(controller.user.value!.fotoProfilUrl) ||
                              isLocalAsset(controller.user.value!.fotoProfilUrl))
                          ? DecorationImage(
                              image: isLocalAsset(
                                      controller.user.value!.fotoProfilUrl)
                                  ? AssetImage(
                                      controller.user.value!.fotoProfilUrl!)
                                  : NetworkImage(
                                      controller.user.value!.fotoProfilUrl!),
                              fit: BoxFit.contain,
                            )
                          : null),
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, ProfileController controller) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.cardLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.logout, color: AppColors.error, size: 28),
            ),
            SizedBox(height: 16),
            Text(
              'Keluar dari Akun?',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Anda perlu login kembali untuk mengakses aplikasi.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.logout();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Ya, Keluar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
