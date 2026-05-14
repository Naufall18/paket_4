import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../../data/providers/auth_provider.dart';
import '../../../../data/services/storage_service.dart';
import '../../../../data/services/api_service.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/utils/snackbar_helper.dart';
import '../../../../core/theme/app_colors.dart';

class LoginController extends GetxController {
  final AuthProvider _authProvider = AuthProvider();
  final StorageService _storageService = Get.find<StorageService>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordHidden = true.obs;

  void togglePasswordVisibility() => isPasswordHidden.toggle();

  Future<void> login() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      SnackbarHelper.showError(
        'Error',
        'Username dan password tidak boleh kosong',
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authProvider.login(
        usernameController.text,
        passwordController.text,
      );

      // Simple handling based on general Sanctum/Laravel response structure
      if (response['success'] == true && response.containsKey('data')) {
        final token = response['data']['access_token'];
        if (token != null) {
          await _storageService.saveToken(token);
          final user = response['data']['user'];
          if (user != null) {
            String? photoUrl;
            if (user['foto_profil_url'] != null &&
                user['foto_profil_url'].toString().isNotEmpty) {
              final raw = user['foto_profil_url'].toString();
              if (raw.startsWith('http') || raw.startsWith('assets/')) {
                photoUrl = raw;
              } else {
                photoUrl =
                    '${ApiService.storageUrl}/${raw.replaceFirst('http://localhost:8000/storage/', '')}';
              }
            } else if (user['foto_profil'] != null &&
                user['foto_profil'].toString().isNotEmpty) {
              photoUrl = '${ApiService.storageUrl}/${user['foto_profil']}';
            }
            await _storageService.saveUserData(
              user['name'] ?? '',
              user['role'] ?? '',
              fotoProfilUrl: photoUrl,
            );
          }
        }

        // Decide routing based on role if available, otherwise default to Student/Admin logic
        final role = response['data']['user']?['role'];
        if (role == 'admin') {
          Get.offAllNamed(Routes.ADMIN_DASHBOARD);
        } else {
          Get.offAllNamed(
            Routes.STUDENT_DASHBOARD,
          ); // Defaulting to student for now
        }
      } else {
        if (response['message'] == 'Akun Anda tidak aktif' || 
            response['message'] == 'Akun Anda dinonaktifkan. Silakan hubungi admin.') {
           showSupportDialog(usernameController.text);
        } else {
          SnackbarHelper.showError(
            'Login Gagal',
            response['message'] ?? 'Periksa kembali kredensial Anda',
          );
        }
      }
    } catch (e) {
      SnackbarHelper.showError('Error', 'Terjadi kesalahan sistem: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showSupportDialog(String initialUsername) {
    final supportMsgController = TextEditingController();
    final usernameInputController = TextEditingController(text: initialUsername);
    final isSubmitting = false.obs;

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Akun Dinonaktifkan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.error,
              ),
            ),
            SizedBox(height: 8),
            Text(
              initialUsername.isNotEmpty
                  ? 'Akun $initialUsername saat ini dinonaktifkan oleh admin. Anda dapat mengirimkan pesan permintaan ke admin untuk mengaktifkannya kembali.'
                  : 'Silakan masukkan Username atau NISN Anda beserta pesan permohonan untuk diaktifkan kembali oleh admin.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(height: 16),
            if (initialUsername.isEmpty) ...[
              TextField(
                controller: usernameInputController,
                style: TextStyle(color: AppColors.textDark, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Username atau NISN Anda',
                  hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.indigo, width: 1.5),
                  ),
                  fillColor: AppColors.background,
                  filled: true,
                ),
              ),
              SizedBox(height: 12),
            ],
            TextField(
              controller: supportMsgController,
              maxLines: 3,
              style: TextStyle(color: AppColors.textDark, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Tulis pesan permohonan Anda (misal: Mohon aktifkan kembali akun saya...)',
                hintStyle: TextStyle(color: AppColors.textMuted.withOpacity(0.5)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.indigo, width: 1.5),
                ),
                fillColor: AppColors.background,
                filled: true,
              ),
            ),
            SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Batal',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Obx(() => ElevatedButton(
                    onPressed: isSubmitting.value ? null : () async {
                      if (usernameInputController.text.isEmpty) {
                         SnackbarHelper.showError('Error', 'Username atau NISN tidak boleh kosong');
                         return;
                      }
                      if (supportMsgController.text.isEmpty) {
                         SnackbarHelper.showError('Error', 'Pesan tidak boleh kosong');
                         return;
                      }
                      isSubmitting.value = true;
                      try {
                        final res = await _authProvider.submitSupportRequest(usernameInputController.text, supportMsgController.text);
                        Get.back(); // close sheet
                        if (res['success'] == true) {
                           SnackbarHelper.showSuccess('Berhasil', 'Pesan permintaan telah dikirim ke admin.');
                        } else {
                           SnackbarHelper.showError('Gagal', res['message'] ?? 'Gagal mengirim pesan');
                        }
                      } catch (e) {
                        SnackbarHelper.showError('Error', 'Gagal memproses permintaan');
                      } finally {
                        isSubmitting.value = false;
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo,
                      padding: EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSubmitting.value 
                        ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : Text('Kirim Pesan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void showForgotPasswordDialog() {
    final phoneController = TextEditingController();
    final otpController = TextEditingController();
    final newPasswordController = TextEditingController();
    
    final confirmPasswordController = TextEditingController();

    final step = 1.obs; // 1: phone, 2: otp, 3: new password
    final isProcessing = false.obs;
    final phoneNum = ''.obs;

    Get.bottomSheet(
      Obx(() => Container(
        padding: EdgeInsets.only(
          left: 24, 
          right: 24, 
          top: 24, 
          bottom: MediaQuery.of(Get.context!).viewInsets.bottom + 24
        ),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lupa Password',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark),
            ),
            SizedBox(height: 8),
            Text(
              step.value == 1 
                ? 'Masukkan nomor WhatsApp yang terdaftar untuk menerima kode OTP.' 
                : step.value == 2 
                  ? 'Masukkan 6 digit kode OTP yang dikirim ke WhatsApp Anda.'
                  : 'Buat password baru untuk akun Anda.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            ),
            SizedBox(height: 20),
            
            if (step.value == 1) ...[
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                style: TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Nomor WhatsApp (Ex: 08xxx/628xxx)',
                  prefixIcon: Icon(Icons.phone, color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else if (step.value == 2) ...[
              TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: TextStyle(color: AppColors.textDark, letterSpacing: 4, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  labelText: 'Kode OTP',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ] else ...[
              Obx(() => TextField(
                controller: newPasswordController,
                keyboardType: TextInputType.text,
                obscureText: isPasswordHidden.value,
                style: TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  prefixIcon: Icon(Icons.lock, color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
              )),
              SizedBox(height: 12),
              Obx(() => TextField(
                controller: confirmPasswordController,
                keyboardType: TextInputType.text,
                obscureText: isPasswordHidden.value,
                style: TextStyle(color: AppColors.textDark),
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Password Baru',
                  prefixIcon: Icon(Icons.lock_reset, color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  suffixIcon: IconButton(
                    icon: Icon(isPasswordHidden.value ? Icons.visibility_off : Icons.visibility, color: AppColors.textMuted),
                    onPressed: togglePasswordVisibility,
                  ),
                ),
              )),
            ],

            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isProcessing.value ? null : () async {
                  isProcessing.value = true;
                  try {
                    if (step.value == 1) {
                      if (phoneController.text.isEmpty) {
                         SnackbarHelper.showError('Error', 'Nomor HP tidak boleh kosong');
                         return;
                      }
                      final res = await _authProvider.sendResetOtp(phoneController.text);
                      if (res['success'] == true) {
                         phoneNum.value = phoneController.text;
                         step.value = 2;
                         SnackbarHelper.showSuccess('Berhasil', 'OTP dikirim ke WhatsApp');
                      } else {
                         SnackbarHelper.showError('Gagal', res['message'] ?? 'Gagal mengirim OTP');
                      }
                    } else if (step.value == 2) {
                      if (otpController.text.length != 6) {
                         SnackbarHelper.showError('Error', 'OTP harus 6 digit');
                         return;
                      }
                      final res = await _authProvider.verifyResetOtp(phoneNum.value, otpController.text);
                      if (res['success'] == true) {
                         step.value = 3;
                         SnackbarHelper.showSuccess('Berhasil', 'OTP Valid. Silakan buat password baru.');
                      } else {
                         SnackbarHelper.showError('Gagal', res['message'] ?? 'OTP tidak valid');
                      }
                    } else if (step.value == 3) {
                      if (newPasswordController.text.length < 6) {
                         SnackbarHelper.showError('Error', 'Password minimal 6 karakter');
                         return;
                      }
                      if (newPasswordController.text != confirmPasswordController.text) {
                         SnackbarHelper.showError('Error', 'Konfirmasi password tidak cocok');
                         return;
                      }
                      final res = await _authProvider.resetPassword(phoneNum.value, otpController.text, newPasswordController.text);
                      if (res['success'] == true) {
                         Get.back();
                         SnackbarHelper.showSuccess('Berhasil', 'Password berhasil diubah. Silakan login.');
                      } else {
                         SnackbarHelper.showError('Gagal', res['message'] ?? 'Gagal mereset password');
                      }
                    }
                  } catch (e) {
                     SnackbarHelper.showError('Error', 'Terjadi kesalahan sistem');
                  } finally {
                     isProcessing.value = false;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.indigo,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: isProcessing.value 
                    ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        step.value == 1 ? 'Kirim OTP' : step.value == 2 ? 'Verifikasi OTP' : 'Simpan Password', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
              ),
            ),
          ],
        ),
      )),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
