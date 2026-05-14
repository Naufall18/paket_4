import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/shared/widgets/detail_info_row.dart';

/// Book detail preview bottom sheet for admin.
class BookDetailSheet {
  static void show(BuildContext context, dynamic book) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book header with cover
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 90,
                      height: 130,
                      color: AppColors.border,
                      child: coverFromUrl(
                        book.coverUrl,
                        fit: BoxFit.cover,
                        context: 'Admin book detail',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.judul ?? 'Judul Buku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DetailIconRow(
                            icon: Icons.person,
                            label: 'Pengarang',
                            value: book.pengarang,
                            spacing: 6),
                        const SizedBox(height: 4),
                        DetailIconRow(
                            icon: Icons.business,
                            label: 'Penerbit',
                            value: book.penerbit,
                            spacing: 6),
                        const SizedBox(height: 4),
                        DetailIconRow(
                            icon: Icons.category,
                            label: 'Kategori',
                            value: book.kategori,
                            spacing: 6),
                        const SizedBox(height: 4),
                        DetailIconRow(
                            icon: Icons.calendar_today,
                            label: 'Tahun',
                            value: book.tahun,
                            spacing: 6),
                        const SizedBox(height: 8),
                        // Stock badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: book.stok > 0
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Stok Tersedia: ${book.stok}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: book.stok > 0
                                  ? const Color(0xFF065F46)
                                  : const Color(0xFF991B1B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Description
              Text(
                'Deskripsi Buku',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark),
              ),
              const SizedBox(height: 8),
              Text(
                book.deskripsi != null && book.deskripsi!.isNotEmpty
                    ? book.deskripsi!
                    : 'Buku ini tidak memiliki deskripsi.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                  ),
                  child: Text(
                    'Tutup',
                    style: TextStyle(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                        fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
