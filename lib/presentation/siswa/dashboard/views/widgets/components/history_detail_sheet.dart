import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/siswa/dashboard/controllers/student_dashboard_controller.dart';

/// History book detail bottom sheet and return confirmation.
class HistoryDetailSheet {
  static void showBookDetail(BuildContext context, dynamic trx) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        padding: EdgeInsets.fromLTRB(
            24, 20, 24, MediaQuery.of(sheetCtx).viewInsets.bottom + 24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Borrowed items list
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: trx.items.map<Widget>((item) {
                  final canReturn = (item.status?.toLowerCase() ?? trx.status.toLowerCase()) == 'dipinjam';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? Colors.white.withOpacity(0.03)
                            : Colors.grey.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.withOpacity(0.1)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  width: 50,
                                  height: 70,
                                  color: AppColors.darkSlate.withOpacity(0.1),
                                  child: coverFromUrl(
                                    item.book?.coverUrl,
                                    fit: BoxFit.cover,
                                    context: 'History detail item',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(item.book?.judul ?? 'Judul Buku',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textDark,
                                            height: 1.1)),
                                    const SizedBox(height: 4),
                                    Text(
                                        'Jumlah: ${item.quantity} • Durasi: ${item.durasiHari} Hari',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textMuted)),
                                    // Kondisi buku hanya ditampilkan setelah buku
                                    // benar2 sudah diserahkan (bukan saat masih pending/approved)
                                    if (item.kondisiBuku != null &&
                                        item.kondisiBuku != 'baik' &&
                                        (item.status == 'dipinjam' ||
                                            item.status == 'dikembalikan' ||
                                            item.status == 'terlambat'))
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: _getConditionColor(item.kondisiBuku).withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Kondisi: ${_formatCondition(item.kondisiBuku)}',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: _getConditionColor(item.kondisiBuku),
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (item.catatanKondisi != null && item.catatanKondisi!.isNotEmpty)
                                                Text(
                                                  'Catatan: ${item.catatanKondisi}',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: _getConditionColor(item.kondisiBuku).withOpacity(0.8),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          if (canReturn) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pop(sheetCtx);
                                  _showSimpleReturnConfirm(
                                    context,
                                    trx,
                                    item,
                                    Get.find<StudentDashboardController>(),
                                  );
                                },
                                icon: const Icon(Icons.assignment_return,
                                    size: 18, color: Colors.white),
                                label: const Text('Kembalikan Buku Ini',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.indigo,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              Divider(
                  height: 1, color: Colors.grey.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text('Detail Peminjaman',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 12),
              _buildInfoRow('Status', trx.displayStatus,
                  isStatus: true),
              _buildInfoRow('Tanggal Pinjam', trx.tanggalPinjam),
              if (trx.status.toLowerCase() == 'dikembalikan' &&
                  trx.tanggalKembaliAktual != null)
                _buildInfoRow(
                    'Tanggal Kembali', trx.tanggalKembaliAktual!)
              else
                _buildInfoRow('Batas Kembali',
                    trx.tanggalKembali ?? 'Belum diatur'),
              _buildInfoRow('Lokasi Rak',
                  trx.book?.lokasiRak ?? 'Tanya Petugas'),
              if (trx.kondisiBuku != 'baik') ...[
                _buildInfoRow('Kondisi Buku', trx.displayKondisi),
                if (trx.catatanKondisi != null &&
                    trx.catatanKondisi!.isNotEmpty)
                  _buildInfoRow('Catatan', trx.catatanKondisi!),
              ],
              if (trx.denda > 0) ...[
                _buildInfoRow('Denda', 'Rp ${trx.denda}',
                    isError: true),
                _buildInfoRow('Keterangan Denda', trx.fineReason,
                    isError: true),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  if (trx.statusApproval == 'approved' &&
                      trx.status.toLowerCase() == 'diambil') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          Get.find<StudentDashboardController>()
                              .studentConfirmPickup(trx.id);
                        },
                        icon: const Icon(Icons.done_all,
                            color: Colors.white),
                        label: const Text('Konfirmasi Pengambilan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ] else if (trx.status.toLowerCase() == 'dipinjam') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5),
                        ),
                        child: Text('Tutup',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ] else if (trx.status.toLowerCase() == 'pending' &&
                      trx.statusApproval != 'approved') ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          side: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1.5),
                        ),
                        child: Text('Tutup',
                            style: TextStyle(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.indigo,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Tutup',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static void _showSimpleReturnConfirm(
    BuildContext context,
    dynamic trx,
    dynamic item,
    StudentDashboardController controller,
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
                  color: AppColors.indigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.assignment_return_outlined,
                  color: AppColors.indigo,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Kembalikan Buku',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.book?.judul ?? 'Buku',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Text(
                'Apakah Anda yakin ingin mengembalikan buku ini?',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: AppColors.border, width: 1.5),
                      ),
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.returnTransactionItem(trx.id, item.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Kembalikan',
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
      ),
    );
  }

  static void showReturnConfirmation(
      BuildContext context, dynamic trx) {
    final ctrl = Get.find<StudentDashboardController>();
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.indigo.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.outbox_rounded,
                    color: AppColors.indigo, size: 36),
              ),
              const SizedBox(height: 16),
              Text('Kembalikan Buku',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin mengembalikan buku ini sekarang?',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
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
                        ctrl.returnBookSiswa(trx.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: const Text('Ya, Kembalikan',
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

  static Color _getConditionColor(String? kondisi) {
    switch (kondisi?.toLowerCase()) {
      case 'baik':
        return AppColors.success;
      case 'rusak_ringan':
        return Colors.orange;
      case 'rusak_berat':
        return Colors.deepOrange;
      case 'hilang':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }

  static String _formatCondition(String? kondisi) {
    switch (kondisi?.toLowerCase()) {
      case 'baik':
        return 'Baik';
      case 'rusak_ringan':
        return 'Rusak Ringan';
      case 'rusak_berat':
        return 'Rusak Berat';
      case 'hilang':
        return 'Hilang';
      default:
        return kondisi ?? '-';
    }
  }

  static Widget _buildInfoRow(String label, String value,
      {bool isStatus = false, bool isError = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: AppColors.textMuted)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isError
                  ? AppColors.error
                  : (isStatus
                      ? AppColors.indigo
                      : AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}
