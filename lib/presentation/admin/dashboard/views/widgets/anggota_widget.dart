import 'package:flutter/material.dart';
import 'package:paket44/data/models/anggota_model.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'components/anggota_form_dialog.dart';
import 'components/anggota_card.dart';

/// Main anggota (member) list view for admin dashboard.
///
/// Detail sheet → [AnggotaDetailSheet] (`components/anggota_detail_sheet.dart`)
/// Form dialog → [AnggotaFormDialog] (`components/anggota_form_dialog.dart`)
class AnggotaWidget extends GetView<AdminDashboardController> {
  const AnggotaWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.indigo,
        onRefresh: () => controller.fetchAnggotas(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildFilters(),
              const SizedBox(height: 16),
              Expanded(child: _buildAnggotaList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Kelola Anggota',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        ElevatedButton.icon(
          onPressed: () => AnggotaFormDialog.show(null, controller),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.indigo,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.add, size: 18, color: Colors.white),
          label: const Text('Tambah',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13)),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
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
        onChanged: (val) => controller.fetchAnggotas(search: val),
        decoration: InputDecoration(
          hintText: 'Cari nama, NIS, kelas...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildFilterDropdown(
                label: 'Tingkat',
                value: controller.selectedAnggotaTingkat.value,
                items: controller.tingkatList,
                onChanged: (val) =>
                    controller.selectedAnggotaTingkat.value = val!,
              )),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() => _buildFilterDropdown(
                label: 'Jurusan',
                value: controller.selectedAnggotaJurusan.value,
                items: controller.jurusanList,
                onChanged: (val) =>
                    controller.selectedAnggotaJurusan.value = val!,
              )),
        ),
      ],
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : 'Semua',
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down,
              size: 20, color: AppColors.indigo),
          style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
          onChanged: onChanged,
          items: items
              .map((val) => DropdownMenuItem<String>(
                  value: val,
                  child: Text(val == 'Semua' ? '$label: Semua' : val)))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildAnggotaList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingAnggota.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }
      if (controller.anggotas.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_search_outlined,
                  size: 60, color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Tidak ada anggota ditemukan',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: controller.filteredAnggotas.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final anggota = controller.filteredAnggotas[index];
          return Column(
            children: [
              AnggotaCard(
                anggota: anggota,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          AnggotaFormDialog.show(anggota, controller),
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        side: BorderSide(
                            color: AppColors.indigo, width: 1.5),
                        foregroundColor: AppColors.indigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _showDeleteDialog(anggota),
                      icon: const Icon(Icons.delete_outline, size: 16),
                      label: const Text('Hapus',
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFDC2626),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  void _showDeleteDialog(AnggotaModel anggota) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                    color: Color(0xFFFFF1F2), shape: BoxShape.circle),
                child: const Icon(Icons.delete_forever,
                    color: Color(0xFFE11D48), size: 36),
              ),
              const SizedBox(height: 16),
              Text('Hapus Anggota',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                      fontFamily: 'Inter'),
                  children: [
                    const TextSpan(
                        text: 'Apakah Anda yakin ingin menghapus '),
                    TextSpan(
                        text: anggota.name,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark)),
                    const TextSpan(text: ' dari sistem?'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
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
                        Get.back();
                        controller.deleteAnggota(anggota.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE11D48),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Ya, Hapus',
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
