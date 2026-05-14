import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/admin/dashboard/controllers/admin_dashboard_controller.dart';
import 'transaction_detail_sheet.dart';

class TransactionCard extends StatelessWidget {
  final dynamic trx;
  final dynamic controller; // AdminDashboardController

  const TransactionCard({
    super.key,
    required this.trx,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final isDipinjam = trx.statusApproval == 'pending' ||
        (trx.statusApproval == 'approved' && trx.status == 'dipinjam');

    return GestureDetector(
      onTap: () {
        debugPrint('tap transaction id=${trx.id}');
        TransactionDetailSheet.show(context, trx, controller);
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 55,
                height: 75,
                color: isDipinjam
                    ? Colors.orange.withOpacity(0.1)
                    : AppColors.success.withOpacity(0.1),
                child: coverFromUrl(
                  trx.primaryBookCoverUrl,
                  fit: BoxFit.cover,
                  context: 'Transaction book',
                ),
              ),
            ),
            const SizedBox(width: 14),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Code + status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          trx.kodeTransaksi ?? 'TRX-${trx.id}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDipinjam
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFD1FAE5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trx.statusBayarDenda == 'lunas'
                              ? 'Lunas'
                              : trx.displayStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: trx.statusBayarDenda == 'lunas'
                                ? const Color(0xFF065F46)
                                : isDipinjam
                                    ? const Color(0xFF92400E)
                                    : const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Borrower
                  Text(
                    'Peminjam: ${trx.user?.name ?? 'Siswa'}',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 6),
                  // Items Status List
                  ...trx.items.map<Widget>((item) {
                    final itemStatus = item.status?.toLowerCase() ?? 'dipinjam';
                    final isItemDone = itemStatus == 'dikembalikan' || itemStatus == 'terlambat';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          Icon(
                            isItemDone ? Icons.check_circle : Icons.radio_button_unchecked,
                            size: 10,
                            color: isItemDone ? AppColors.success : Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.book?.judul ?? 'Buku'}: ${isItemDone ? (itemStatus == 'terlambat' ? 'Selesai (Terlambat)' : 'Selesai') : 'Dipinjam'}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isItemDone ? AppColors.textMuted : AppColors.textDark.withOpacity(0.7),
                                decoration: isItemDone ? TextDecoration.lineThrough : null,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  const SizedBox(height: 6),
                  // Date
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        trx.tanggalPinjam,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  if (trx.denda > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded,
                            size: 14, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text(
                          'Denda: Rp ${trx.denda}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.error),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            // Action Icon
            Center(
              child: Icon(Icons.chevron_right_rounded,
                  color: AppColors.textMuted, size: 24),
            ),
          ],
        ),
      ),
    );
  }
}
