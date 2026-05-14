import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:intl/intl.dart';
import '../../controllers/admin_dashboard_controller.dart';

/// Denda recap view showing all outstanding and paid fines.
class DendaRecapWidget extends GetView<AdminDashboardController> {
  const DendaRecapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.indigo,
        onRefresh: () => controller.fetchTransactions(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 16),
              _buildStats(),
              const SizedBox(height: 20),
              Expanded(child: _buildDendaList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rekap Denda',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text('Pantau denda yang belum dibayar dan yang sudah lunas',
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildStats() {
    return Obx(() {
      final totalFine = controller.totalFineAmount;
      final pendingFine = controller.pendingFineAmount;
      final lunasFine = controller.lunasFineAmount;

      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Denda',
              amount: 'Rp ${NumberFormat('#,###').format(totalFine)}',
              bgColor: AppColors.indigo.withOpacity(0.1),
              iconColor: AppColors.indigo,
              icon: Icons.receipt,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Belum Bayar',
              amount: 'Rp ${NumberFormat('#,###').format(pendingFine)}',
              bgColor: Colors.orange.withOpacity(0.1),
              iconColor: Colors.orange,
              icon: Icons.pending,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              title: 'Lunas',
              amount: 'Rp ${NumberFormat('#,###').format(lunasFine)}',
              bgColor: AppColors.success.withOpacity(0.1),
              iconColor: AppColors.success,
              icon: Icons.check_circle,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required String title,
    required String amount,
    required Color bgColor,
    required Color iconColor,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDendaList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTransactions.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }

      // Filter transactions with denda
      final withDenda = controller.filteredTransactions
          .where((trx) => trx.denda > 0)
          .toList();

      if (withDenda.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.done_all,
                  size: 60, color: AppColors.success.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Semua denda sudah dibayar!',
                  style:
                      TextStyle(color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: withDenda.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final trx = withDenda[index];
          final isPending = trx.statusBayarDenda == 'belum_bayar';

          return GestureDetector(
            onTap: () => _showDendaDetail(context, trx),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: isPending
                        ? Colors.orange.withOpacity(0.2)
                        : AppColors.success.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              trx.kodeTransaksi ?? 'TRX-${trx.id}',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              trx.user?.name ?? 'User',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.orange.withOpacity(0.1)
                              : AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPending ? 'Belum Bayar' : 'Lunas',
                          style: TextStyle(
                            fontSize: 11,
                            color: isPending ? Colors.orange : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Jumlah Denda',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                          Text(
                            'Rp ${NumberFormat('#,###').format(trx.denda)}',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                color: AppColors.textDark),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Batas Kembali',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted)),
                          Text(
                            trx.tanggalKembali ?? '-',
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showDendaDetail(BuildContext context, dynamic trx) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Detail Denda',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark)),
              const SizedBox(height: 16),
              _buildDetailRow('Kode Transaksi', trx.kodeTransaksi),
              _buildDetailRow('Peminjam', trx.user?.name ?? '-'),
              _buildDetailRow('NIS', trx.user?.nis ?? '-'),
              _buildDetailRow('Kelas', trx.user?.kelas ?? '-'),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 12),
              _buildDetailRow('Batas Kembali', trx.tanggalKembali ?? '-'),
              _buildDetailRow('Tanggal Kembali Aktual',
                  trx.tanggalKembaliAktual ?? 'Belum dikembalikan'),
              const SizedBox(height: 12),
              Divider(height: 1, color: Colors.grey.withOpacity(0.2)),
              const SizedBox(height: 12),
              _buildDetailRow('Total Denda',
                  'Rp ${NumberFormat('#,###').format(trx.denda)}',
                  isHighlight: true),
              _buildDetailRow('Status', trx.statusBayarDenda == 'lunas' ? 'Lunas' : 'Belum Bayar',
                  statusColor: trx.statusBayarDenda == 'lunas'
                      ? AppColors.success
                      : Colors.orange),
              const SizedBox(height: 16),
              if (trx.statusBayarDenda == 'belum_bayar')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.payFine(trx.id);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.indigo,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Tandai Lunas',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600)),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('Denda sudah dibayar',
                          style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: AppColors.border),
                  ),
                  child: Text('Tutup',
                      style: TextStyle(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isHighlight = false, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 13,
                  color: statusColor ?? (isHighlight ? AppColors.error : AppColors.textDark),
                  fontWeight: isHighlight || statusColor != null
                      ? FontWeight.w700
                      : FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
