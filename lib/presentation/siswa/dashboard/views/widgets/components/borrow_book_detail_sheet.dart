import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/siswa/dashboard/controllers/student_dashboard_controller.dart';

/// Book detail preview bottom sheet for student borrow view.
class BorrowBookDetailSheet {
  static void show(BuildContext context, dynamic book,
      StudentDashboardController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 80,
                      height: 110,
                      color: AppColors.chipBg,
                      child: coverFromUrl(book.coverUrl,
                          fit: BoxFit.cover, context: 'Borrow detail'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book.judul,
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                color: AppColors.textDark)),
                        const SizedBox(height: 4),
                        Text('Oleh: ${book.pengarang}',
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.indigo,
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Text('Penerbit: ${book.penerbit}',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                            'Tahun: ${book.tahun} • Kategori: ${book.kategori}',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                        const SizedBox(height: 4),
                        Text(
                            'Letak Rak: ${book.lokasiRak ?? "Tidak diketahui"}',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.indigo,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: book.stok > 0
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
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
              Text('Deskripsi Buku',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: AppColors.textDark)),
              const SizedBox(height: 8),
              Text(
                (book.deskripsi != null && book.deskripsi!.isNotEmpty)
                    ? book.deskripsi!
                    : 'Tidak ada deskripsi yang tersedia untuk buku ini.',
                style: TextStyle(
                    fontSize: 14, color: AppColors.textMuted, height: 1.5),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: book.stok > 0
                      ? () {
                          Get.back();
                          controller.addToCart(book);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.indigo,
                    disabledBackgroundColor: AppColors.border,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    book.stok > 0 ? 'Tambah ke Keranjang' : 'Stok Habis',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: book.stok > 0
                          ? Colors.white
                          : AppColors.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
