import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import '../../controllers/admin_dashboard_controller.dart';

/// Widget statistik buku populer & analitik perpustakaan untuk Admin Dashboard.
class BookAnalyticsWidget extends GetView<AdminDashboardController> {
  const BookAnalyticsWidget({super.key});

  /// Safely converts any value (String, int, double, null) → int.
  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingDashboard.value) {
        return _buildSkeleton();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 14),
          _buildTopBooksList(context),
          if (controller.kategoriStats.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildKategoriSection(),
          ],
          if (controller.trenWaktu.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildTrendSection(),
          ],
        ],
      );
    });
  }

  // ── Section Header ──
  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.bar_chart_rounded,
              color: Colors.white, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Statistik Buku',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              Text(
                'Buku paling sering dipinjam',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
        // Filter Dropdown
        Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.indigo.withOpacity(0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.indigo.withOpacity(0.2)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.analyticsFilter.value,
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.indigo, size: 16),
              isDense: true,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.indigo),
              items: const [
                DropdownMenuItem(value: 'semua', child: Text('Semua Waktu')),
                DropdownMenuItem(value: 'harian', child: Text('Harian')),
                DropdownMenuItem(value: 'mingguan', child: Text('Mingguan')),
                DropdownMenuItem(value: 'bulanan', child: Text('Bulanan')),
                DropdownMenuItem(value: 'tahunan', child: Text('Tahunan')),
              ],
              onChanged: (val) {
                if (val != null) controller.changeAnalyticsFilter(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Top 5 Buku ──
  Widget _buildTopBooksList(BuildContext context) {
    final books = controller.topBooks;
    if (books.isEmpty) {
      return _buildEmptyState(
        icon: Icons.menu_book_outlined,
        message: 'Belum ada data peminjaman buku',
      );
    }

    final maxCount = _toInt(books.first['total_dipinjam']);
    final safeMax = maxCount > 0 ? maxCount : 1;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(books.length, (i) {
          final book = books[i];
          final count = _toInt(book['total_dipinjam']);
          final peminjam = _toInt(book['total_peminjam']);
          final progress = count / safeMax;
          return _buildBookRankItem(
            context: context,
            rank: i + 1,
            judul: book['judul']?.toString() ?? '-',
            pengarang: book['pengarang']?.toString() ?? '-',
            coverUrl: book['cover']?.toString(),
            totalDipinjam: count,
            totalPeminjam: peminjam,
            progress: progress.clamp(0.0, 1.0),
            isFirst: i == 0,
            isLast: i == books.length - 1,
          );
        }),
      ),
    );
  }

  Widget _buildBookRankItem({
    required BuildContext context,
    required int rank,
    required String judul,
    required String pengarang,
    required String? coverUrl,
    required int totalDipinjam,
    required int totalPeminjam,
    required double progress,
    required bool isFirst,
    required bool isLast,
  }) {
    final rankColors = [
      const Color(0xFFFFD700), // Gold  #1
      const Color(0xFFC0C0C0), // Silver #2
      const Color(0xFFCD7F32), // Bronze #3
      AppColors.indigo,        // #4
      AppColors.textMuted,     // #5
    ];
    final rankColor = rankColors[(rank - 1).clamp(0, rankColors.length - 1)];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.07), width: 1)),
        color: isFirst ? const Color(0xFFFFD700).withOpacity(0.04) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank badge
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.12),
              shape: BoxShape.circle,
              border:
                  Border.all(color: rankColor.withOpacity(0.4), width: 1.5),
            ),
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Cover
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              width: 36,
              height: 50,
              child: coverFromUrl(coverUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          // Title + bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  pengarang,
                  style:
                      TextStyle(fontSize: 11, color: AppColors.textMuted),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.indigo.withOpacity(0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFirst
                          ? const Color(0xFF6366F1)
                          : AppColors.indigo.withOpacity(0.5),
                    ),
                    minHeight: 5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Count column
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${totalDipinjam}×',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.indigo,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalPeminjam peminjam',
                style: TextStyle(fontSize: 9, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Distribusi Kategori ──
  Widget _buildKategoriSection() {
    final stats = controller.kategoriStats;
    final total = stats.fold<int>(0, (s, e) => s + _toInt(e['jumlah']));

    final kategoriColors = [
      const Color(0xFF6366F1),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      const Color(0xFF8B5CF6),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.pie_chart_outline_rounded,
                size: 16, color: AppColors.indigo),
            const SizedBox(width: 8),
            Text(
              'Distribusi Kategori Peminjaman',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...List.generate(stats.length, (i) {
          final s = stats[i];
          final jumlah = _toInt(s['jumlah']);
          final pct = total > 0 ? (jumlah / total).clamp(0.0, 1.0) : 0.0;
          final color = kategoriColors[i % kategoriColors.length];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: Text(
                    s['kategori']?.toString() ?? '-',
                    style: TextStyle(
                        fontSize: 12, color: AppColors.textDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: color.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: Text(
                    '$jumlah',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ── Tren ──
  Widget _buildTrendSection() {
    final tren = controller.trenWaktu;
    int maxVal = 0;
    for (final t in tren) {
      final v = _toInt(t['jumlah']);
      if (v > maxVal) maxVal = v;
    }
    final safeMax = maxVal > 0 ? maxVal : 1;
    
    final filter = controller.analyticsFilter.value;
    String trendTitle = 'Tren Peminjaman 6 Bulan Terakhir';
    if (filter == 'harian') trendTitle = 'Tren Peminjaman 7 Hari Terakhir';
    if (filter == 'mingguan') trendTitle = 'Tren Peminjaman 4 Minggu Terakhir';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.trending_up_rounded,
                size: 16, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              trendTitle,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 120, // Diperbesar dari 100 untuk mencegah overflow
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(tren.length, (i) {
              final t = tren[i];
              final val = _toInt(t['jumlah']);
              final heightFraction = (val / safeMax).clamp(0.0, 1.0);
              final isLast = i == tren.length - 1;
              final barColor = isLast
                  ? AppColors.indigo
                  : AppColors.indigo.withOpacity(0.45);

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (val > 0)
                        Text(
                          '$val',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isLast
                                  ? AppColors.indigo
                                  : AppColors.textMuted),
                        ),
                      const SizedBox(height: 4),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        height: 60 * heightFraction, // Dikurangi dari 70 agar lebih aman
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t['label_singkat']?.toString() ?? '',
                        style: TextStyle(
                            fontSize: 9, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──
  Widget _buildEmptyState(
      {required IconData icon, required String message}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppColors.textMuted.withOpacity(0.3)),
          const SizedBox(height: 8),
          Text(message,
              style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 160,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        const SizedBox(height: 14),
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ],
    );
  }
}
