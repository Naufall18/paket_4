import 'package:flutter/material.dart';
import 'package:paket44/data/models/book_model.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import '../../controllers/admin_dashboard_controller.dart';
import 'components/book_form_dialog.dart';
import 'components/book_detail_sheet.dart';
import 'components/book_card.dart';

/// Main book list view for admin dashboard.
///
/// Form dialogs → [BookFormDialog] (`components/book_form_dialog.dart`)
/// Detail sheet → [BookDetailSheet] (`components/book_detail_sheet.dart`)
class BookWidget extends GetView<AdminDashboardController> {
  const BookWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => BookFormDialog.showAddDialog(context, controller),
        backgroundColor: AppColors.indigo,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.indigo,
        onRefresh: () => controller.fetchBooks(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              _buildHeader(),
              const SizedBox(height: 16),
              // ── Search ──
              _buildSearchBar(context),
              const SizedBox(height: 16),
              // ── Category chips ──
              _buildCategoryChips(),
              const SizedBox(height: 16),
              // ── Book list ──
              Expanded(child: _buildBookList(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Kelola Buku',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        Obx(() => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.indigo.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${controller.filteredBooks.length} buku',
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.indigo),
              ),
            )),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return TextField(
      onChanged: (value) => controller.searchBookQuery.value = value,
      decoration: InputDecoration(
        hintText: 'Cari judul atau pengarang...',
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

  Widget _buildCategoryChips() {
    return Obx(() {
      if (controller.bookCategories.isEmpty) return const SizedBox.shrink();
      return SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: controller.bookCategories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final kategori = controller.bookCategories[index];
            final isSelected =
                controller.selectedBookCategory.value == kategori;
            return GestureDetector(
              onTap: () =>
                  controller.selectedBookCategory.value = kategori,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.indigo
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.indigo
                        : Colors.grey.withOpacity(0.3),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  kategori,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                    color:
                        isSelected ? Colors.white : AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildBookList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBooks.value) {
        return Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }
      if (controller.filteredBooks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.menu_book_outlined,
                  size: 60, color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text('Tidak ada buku yang sesuai',
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 14)),
            ],
          ),
        );
      }
      return ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        itemCount: controller.filteredBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final book = controller.filteredBooks[index];
          return BookCard(
            book: book,
            onEdit: () => BookFormDialog.showEditDialog(context, book, controller),
            onDelete: () => _showDeleteDialog(context, book.id, book.judul),
          );
        },
      );
    });
  }

  void _showDeleteDialog(BuildContext context, int bookId, String title) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_outline, color: Colors.red),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Hapus Buku',
                  style: TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 18)),
            ),
          ],
        ),
        content: Text('Yakin ingin menghapus "$title"?',
            style: TextStyle(color: AppColors.textMuted)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Batal',
                style: TextStyle(color: AppColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteBook(bookId);
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
