import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paket44/core/theme/app_colors.dart';
import 'package:paket44/core/utils/url_utils.dart';
import 'package:paket44/presentation/siswa/dashboard/controllers/student_dashboard_controller.dart';

/// Cart bottom sheet for the student borrow view.
class CartSheet {
  static void show(
      BuildContext context, StudentDashboardController controller) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Keranjang Pinjam',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark)),
                  TextButton.icon(
                    onPressed: () => controller.clearCart(),
                    icon: const Icon(Icons.delete_sweep_outlined,
                        size: 18, color: AppColors.error),
                    label: const Text('Hapus Semua',
                        style: TextStyle(
                            color: AppColors.error,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Divider(height: 1, color: AppColors.border),
            // Cart items
            Expanded(
              child: Obx(
                () => controller.cart.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.shopping_basket_outlined,
                                size: 64,
                                color: AppColors.textMuted.withOpacity(0.3)),
                            const SizedBox(height: 16),
                            Text('Keranjang kamu masih kosong',
                                style: TextStyle(
                                    color: AppColors.textMuted,
                                    fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: controller.cart.length,
                        padding: const EdgeInsets.all(20),
                        itemBuilder: (context, index) {
                          final item = controller.cart[index];
                          return _buildCartItem(context, item, controller);
                        },
                      ),
              ),
            ),
            // Checkout button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: SizedBox(
                  width: double.infinity,
                  child: Obx(
                    () => ElevatedButton(
                      onPressed: controller.cart.isEmpty
                          ? null
                          : () {
                              Get.back();
                              controller.checkoutCart();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.indigo,
                        disabledBackgroundColor: AppColors.border,
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text(
                        controller.cart.isEmpty
                            ? 'Keranjang Kosong'
                            : 'Pinjam Sekarang (${controller.totalItemsInCart} Buku)',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  static Widget _buildCartItem(BuildContext context, dynamic item,
      StudentDashboardController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 44,
                  height: 60,
                  color: AppColors.chipBg,
                  child: coverFromUrl(item.book.coverUrl,
                      fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.book.judul,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.textDark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(item.book.pengarang,
                        style: TextStyle(
                            color: AppColors.textMuted, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              IconButton(
                onPressed: () =>
                    controller.removeFromCart(item.book.id),
                icon: Icon(Icons.close_rounded,
                    color: AppColors.textMuted, size: 20),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                          'Durasi: ${item.duration.value} Hari',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.indigo),
                        )),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 2,
                        thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 6),
                        overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 14),
                      ),
                      child: Obx(() => Slider(
                            value: item.duration.value.toDouble(),
                            min: 1,
                            max: 30,
                            divisions: 29,
                            onChanged: (val) =>
                                item.duration.value = val.toInt(),
                            activeColor: AppColors.indigo,
                            inactiveColor:
                                AppColors.indigo.withOpacity(0.1),
                          )),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (item.quantity.value > 1) {
                          item.quantity.value--;
                        }
                      },
                      icon: Icon(Icons.remove,
                          size: 16, color: AppColors.indigo),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                    Obx(() => Text(
                          item.quantity.value.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark),
                        )),
                    IconButton(
                      onPressed: () {
                        if (item.quantity.value < item.book.stok) {
                          item.quantity.value++;
                        }
                      },
                      icon: Icon(Icons.add,
                          size: 16, color: AppColors.indigo),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
