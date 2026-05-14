import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';

class RegisterController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final StorageService _storageService = Get.find<StorageService>();

  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final nisController = TextEditingController();
  final kelasController = TextEditingController();
  final noHpController = TextEditingController();
  final adminCodeController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;

  void togglePasswordVisibility() => isPasswordHidden.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordHidden.toggle();

  Future<void> register() async {
    final isAdmin = adminCodeController.text.isNotEmpty;

    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty ||
        (!isAdmin &&
            (nisController.text.isEmpty || kelasController.text.isEmpty))) {
      SnackbarHelper.showError(
        'Error',
        isAdmin
            ? 'Semua kolom profil wajib diisi'
            : 'Semua kolom yang wajib harus diisi',
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      SnackbarHelper.showError('Error', 'Password tidak cocok');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.register(
        nameController.text,
        usernameController.text,
        emailController.text,
        passwordController.text,
        nisController.text,
        kelasController.text,
        noHp: noHpController.text.isEmpty ? null : noHpController.text,
        adminCode: adminCodeController.text.isEmpty
            ? null
            : adminCodeController.text,
      );

      if (response['success'] == true && response.containsKey('data')) {
        final token = response['data']['access_token'];
        if (token != null) {
          await _storageService.saveToken(token);
          final user = response['data']['user'];
          if (user != null) {
            await _storageService.saveUserData(
              user['name'] ?? '',
              user['role'] ?? 'siswa',
            );
          }
        }
        // Route based on role
        if (isAdmin) {
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        } else {
          Get.offAllNamed(Routes.STUDENT_DASHBOARD);
        }
      } else {
        SnackbarHelper.showError(
          'Registrasi Gagal',
          response['message'] ?? 'Silakan coba lagi',
        );
      }
    } catch (e) {
      SnackbarHelper.showError('Error', 'Terjadi kesalahan sistem: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nisController.dispose();
    kelasController.dispose();
    noHpController.dispose();
    super.onClose();
  }
}
