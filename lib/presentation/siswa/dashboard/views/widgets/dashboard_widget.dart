import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import 'package:paket44/presentation/widgets/stat_card.dart';
import 'package:paket44/presentation/shared/widgets/quick_action_card.dart';
import '../../controllers/student_dashboard_controller.dart';
import 'history_widget.dart';
import '../../../../../core/utils/url_utils.dart';

class DashboardWidget extends GetView<StudentDashboardController> {
  const DashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.indigo,
      onRefresh: () async {
        await controller.fetchStudentStats();
        await controller.fetchMyHistory();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(),
            const SizedBox(height: 24),
            Text(
              'Statistik Saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatsRow(),
            const SizedBox(height: 28),
            Text(
              'Aksi Cepat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 28),
            Text(
              'Sedang Dipinjam',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            _buildCurrentlyBorrowedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366f1), Color(0xFF818cf8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Obx(
            () => CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white24,
              backgroundImage: isLocalAsset(controller.userPhoto.value)
                  ? AssetImage(controller.userPhoto.value!)
                      as ImageProvider
                  : isHttpImageUrl(controller.userPhoto.value)
                      ? NetworkImage(controller.userPhoto.value)
                      : null,
              child: !isHttpImageUrl(controller.userPhoto.value) &&
                      !isLocalAsset(controller.userPhoto.value)
                  ? const Icon(Icons.person, color: Colors.white, size: 22)
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${controller.userName}! \uD83D\uDC4B',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Selamat datang di Perpustakaan Digital',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      if (controller.isLoadingDashboard.value) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: CircularProgressIndicator(color: AppColors.indigo),
          ),
        );
      }
      return Row(
        children: [
          Expanded(
            child: StatCard(
              title: 'Buku Dipinjam',
              value: controller.bukuDipinjam.value.toString(),
              icon: Icons.menu_book_rounded,
              iconColor: AppColors.indigo,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              title: 'Total Denda',
              value: 'Rp ${controller.totalDenda.value}',
              icon: Icons.account_balance_wallet_rounded,
              iconColor: controller.totalDenda.value > 0
                  ? AppColors.error
                  : AppColors.success,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        QuickActionCard(
          icon: Icons.search,
          label: 'Cari\nBuku',
          color: AppColors.indigo,
          onTap: () => controller.changePage(1),
        ),
        const SizedBox(width: 12),
        QuickActionCard(
          icon: Icons.history,
          label: 'Riwayat\nPinjam',
          color: const Color(0xFF10B981), // emerald
          onTap: () => controller.changePage(2),
        ),
      ],
    );
  }

  Widget _buildCurrentlyBorrowedList() {
    return Obx(() {
      final dipinjam = controller.myHistory
          .where((e) => e.status.toLowerCase() == 'dipinjam')
          .toList();
      
      if (dipinjam.isEmpty) {
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
              Icon(
                Icons.library_books_outlined,
                size: 40,
                color: AppColors.textMuted.withOpacity(0.4),
              ),
              const SizedBox(height: 8),
              Text(
                'Tidak ada buku yang sedang dipinjam',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        );
      }
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: dipinjam.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final trx = dipinjam[index];
          // Use the row builder from HistoryWidget to display the item
          // Tapping it will show HistoryDetailSheet (because HistoryWidget.buildHistoryItem handles this)
          return HistoryWidget.buildHistoryItem(context, trx);
        },
      );
    });
  }
}
