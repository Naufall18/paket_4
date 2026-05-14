import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/snackbar_helper.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:paket44/presentation/shared/widgets/app_text_field.dart';

/// Admin dashboard dialogs: register student, fine settings.
class DashboardDialogs {
  // ── Register Student (quick action) ──
  static void showRegisterStudent(AdminDashboardController controller) {
    final nameC = TextEditingController();
    final usernameC = TextEditingController();
    final emailC = TextEditingController();
    final passwordC = TextEditingController();
    final nisC = TextEditingController();
    final selectedKelas = ''.obs;

    final kelasList = [
      'X RPL', 'X TKJ', 'X MM', 'X AKL', 'X OTKP', 'X BDP',
      'XI RPL', 'XI TKJ', 'XI MM', 'XI AKL', 'XI OTKP', 'XI BDP',
      'XII RPL', 'XII TKJ', 'XII MM', 'XII AKL', 'XII OTKP', 'XII BDP',
    ];

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add_alt,
                        color: Color(0xFF3B82F6)),
                  ),
                  const SizedBox(width: 12),
                  Text('Daftarkan Siswa',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 20),
              AppTextField(
                  label: 'Nama Lengkap',
                  controller: nameC,
                  icon: Icons.badge_outlined),
              const SizedBox(height: 10),
              AppTextField(
                  label: 'Username',
                  controller: usernameC,
                  icon: Icons.person_outline),
              const SizedBox(height: 10),
              AppTextField(
                  label: 'Email',
                  controller: emailC,
                  icon: Icons.email_outlined),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: AppTextField(
                        label: 'NIS',
                        controller: nisC,
                        icon: Icons.pin_outlined,
                        isNumber: true),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => DropdownButtonFormField<String>(
                        value: selectedKelas.value.isEmpty
                            ? null
                            : selectedKelas.value,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down,
                            color: AppColors.textMuted),
                        decoration: InputDecoration(
                          labelText: 'Kelas',
                          labelStyle: TextStyle(
                              fontSize: 13, color: AppColors.textMuted),
                          prefixIcon: Icon(Icons.class_,
                              size: 18, color: AppColors.textMuted),
                          filled: true,
                          fillColor: AppColors.cardLight,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide:
                                BorderSide(color: AppColors.indigo),
                          ),
                        ),
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textDark),
                        items: kelasList
                            .map((k) => DropdownMenuItem(
                                value: k,
                                child: Text(k,
                                    style: const TextStyle(fontSize: 13))))
                            .toList(),
                        onChanged: (val) =>
                            selectedKelas.value = val ?? '',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              AppTextField(
                  label: 'Password',
                  controller: passwordC,
                  icon: Icons.lock_outline,
                  isPassword: true),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: AppColors.border, width: 1.5),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameC.text.isEmpty ||
                            usernameC.text.isEmpty ||
                            passwordC.text.isEmpty) {
                          SnackbarHelper.showError(
                            'Validasi',
                            'Nama, Username, dan Password wajib diisi',
                          );
                          return;
                        }
                        controller.registerStudent(
                          nameC.text,
                          usernameC.text,
                          emailC.text,
                          passwordC.text,
                          nisC.text,
                          selectedKelas.value,
                        );
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Daftar',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Fine Settings ──
  static void showFineSettings(AdminDashboardController controller) {
    final controllers = <String, TextEditingController>{};
    for (var s in controller.settings) {
      controllers[s['key']] =
          TextEditingController(text: s['value'].toString());
    }

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings_suggest_outlined,
                        color: Color(0xFFF59E0B)),
                  ),
                  const SizedBox(width: 12),
                  Text('Pengaturan Denda',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Atur besaran denda untuk keterlambatan dan kerusakan buku.',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
              const SizedBox(height: 20),
              Obx(() {
                if (controller.isLoadingSettings.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.settings.isEmpty) {
                  return Center(
                      child: Text('Tidak ada data pengaturan',
                          style: TextStyle(color: AppColors.textMuted)));
                }
                return Column(
                  children: controller.settings.map((s) {
                    final key = s['key'];
                    if (!controllers.containsKey(key)) {
                      controllers[key] = TextEditingController(
                          text: s['value'].toString());
                    }
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: AppTextField(
                        label: s['label'] ?? key,
                        controller: controllers[key]!,
                        icon: Icons.payments_outlined,
                        isNumber: true,
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        side: BorderSide(
                            color: AppColors.border, width: 1.5),
                      ),
                      child: Text('Batal',
                          style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final updated = controller.settings.map((s) {
                          return {
                            'key': s['key'],
                            'value':
                                controllers[s['key']]?.text ?? s['value'],
                          };
                        }).toList();
                        controller.updateSettings(updated);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF59E0B),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Simpan',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
