import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';

/// All transaction action dialogs: approve, reject, return, delete, pay fine.
class TransactionActions {
  // ── Delete ──
  static void showDeleteConfirmation(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error),
            const SizedBox(width: 8),
            const Text('Hapus Transaksi',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        content: Text(
            'Apakah Anda yakin ingin menghapus riwayat transaksi peminjaman buku "${trx.book?.judul}" oleh ${trx.user?.name}? Data yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child:
                Text('Batal', style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.deleteTransaction(trx.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Return with condition ──
  static void showReturnConfirmation(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
    // Map of itemId to conditions
    final itemConditions = <int, RxString>{}.obs;
    final itemNotes = <int, TextEditingController>{};
    final itemDendas = <int, TextEditingController>{};

    for (var item in trx.items) {
      final id = item.id;
      itemConditions[id] = 'baik'.obs;
      itemNotes[id] = TextEditingController();
      itemDendas[id] = TextEditingController(text: '0');

      // Auto-set denda based on condition for each item
      ever(itemConditions[id]!, (String kondisi) {
        switch (kondisi) {
          case 'rusak_ringan':
            itemDendas[id]?.text = '10000';
            break;
          case 'rusak_berat':
            itemDendas[id]?.text = '25000';
            break;
          case 'hilang':
            itemDendas[id]?.text = '50000';
            break;
          default:
            itemDendas[id]?.text = '0';
        }
      });
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.indigo.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.assignment_return_outlined,
                        color: AppColors.indigo, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Proses Pengembalian',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih kondisi setiap buku yang dikembalikan.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: trx.items.length,
                itemBuilder: (context, index) {
                  final item = trx.items[index];
                  final id = item.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 36,
                                height: 50,
                                color: Colors.grey.withOpacity(0.1),
                                child: coverFromUrl(item.book?.coverUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.book?.judul ?? 'Buku',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Kondisi:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Obx(() => Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildCompactConditionChip(itemConditions[id]!, 'baik', 'Baik', AppColors.success),
                            _buildCompactConditionChip(itemConditions[id]!, 'rusak_ringan', 'Rusak Ringan', Colors.orange),
                            _buildCompactConditionChip(itemConditions[id]!, 'rusak_berat', 'Rusak Berat', Colors.deepOrange),
                            _buildCompactConditionChip(itemConditions[id]!, 'hilang', 'Hilang', AppColors.error),
                          ],
                        )),
                        Obx(() {
                          if (itemConditions[id]?.value == 'baik') return const SizedBox.shrink();
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 12),
                              TextField(
                                controller: itemNotes[id],
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  hintText: 'Catatan kerusakan...',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: itemDendas[id],
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  prefixText: 'Denda: Rp ',
                                  isDense: true,
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final itemsList = <Map<String, dynamic>>[];
                        itemConditions.forEach((id, cond) {
                          itemsList.add({
                            'id': id,
                            'kondisi_buku': cond.value,
                            'catatan_kondisi': itemNotes[id]?.text,
                            'denda_kerusakan': int.tryParse(itemDendas[id]?.text ?? '0') ?? 0,
                          });
                        });

                        Get.back();
                        controller.returnBookWithCondition(
                          trx.id,
                          items: itemsList,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Proses', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Approve ──
  static void showApproveConfirmation(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
    // Map of itemId to conditions
    final itemConditions = <int, RxString>{}.obs;
    final itemNotes = <int, TextEditingController>{};

    for (var item in trx.items) {
      itemConditions[item.id] = 'baik'.obs;
      itemNotes[item.id] = TextEditingController();
    }

    Get.dialog(
      Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.thumb_up_alt_outlined,
                        color: AppColors.success, size: 32),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Setujui Peminjaman',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih kondisi setiap buku sebelum diserahkan.',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: trx.items.length,
                itemBuilder: (context, index) {
                  final item = trx.items[index];
                  final itemId = item.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? Colors.white.withOpacity(0.03) : Colors.grey.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 36,
                                height: 50,
                                color: Colors.grey.withOpacity(0.1),
                                child: coverFromUrl(item.book?.coverUrl, fit: BoxFit.cover),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item.book?.judul ?? 'Buku',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text('Kondisi Buku:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Obx(() => Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            _buildCompactConditionChip(itemConditions[itemId]!, 'baik', 'Baik', AppColors.success),
                            _buildCompactConditionChip(itemConditions[itemId]!, 'rusak_ringan', 'Rusak Ringan', Colors.orange),
                            _buildCompactConditionChip(itemConditions[itemId]!, 'rusak_berat', 'Rusak Berat', Colors.deepOrange),
                            _buildCompactConditionChip(itemConditions[itemId]!, 'hilang', 'Hilang', AppColors.error),
                          ],
                        )),
                        const SizedBox(height: 12),
                        Obx(() {
                          if (itemConditions[itemId]?.value == 'baik') return const SizedBox.shrink();
                          return TextField(
                            controller: itemNotes[itemId],
                            style: const TextStyle(fontSize: 13),
                            decoration: InputDecoration(
                              hintText: 'Tambahkan catatan...',
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Batal', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Prepare items list for backend
                        final itemsList = <Map<String, dynamic>>[];
                        itemConditions.forEach((id, cond) {
                          itemsList.add({
                            'id': id,
                            'kondisi_buku': cond.value,
                            'catatan_kondisi': itemNotes[id]?.text,
                          });
                        });

                        Get.back();
                        controller.approveBorrowing(
                          trx.id,
                          items: itemsList,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Setujui', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCompactConditionChip(RxString selected, String value, String label, Color color) {
    return Obx(() {
      final isSelected = selected.value == value;
      return GestureDetector(
        onTap: () => selected.value = value,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isSelected ? color : color.withOpacity(0.2)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.white : color,
            ),
          ),
        ),
      );
    });
  }

  // ── Reject ──
  static void showRejectConfirmation(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
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
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.cancel_outlined,
                    color: AppColors.error, size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Tolak Peminjaman',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin menolak permohonan peminjaman ini?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        side:
                            BorderSide(color: AppColors.border, width: 1.5),
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
                        controller.rejectBorrowing(trx.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Tolak',
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

  // ── Pay Fine ──
  static void showPayFineConfirmation(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Pembayaran'),
        content:
            Text('Tandai denda sebesar Rp ${trx.denda} sebagai Lunas?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.payFine(trx.id);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo),
            child: const Text('Lunas',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Shared: Condition option widget ──
  static Widget _buildConditionOption(RxString selected, String value,
      String label, IconData icon, Color color) {
    final isSelected = selected.value == value;
    return InkWell(
      onTap: () => selected.value = value,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected ? color.withOpacity(0.08) : Colors.transparent,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : AppColors.textDark,
                fontSize: 14,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(Icons.radio_button_checked, color: color, size: 20)
            else
              Icon(Icons.radio_button_off,
                  color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
