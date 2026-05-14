import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/url_utils.dart';
import '../../controllers/student_dashboard_controller.dart';
import 'components/history_detail_sheet.dart';

/// History list for students.
///
/// Detail sheet → [HistoryDetailSheet] (`components/history_detail_sheet.dart`)
class HistoryWidget extends GetView<StudentDashboardController> {
  const HistoryWidget({super.key});

  // ── Shared history-item row (used by dashboard too) ──
  static Widget buildHistoryItem(BuildContext context, dynamic trx) {
    String displayStatus = trx.status;
    Color statusColor = const Color(0xFF065F46);
    Color statusBg = const Color(0xFFD1FAE5);

    if (trx.statusApproval == 'rejected') {
      displayStatus = 'Ditolak';
      statusColor = const Color(0xFF991B1B);
      statusBg = const Color(0xFFFEE2E2);
    } else if (trx.statusApproval == 'approved' &&
        trx.status.toLowerCase() == 'pending') {
      displayStatus = 'Bisa Diambil';
      statusColor = const Color(0xFF1E40AF);
      statusBg = const Color(0xFFDBEAFE);
    } else if (trx.status.toLowerCase() == 'pending' ||
        trx.statusApproval == 'pending') {
      displayStatus = 'Menunggu Approval';
      statusColor = const Color(0xFF92400E);
      statusBg = const Color(0xFFFEF3C7);
    } else if (trx.status.toLowerCase() == 'dipinjam') {
      displayStatus = 'Sedang Dipinjam';
      statusColor = const Color(0xFF065F46);
      statusBg = const Color(0xFFD1FAE5);
    } else if (trx.status.toLowerCase() == 'dikembalikan') {
      displayStatus = 'Selesai';
      statusColor = Get.isDarkMode
          ? const Color(0xFF94A3B8)
          : const Color(0xFF64748B);
      statusBg = Get.isDarkMode
          ? const Color(0xFF334155)
          : const Color(0xFFF1F5F9);
    } else if (trx.statusApproval == 'rejected') {
      displayStatus = 'Ditolak';
      statusColor = const Color(0xFF991B1B);
      statusBg = const Color(0xFFFEE2E2);
    }

    String coverUrl;
    if (isLocalAsset(trx.primaryBookCoverUrl)) {
      coverUrl = trx.primaryBookCoverUrl!;
    } else if (isHttpImageUrl(trx.primaryBookCoverUrl)) {
      coverUrl = trx.primaryBookCoverUrl!;
    } else {
      final titleEnc = Uri.encodeComponent(
          trx.primaryBookTitle.isNotEmpty
              ? trx.primaryBookTitle
              : 'Buku');
      coverUrl =
          'https://ui-avatars.com/api/?name=$titleEnc&background=F3F4F6&color=4B5563&size=200';
    }

    return GestureDetector(
      onTap: () => HistoryDetailSheet.showBookDetail(context, trx),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
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
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 58,
                color: statusBg,
                child: coverFromUrl(coverUrl,
                    fit: BoxFit.cover, context: 'History item'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trx.items.length > 1
                        ? '${trx.primaryBookTitle} (+${trx.items.length - 1} buku lainnya)'
                        : (trx.primaryBookTitle.isNotEmpty
                            ? trx.primaryBookTitle
                            : (trx.book?.judul ?? 'Buku')),
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppColors.textDark),
                  ),
                  const SizedBox(height: 2),
                  Text('Durasi: ${trx.durasiHari} Hari',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  if (trx.totalBooks > 1)
                    Text('Jumlah: ${trx.totalBooks} buku',
                        style: TextStyle(
                            fontSize: 12,
                            color: AppColors.indigo,
                            fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayStatus,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: statusColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.indigo,
      onRefresh: () => controller.fetchMyHistory(),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(child: _buildHistoryList(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Riwayat Peminjaman',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        Obx(
          () => Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${controller.myHistory.length} riwayat',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.indigo),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingHistory.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }
      if (controller.myHistory.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.history_outlined,
                  size: 60,
                  color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Belum ada riwayat peminjaman',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        );
      }
      final grouped = _groupByDate(controller.myHistory);
      final dateKeys = grouped.keys.toList();

      return ListView.builder(
        itemCount: dateKeys.length,
        itemBuilder: (context, groupIndex) {
          final dateLabel = dateKeys[groupIndex];
          final items = grouped[dateLabel]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (groupIndex > 0) const SizedBox(height: 16),
              _buildDateHeader(dateLabel, items.length),
              ...items.asMap().entries.map((e) {
                final idx = e.key;
                final trx = e.value;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom: idx < items.length - 1 ? 10 : 0),
                  child: HistoryWidget.buildHistoryItem(context, trx),
                );
              }),
            ],
          );
        },
      );
    });
  }

  Widget _buildDateHeader(String label, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.indigo,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.indigo)),
          const SizedBox(width: 8),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.indigo.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$count peminjaman',
              style: TextStyle(
                  fontSize: 11,
                  color: AppColors.indigo,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Date grouping helpers ──

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool _isYesterday(DateTime date) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static Map<String, List<dynamic>> _groupByDate(
      List<dynamic> transactions) {
    final result = <String, List<dynamic>>{};
    for (final trx in transactions) {
      String label;
      try {
        final dateStr = trx.tanggalPinjam;
        if (dateStr.isNotEmpty) {
          DateTime? date;
          try {
            date =
                DateFormat('dd MMMM yyyy', 'id_ID').parse(dateStr);
          } catch (_) {}
          if (date != null) {
            if (_isToday(date)) {
              label = 'Hari ini';
            } else if (_isYesterday(date)) {
              label = 'Kemarin';
            } else {
              label = dateStr;
            }
          } else {
            label = dateStr;
          }
        } else {
          label = 'Lainnya';
        }
      } catch (_) {
        label = 'Lainnya';
      }
      result.putIfAbsent(label, () => []).add(trx);
    }
    return result;
  }
}
