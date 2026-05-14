import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import '../../../../../../data/models/anggota_model.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:paket44/presentation/shared/widgets/app_text_field.dart';

/// Add / Edit anggota dialog.
class AnggotaFormDialog {
  static void show(AnggotaModel? anggota, AdminDashboardController controller) {
    final isEdit = anggota != null;
    final nameC = TextEditingController(text: isEdit ? anggota.name : '');
    final usernameC =
        TextEditingController(text: isEdit ? anggota.username : '');
    final emailC = TextEditingController(text: isEdit ? anggota.email : '');
    final passwordC = TextEditingController();
    final nisC = TextEditingController(text: isEdit ? anggota.nis : '');
    final hpC =
        TextEditingController(text: isEdit ? (anggota.noHp ?? '') : '');
    final selectedKelas = (isEdit ? anggota.kelas : '').obs;
    final statusAktif = (isEdit ? anggota.statusAktif : true).obs;

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
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit : Icons.person_add_alt,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Edit Anggota' : 'Tambah Anggota',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fields
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
                  icon: Icons.email_outlined,
                  isEmail: true),
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
                            : (kelasList.contains(selectedKelas.value)
                                ? selectedKelas.value
                                : null),
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
                          fillColor: AppColors.inputFill,
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
                  label: 'No. HP',
                  controller: hpC,
                  icon: Icons.phone_outlined,
                  isNumber: true),
              const SizedBox(height: 10),
              AppTextField(
                label: 'Password ${isEdit ? "(Opsional)" : ""}',
                controller: passwordC,
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              if (isEdit) ...[
                const SizedBox(height: 16),
                Obx(
                  () => SwitchListTile(
                    title: Text('Status Aktif',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark)),
                    subtitle: Text(
                      statusAktif.value
                          ? 'Akun dapat digunakan'
                          : 'Akun ditangguhkan',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                    ),
                    value: statusAktif.value,
                    activeColor: AppColors.success,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) => statusAktif.value = val,
                  ),
                ),
              ],

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
                            (!isEdit && passwordC.text.isEmpty)) {
                          Get.snackbar(
                            '⚠️ Validasi',
                            'Nama, Username, dan Password wajib diisi',
                            backgroundColor: const Color(0xFFFEF3C7),
                            colorText: const Color(0xFF92400E),
                            snackPosition: SnackPosition.TOP,
                            margin: const EdgeInsets.all(16),
                            borderRadius: 12,
                            icon: const Icon(Icons.warning_amber,
                                color: Color(0xFF92400E)),
                          );
                          return;
                        }
                        if (isEdit) {
                          final data = <String, dynamic>{
                            'name': nameC.text,
                            'username': usernameC.text,
                            'email': emailC.text,
                            'nis': nisC.text,
                            'kelas': selectedKelas.value,
                            'no_hp': hpC.text,
                            'status_aktif': statusAktif.value,
                          };
                          if (passwordC.text.isNotEmpty) {
                            data['password'] = passwordC.text;
                          }
                          controller.updateAnggota(anggota.id, data);
                        } else {
                          controller.registerStudent(
                            nameC.text,
                            usernameC.text,
                            emailC.text,
                            passwordC.text,
                            nisC.text,
                            selectedKelas.value,
                          );
                        }
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isEdit ? 'Simpan' : 'Tambah',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600),
                      ),
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
