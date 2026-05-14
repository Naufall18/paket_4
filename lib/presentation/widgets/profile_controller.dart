import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../../data/models/user_model.dart';
import '../../../data/services/api_service.dart';
import '../../../data/services/storage_service.dart';
import '../../../data/providers/auth_provider.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/theme/app_colors.dart';

class ProfileController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final AuthProvider _authProvider = AuthProvider();
  final ImagePicker _picker = ImagePicker();

  final isLoading = true.obs;
  final isSaving = false.obs;
  final user = Rx<UserModel?>(null);
  final isPasswordVisible = false.obs;

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Form controllers
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final noHpController = TextEditingController();
  final passwordController = TextEditingController();

  final selectedImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    try {
      final token = _storageService.getToken();
      if (token == null) return;

      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/me'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        user.value = UserModel.fromJson(data['data']);

        nameController.text = user.value?.name ?? '';
        usernameController.text = user.value?.username ?? '';
        emailController.text = user.value?.email ?? '';
        noHpController.text = user.value?.noHp ?? '';

        // Update storage service if needed
        if (user.value?.name != null && user.value?.role != null) {
          _storageService.saveUserData(
            user.value!.name!,
            user.value!.role!,
            fotoProfilUrl: user.value!.fotoProfilUrl,
          );
        }
      }
    } catch (e) {
      SnackbarHelper.showError('❌ Error', 'Gagal memuat profil');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  Future<void> saveProfile() async {
    if (nameController.text.isEmpty ||
        usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        noHpController.text.isEmpty) {
      SnackbarHelper.showError(
        '⚠️ Validasi',
        'Nama, Username, Email, dan No. HP tidak boleh kosong',
      );
      return;
    }

    if (passwordController.text.isNotEmpty) {
      isSaving.value = true;
      final token = _storageService.getToken();

      if (token == null) {
        isSaving.value = false;
        return;
      }

      final response = await _authProvider.sendOtp(token, noHpController.text);
      isSaving.value = false;

      if (response['success'] == true) {
        SnackbarHelper.showSuccess(
          '✅ OTP Terkirim',
          response['message'] ?? 'Periksa SMS/WhatsApp Anda',
        );
        _showVerificationDialog(token);
      } else {
        SnackbarHelper.showError(
          '❌ Gagal Kirim OTP',
          response['message'] ?? 'Gagal mengirim OTP ke email Anda',
        );
      }
    } else {
      _executeSaveProfile();
    }
  }

  void _showVerificationDialog(String token) {
    final otpController = TextEditingController();
    bool isError = false;
    bool isVerifying = false;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.security,
                      color: Color(0xFF3B82F6),
                      size: 36,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Verifikasi Keamanan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Masukkan 6 digit kode OTP yang telah dikirim ke nomor ${noHpController.text}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 24),
                  TextField(
                    controller: otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: '000000',
                      hintStyle: TextStyle(
                        color: AppColors.border,
                        letterSpacing: 8,
                      ),
                      filled: true,
                      fillColor: AppColors.cardLight,
                      errorText: isError
                          ? 'Kode OTP salah atau kedaluwarsa'
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF3B82F6),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: (val) {
                      if (isError) setState(() => isError = false);
                    },
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
                            side: BorderSide(color: AppColors.border),
                          ),
                          child: Text(
                            'Batal',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isVerifying
                              ? null
                              : () async {
                                  if (otpController.text.length == 6) {
                                    setState(() {
                                      isVerifying = true;
                                      isError = false;
                                    });
                                    final response = await _authProvider
                                        .verifyOtp(
                                          token,
                                          noHpController.text,
                                          otpController.text,
                                        );
                                    setState(() {
                                      isVerifying = false;
                                    });

                                    if (response['success'] == true) {
                                      Get.back();
                                      _executeSaveProfile();
                                    } else {
                                      setState(() => isError = true);
                                    }
                                  } else {
                                    setState(() => isError = true);
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B82F6),
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isVerifying
                              ? SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Verifikasi',
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
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _executeSaveProfile() async {
    isSaving.value = true;
    final token = _storageService.getToken();

    if (token == null) {
      isSaving.value = false;
      return;
    }

    final response = await _authProvider.updateProfile(
      token,
      nameController.text,
      usernameController.text,
      emailController.text,
      noHpController.text,
      passwordController.text,
      selectedImagePath.value,
    );

    if (response['success'] == true) {
      final msg = passwordController.text.isNotEmpty
          ? 'Password berhasil diubah'
          : (response['message'] ?? 'Profil berhasil diperbarui');
      SnackbarHelper.showSuccess('Berhasil!', msg);
      passwordController.clear();
      selectedImagePath.value = '';
      await fetchProfile(); // Reload data
    } else {
      SnackbarHelper.showError(
        'Gagal',
        response['message'] ?? 'Terjadi kesalahan saat menyimpan',
      );
    }

    isSaving.value = false;
  }

  void logout() async {
    await _storageService.clearToken();
    Get.offAllNamed('/login');
    SnackbarHelper.showSuccess(
      'Berhasil Keluar',
      'Sesi Anda telah berakhir, sampai jumpa!',
    );
  }
}
