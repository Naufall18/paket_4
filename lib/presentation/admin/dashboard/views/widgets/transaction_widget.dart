import 'package:flutter/material.dart';
import 'package:paket44/data/models/transaction_model.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'components/transaction_detail_sheet.dart';
import 'components/transaction_card.dart';
import 'components/transaction_pdf_export.dart';

/// Main transaction list view for admin dashboard.
///
/// Detail sheets and action dialogs are in:
/// - [TransactionDetailSheet] → `components/transaction_detail_sheet.dart`
/// - [TransactionActions]     → `components/transaction_actions.dart`
/// - [TransactionPdfExport]   → `components/transaction_pdf_export.dart`
class TransactionWidget extends GetView<AdminDashboardController> {
  const TransactionWidget({super.key});

  /// Public accessor so other widgets (e.g. dashboard) can call it.
  static void showTransactionDetail(
    BuildContext context,
    dynamic trx,
    AdminDashboardController controller,
  ) =>
      TransactionDetailSheet.show(context, trx, controller);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.indigo,
      onRefresh: () => controller.fetchTransactions(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            _buildHeader(context),
            const SizedBox(height: 16),

            // ── Search ──
            _buildSearchBar(context),
            const SizedBox(height: 16),

            // ── Status filters ──
            _buildStatusFilters(),
            const SizedBox(height: 16),

            // ── List ──
            Expanded(child: _buildTransactionList(context)),
          ],
        ),
      ),
    );
  }

  // ── Header with counter + PDF export ──
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Transaksi',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark),
        ),
        Row(
          children: [
            Obx(() => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.filteredTransactions.length} data',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.indigo),
                  ),
                )),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(Icons.picture_as_pdf, color: AppColors.indigo),
              tooltip: 'Cetak PDF',
              onPressed: () =>
                  TransactionPdfExport.showExportDialog(context, controller),
            ),
          ],
        ),
      ],
    );
  }

  // ── Search bar ──
  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: (value) => controller.searchTransactionQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Cari nama siswa, buku, atau kategori...',
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.indigo),
        ),
      ),
    );
  }

  // ── Horizontal status filter chips ──
  Widget _buildStatusFilters() {
    return Obx(() {
      if (controller.transactionStatuses.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.transactionStatuses.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final status = controller.transactionStatuses[index];
            final isSelected =
                controller.selectedTransactionStatus.value == status;
            return GestureDetector(
              onTap: () =>
                  controller.selectedTransactionStatus.value = status,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.indigo : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.indigo
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Transaction list ──
  Widget _buildTransactionList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingTransactions.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }
      if (controller.filteredTransactions.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 60, color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Tidak ada transaksi yang sesuai',
                  style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        itemCount: controller.filteredTransactions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final trx = controller.filteredTransactions[index];
          return TransactionCard(
            trx: trx,
            controller: controller,
          );
        },
      );
    });
  }
}
