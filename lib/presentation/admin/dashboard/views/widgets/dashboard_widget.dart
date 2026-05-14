import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/url_utils.dart';
import '../../../../widgets/stat_card.dart';
import 'package:paket44/presentation/shared/widgets/quick_action_card.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'transaction_widget.dart';
import 'book_analytics_widget.dart';
import 'components/dashboard_dialogs.dart';

/// Admin dashboard overview page.
///
/// Dialogs → [DashboardDialogs] (`components/dashboard_dialogs.dart`)
class DashboardWidget extends GetView<AdminDashboardController> {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.indigo,
      onRefresh: () async {
        await controller.fetchDashboardStats();
        await controller.fetchTransactions();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            _buildSectionTitle('Ringkasan', 'Overview perpustakaan Anda'),
            const SizedBox(height: 20),
            _buildStatGrid(),
            const SizedBox(height: 28),
            _buildFinancialSummary(),
            const SizedBox(height: 28),
            const BookAnalyticsWidget(),
            const SizedBox(height: 28),
            _buildQuickActions(),
            const SizedBox(height: 28),
            _buildRecentTransactions(context),
          ],
        ),
      ),
    );
  }

  // ── Welcome Card ──
  Widget _buildWelcomeCard() {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 24),
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.indigo, Color(0xFF6366f1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.indigo.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Selamat datang kembali,',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 6),
                  Text(controller.userName.value,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      controller.userRole.value.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withOpacity(0.5), width: 2),
              ),
              child: ClipOval(
                child: isHttpImageUrl(controller.userPhoto.value)
                    ? Image.network(
                        controller.userPhoto.value,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.person, color: Colors.white, size: 30),
                      )
                    : const Icon(Icons.person, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
      ],
    );
  }

  // ── Stat Grid ──
  Widget _buildStatGrid() {
    return Obx(() {
      if (controller.isLoadingDashboard.value) {
        return const SizedBox(
          height: 200,
          child: Center(
              child: CircularProgressIndicator(color: AppColors.indigo)),
        );
      }
      return Column(
        children: [
          Row(children: [
            Expanded(
                child: StatCard(
                    title: 'Total Buku',
                    value: controller.totalBuku.value.toString(),
                    icon: Icons.auto_stories,
                    iconColor: const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(
                child: StatCard(
                    title: 'Anggota',
                    value: controller.totalAnggota.value.toString(),
                    icon: Icons.people_alt,
                    iconColor: const Color(0xFF10B981))),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: StatCard(
                    title: 'Peminjaman Aktif',
                    value: controller.peminjamanAktif.value.toString(),
                    icon: Icons.sync_alt,
                    iconColor: AppColors.indigo)),
            const SizedBox(width: 12),
            Expanded(
                child: StatCard(
                    title: 'Terlambat',
                    value: controller.bukuTerlambat.value.toString(),
                    icon: Icons.warning_amber_rounded,
                    iconColor: AppColors.error)),
          ]),
        ],
      );
    });
  }

  // ── Financial Summary ──
  Widget _buildFinancialSummary() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Ringkasan Keuangan',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark)),
            Icon(Icons.account_balance_wallet_outlined,
                size: 20, color: AppColors.indigo),
          ],
        ),
        const SizedBox(height: 12),
        Obx(() => Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: _buildRecapItem('Total Denda',
                              'Rp ${controller.totalFineAmount}', AppColors.textDark)),
                      Container(
                          width: 1,
                          height: 40,
                          color: AppColors.border,
                          margin: const EdgeInsets.symmetric(horizontal: 16)),
                      Expanded(
                          child: _buildRecapItem('Lunas',
                              'Rp ${controller.lunasFineAmount}', AppColors.success)),
                    ],
                  ),
                  Divider(height: 32, color: AppColors.border),
                  _buildRecapItem('Belum Dibayar',
                      'Rp ${controller.pendingFineAmount}', AppColors.error),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRecapItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ── Quick Actions ──
  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Aksi Cepat',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            QuickActionCard(
                icon: Icons.add_circle_outline,
                label: 'Tambah\nBuku',
                color: AppColors.indigo,
                onTap: () => controller.changePage(1)),
            const SizedBox(width: 12),
            QuickActionCard(
                icon: Icons.swap_horiz,
                label: 'Lihat\nTransaksi',
                color: const Color(0xFF10B981),
                onTap: () => controller.changePage(2)),
            const SizedBox(width: 12),
            QuickActionCard(
                icon: Icons.person_add_alt,
                label: 'Daftar\nSiswa',
                color: const Color(0xFF3B82F6),
                onTap: () =>
                    DashboardDialogs.showRegisterStudent(controller)),
            const SizedBox(width: 12),
            QuickActionCard(
                icon: Icons.settings_suggest_outlined,
                label: 'Pengaturan\nDenda',
                color: const Color(0xFFF59E0B),
                onTap: () =>
                    DashboardDialogs.showFineSettings(controller)),
          ],
        ),
      ],
    );
  }

  // ── Recent Transactions ──
  Widget _buildRecentTransactions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Transaksi Terbaru',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.transactions.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined,
                      size: 40,
                      color: AppColors.textMuted.withOpacity(0.4)),
                  const SizedBox(height: 8),
                  Text('Belum ada transaksi',
                      style: TextStyle(
                          color: AppColors.textMuted, fontSize: 13)),
                ],
              ),
            );
          }
          final recent = controller.transactions.take(3).toList();
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recent.length,
              separatorBuilder: (_, __) =>
                  Divider(height: 1, color: Colors.grey.withOpacity(0.1)),
              itemBuilder: (context, index) {
                final trx = recent[index];
                final isPending = trx.statusApproval == 'pending';
                final isDipinjam = trx.statusApproval == 'approved' &&
                    trx.status == 'dipinjam';
                return ListTile(
                  onTap: () {
                    debugPrint('tap recent transaction id=${trx.id}');
                    TransactionWidget.showTransactionDetail(
                        context, trx, controller);
                  },
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  leading: CircleAvatar(
                    backgroundColor: isPending
                        ? AppColors.info.withOpacity(0.1)
                        : (isDipinjam
                            ? Colors.orange.withOpacity(0.1)
                            : AppColors.success.withOpacity(0.1)),
                    child: Icon(
                      isPending
                          ? Icons.pending_actions
                          : (isDipinjam
                              ? Icons.hourglass_bottom
                              : Icons.check_circle_outline),
                      color: isPending
                          ? AppColors.info
                          : (isDipinjam
                              ? Colors.orange
                              : AppColors.success),
                      size: 20,
                    ),
                  ),
                  title: Text(trx.user?.name ?? 'Siswa',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark)),
                  subtitle: Text(trx.book?.judul ?? '-',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted)),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isPending
                          ? const Color(0xFFDBEAFE)
                          : (isDipinjam
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFD1FAE5)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      trx.displayStatus,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isPending
                            ? const Color(0xFF1E40AF)
                            : (isDipinjam
                                ? const Color(0xFF92400E)
                                : const Color(0xFF065F46)),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}
