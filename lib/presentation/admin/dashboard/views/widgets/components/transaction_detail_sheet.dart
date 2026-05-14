import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'package:paket44/presentation/shared/widgets/detail_info_row.dart';
import 'transaction_actions.dart';

/// Bottom sheet showing full transaction details.
class TransactionDetailSheet {
  static void show(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        return Container(
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
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Book items list
                _buildBookItemsList(trx),
                const SizedBox(height: 6),

                // Borrower info + delete button
                _buildBorrowerInfo(sheetCtx, context, trx, controller),
                const SizedBox(height: 20),

                Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
                const SizedBox(height: 16),

                Text(
                  'Detail Transaksi',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),

                // Transaction details
                _buildTransactionDetails(trx),

                // Pay fine button
                if (trx.denda > 0 &&
                    trx.statusBayarDenda == 'belum_bayar') ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetCtx);
                        TransactionActions.showPayFineConfirmation(
                            context, trx, controller);
                      },
                      icon: const Icon(Icons.payments_outlined,
                          color: Colors.white),
                      label: const Text('Tandai Denda Lunas',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Action buttons
                _buildActionButtons(sheetCtx, context, trx, controller),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _buildBookItemsList(dynamic trx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: trx.items.map<Widget>((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 50,
                  height: 70,
                  color: AppColors.darkSlate.withOpacity(0.1),
                  child: coverFromUrl(
                    item.book?.coverUrl,
                    fit: BoxFit.cover,
                    context: 'Transaction detail',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.book?.judul ?? 'Judul Buku',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                        height: 1.1,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jumlah: ${item.quantity} • Durasi: ${item.durasiHari} Hari',
                          style: TextStyle(
                              fontSize: 11, color: AppColors.textMuted),
                        ),
                        if (item.status != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(item.status!)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _translateStatus(item.status!),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(item.status!),
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Kondisi hanya muncul setelah buku diserahkan fisik
                    if (item.kondisiBuku != null &&
                        item.kondisiBuku!.isNotEmpty &&
                        item.kondisiBuku != 'baik' &&
                        (item.status == 'dipinjam' ||
                            item.status == 'dikembalikan' ||
                            item.status == 'terlambat'))
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getKondisiColor(item.kondisiBuku!)
                                    .withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Kondisi: ${_translateKondisi(item.kondisiBuku!)}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _getKondisiColor(item.kondisiBuku!),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (item.catatanKondisi != null &&
                                item.catatanKondisi!.isNotEmpty)
                              Flexible(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: Text(
                                    '(${item.catatanKondisi})',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  static Widget _buildBorrowerInfo(BuildContext sheetCtx,
      BuildContext context, dynamic trx, AdminDashboardController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DetailIconRow(
                  icon: Icons.person_outline,
                  label: 'Peminjam',
                  value: trx.user?.name),
              const SizedBox(height: 4),
              DetailIconRow(
                  icon: Icons.badge_outlined,
                  label: 'NIS',
                  value: trx.user?.nis),
              const SizedBox(height: 4),
              DetailIconRow(
                  icon: Icons.class_outlined,
                  label: 'Kelas',
                  value: trx.user?.kelas),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline, color: AppColors.error),
          onPressed: () {
            Navigator.pop(sheetCtx);
            TransactionActions.showDeleteConfirmation(
                context, trx, controller);
          },
          tooltip: 'Hapus Transaksi',
        ),
      ],
    );
  }

  static Widget _buildTransactionDetails(dynamic trx) {
    return Column(
      children: [
        DetailInfoRow(
            label: 'Status Peminjaman',
            value: trx.displayStatus,
            isStatus: true),
        const SizedBox(height: 8),
        DetailInfoRow(label: 'Tanggal Pinjam', value: trx.tanggalPinjam),
        const SizedBox(height: 8),
        if (trx.status.toLowerCase() == 'dikembalikan' &&
            trx.tanggalKembaliAktual != null) ...[
          DetailInfoRow(
              label: 'Tanggal Kembali', value: trx.tanggalKembaliAktual!),
        ] else ...[
          DetailInfoRow(
              label: 'Batas Kembali',
              value: trx.tanggalKembali ?? 'Belum diatur'),
        ],
        if (trx.kondisiBuku != 'baik') ...[
          const SizedBox(height: 8),
          DetailInfoRow(label: 'Kondisi Buku', value: trx.displayKondisi),
          if (trx.catatanKondisi != null && trx.catatanKondisi!.isNotEmpty)
            DetailInfoRow(label: 'Catatan', value: trx.catatanKondisi!),
        ],
        if (trx.denda > 0) ...[
          const SizedBox(height: 8),
          DetailInfoRow(
              label: 'Total Denda',
              value: 'Rp ${trx.denda}',
              isError: true),
          DetailInfoRow(
            label: 'Status Bayar',
            value:
                trx.statusBayarDenda == 'lunas' ? 'Lunas' : 'Belum Bayar',
            isStatus: true,
          ),
          // Alasan Denda ditampilkan bawah kondisi buku agar tidak overflow
          _buildAlasanDenda(trx.fineReason),
        ],
      ],
    );
  }

  /// Menampilkan alasan denda dalam format kolom (label di atas, nilai di bawah)
  /// agar teks panjang tidak overflow ke kanan layar.
  static Widget _buildAlasanDenda(String reason) {
    if (reason.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alasan Denda',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.07),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              reason,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionButtons(BuildContext sheetCtx,
      BuildContext context, dynamic trx, AdminDashboardController controller) {
    return Row(
      children: [
        if (trx.statusApproval == 'pending') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.pop(sheetCtx);
                TransactionActions.showRejectConfirmation(
                    context, trx, controller);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                    color: AppColors.error.withOpacity(0.5), width: 1.5),
              ),
              child: Text('Tolak',
                  style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetCtx);
                TransactionActions.showApproveConfirmation(
                    context, trx, controller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Setujui',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ] else if (trx.statusApproval == 'approved' && (trx.status == 'pending' || trx.status == 'approved')) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(sheetCtx);
                controller.confirmPickup(trx.id);
              },
              icon: const Icon(Icons.verified_user_outlined, color: Colors.white),
              label: const Text('Konfirmasi Pengambilan',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else if (trx.status.toLowerCase() == 'diambil' ||
                (trx.statusApproval == 'approved' && trx.status.toLowerCase() == 'diambil')) ...[
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pop(sheetCtx),
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Buku Siap Diambil',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ] else if (trx.status.toLowerCase() == 'dipinjam') ...[
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(sheetCtx),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(
                    color: Colors.grey.shade300, width: 1.5),
              ),
              child: Text('Tutup',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetCtx);
                TransactionActions.showReturnConfirmation(
                    context, trx, controller);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Tandai Selesai',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ] else ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(sheetCtx),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text('Tutup',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ],
    );
  }

  static String _translateKondisi(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return 'Baik';
      case 'rusak_ringan':
        return 'Rusak Ringan';
      case 'rusak_berat':
        return 'Rusak Berat';
      case 'hilang':
        return 'Hilang';
      default:
        return kondisi;
    }
  }

  static Color _getKondisiColor(String kondisi) {
    switch (kondisi) {
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

  static String _translateStatus(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return 'Dipinjam';
      case 'dikembalikan':
        return 'Selesai';
      case 'terlambat':
        return 'Terlambat';
      case 'pending':
        return 'Menunggu';
      case 'approved':
        return 'Disetujui';
      case 'diambil':
        return 'Diambil';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  static Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipinjam':
        return Colors.blue;
      case 'dikembalikan':
        return AppColors.success;
      case 'terlambat':
        return AppColors.error;
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.indigo;
      case 'diambil':
        return Colors.teal;
      case 'rejected':
        return AppColors.error;
      default:
        return AppColors.textMuted;
    }
  }
}
