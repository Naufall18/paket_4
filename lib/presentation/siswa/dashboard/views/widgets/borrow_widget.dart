import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/url_utils.dart';
import '../../controllers/student_dashboard_controller.dart';
import 'components/borrow_book_detail_sheet.dart';
import 'components/cart_sheet.dart';

/// Book catalog / borrow list for students.
///
/// Book detail → [BorrowBookDetailSheet]
/// Cart sheet  → [CartSheet]
class BorrowWidget extends GetView<StudentDashboardController> {
  const BorrowWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        color: AppColors.indigo,
        onRefresh: () => controller.fetchAvailableBooks(),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 16),
              _buildListHeader(context),
              const SizedBox(height: 12),
              _buildCategoryChips(),
              const SizedBox(height: 12),
              Expanded(child: _buildBookList(context)),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() => controller.cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => CartSheet.show(context, controller),
              backgroundColor: AppColors.indigo,
              icon: const Icon(Icons.shopping_cart_checkout,
                  color: Colors.white),
              label: Text(
                'Checkout (${controller.totalItemsInCart})',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            )
          : const SizedBox.shrink()),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: controller.searchBooks,
        style: TextStyle(fontSize: 14, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: 'Cari buku berdasarkan judul...',
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
          prefixIcon:
              Icon(Icons.search, color: AppColors.textMuted, size: 20),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Katalog Buku',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark)),
        Obx(
          () => Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${controller.filteredBooks.length} buku',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.indigo),
                ),
              ),
              const SizedBox(width: 8),
              Stack(
                children: [
                  IconButton(
                    onPressed: () => CartSheet.show(context, controller),
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: AppColors.indigo),
                  ),
                  if (controller.cart.isNotEmpty)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle),
                        constraints: const BoxConstraints(
                            minWidth: 14, minHeight: 14),
                        child: Text(
                          '${controller.cart.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips() {
    return Obx(
      () => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: controller.categories.map((category) {
            final isSelected =
                controller.selectedCategory.value == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: FilterChip(
                label: Text(
                  category.isEmpty ? 'Umum' : category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textDark,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => controller.setCategory(category),
                selectedColor: AppColors.indigo,
                backgroundColor: AppColors.cardLight,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color:
                        isSelected ? AppColors.indigo : AppColors.border,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBookList(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingBooks.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppColors.indigo));
      }
      if (controller.filteredBooks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off_rounded,
                  size: 60, color: AppColors.textMuted.withOpacity(0.3)),
              const SizedBox(height: 12),
              Text(
                controller.searchQuery.isEmpty
                    ? 'Katalog kosong'
                    : 'Buku tidak ditemukan',
                style: TextStyle(color: AppColors.textMuted, fontSize: 14),
              ),
            ],
          ),
        );
      }
      return ListView.separated(
        itemCount: controller.filteredBooks.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final book = controller.filteredBooks[index];
          return _buildBookCard(context, book);
        },
      );
    });
  }

  Widget _buildBookCard(BuildContext context, dynamic book) {
    return GestureDetector(
      onTap: () =>
          BorrowBookDetailSheet.show(context, book, controller),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withOpacity(0.04)),
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
                width: 55,
                height: 75,
                color: AppColors.chipBg,
                child: coverFromUrl(book.coverUrl,
                    fit: BoxFit.cover, context: 'BorrowWidget'),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.judul,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textDark),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(book.pengarang,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: book.stok > 0
                          ? const Color(0xFFD1FAE5)
                          : const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Stok: ${book.stok}',
                      style: TextStyle(
                        fontSize: 11,
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
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed:
                  book.stok > 0 ? () => controller.addToCart(book) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo,
                disabledBackgroundColor: AppColors.border,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              child: const Icon(Icons.add_shopping_cart,
                  size: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
