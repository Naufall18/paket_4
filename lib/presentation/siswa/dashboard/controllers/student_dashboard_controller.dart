import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../../data/models/book_model.dart';
import '../../../../../../data/models/transaction_model.dart';
import '../../../../../../data/providers/book_provider.dart';
import '../../../../../../data/providers/transaction_provider.dart';
import '../../../../../../data/services/storage_service.dart';
import '../../../../../../routes/app_routes.dart';

class CartItem {
  final BookModel book;
  RxInt quantity;
  RxInt duration;

  CartItem({
    required this.book,
    int quantity = 1,
    int duration = 7,
  })  : quantity = quantity.obs,
        duration = duration.obs;

  Map<String, dynamic> toJson() => {
        'buku_id': book.id,
        'quantity': quantity.value,
        'durasi_hari': duration.value,
      };
}

class StudentDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final BookProvider bookProvider;
  final TransactionProvider transactionProvider;

  StudentDashboardController({
    required this.bookProvider,
    required this.transactionProvider,
  });

  final currentIndex = 0.obs;
  RxString get userName => _storageService.userName;
  RxString get userRole => _storageService.userRole;
  RxString get userPhoto => _storageService.userPhoto;

  // Observables for Books (Available to borrow)
  final availableBooks = <BookModel>[].obs;
  final filteredBooks = <BookModel>[].obs;
  final isLoadingBooks = false.obs;
  final searchQuery = ''.obs;
  final selectedCategory = 'Semua'.obs;
  final categories = <String>['Semua'].obs;

  // Selected duration for borrowing
  final durasiHari = 7.obs;

  // Observables for History
  final myHistory = <TransactionModel>[].obs;
  final isLoadingHistory = false.obs;

  // Observables for Dashboard Stats
  final isLoadingDashboard = false.obs;
  final bukuDipinjam = 0.obs;
  final totalDenda = 0.obs;
  
  // Shopping Cart
  final cart = <CartItem>[].obs;
  int get cartCount => cart.length;
  int get totalItemsInCart => cart.fold(0, (sum, item) => sum + item.quantity.value);

  @override
  void onInit() {
    super.onInit();
    fetchStudentStats();
    fetchMyHistory(); // Fetch history so Dashboard can display "Transaksi Terbaru" immediately
    // Books are loaded on-demand when user taps the tab
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0) fetchStudentStats();
    if (index == 1) fetchAvailableBooks();
    if (index == 2) fetchMyHistory();
  }

  Future<void> fetchStudentStats() async {
    isLoadingDashboard.value = true;
    final response = await transactionProvider.getStudentDashboard();
    if (response['success'] == true) {
      final data = response['data'] ?? {};
      bukuDipinjam.value = data['buku_dipinjam'] ?? 0;
      // Denda might come as string or int depending on backend
      totalDenda.value = data['total_denda'] != null
          ? int.tryParse(data['total_denda'].toString()) ?? 0
          : 0;
    } else {
      Get.snackbar(
        'Error',
        response['message'] ?? 'Gagal memuat statistik siswa',
      );
    }
    isLoadingDashboard.value = false;
  }

  Future<void> fetchAvailableBooks() async {
    isLoadingBooks.value = true;
    final response = await bookProvider.getBooks();
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      availableBooks.value = data.map((e) => BookModel.fromJson(e)).toList();

      // Extract unique categories
      final uniqueCategories = availableBooks
          .map((b) => b.kategori)
          .where((c) => c.isNotEmpty)
          .toSet()
          .toList();
      uniqueCategories.sort();
      categories.value = ['Semua', ...uniqueCategories];

      filterBooks(); // Apply existing search and category immediately
    } else {
      Get.snackbar('Error', response['message'] ?? 'Gagal memuat katalog buku');
    }
    isLoadingBooks.value = false;
  }

  void searchBooks(String query) {
    searchQuery.value = query;
    filterBooks();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
    filterBooks();
  }

  void filterBooks() {
    final query = searchQuery.value.toLowerCase();
    final category = selectedCategory.value;

    filteredBooks.assignAll(
      availableBooks.where((book) {
        final matchesQuery =
            book.judul.toLowerCase().contains(query) ||
            book.pengarang.toLowerCase().contains(query);
        final matchesCategory = category == 'Semua' || book.kategori == category;
        
        return matchesQuery && matchesCategory;
      }).toList(),
    );
  }

  Future<void> fetchMyHistory() async {
    isLoadingHistory.value = true;
    final response = await transactionProvider.getStudentTransactions();
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      myHistory.value = data.map((e) => TransactionModel.fromJson(e)).toList();
    } else {
      Get.snackbar('Error', response['message'] ?? 'Gagal memuat riwayat');
    }
    isLoadingHistory.value = false;
  }

  void addToCart(BookModel book) {
    // Check if already in cart
    final existingIndex = cart.indexWhere((item) => item.book.id == book.id);
    if (existingIndex != -1) {
      if (cart[existingIndex].quantity.value < book.stok) {
        cart[existingIndex].quantity.value++;
        Get.snackbar('Berhasil', 'Jumlah buku ${book.judul} ditambah',
            snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Peringatan', 'Stok buku tidak cukup',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      cart.add(CartItem(book: book));
      Get.snackbar('Berhasil', 'Buku ${book.judul} ditambah ke keranjang',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void removeFromCart(int bookId) {
    cart.removeWhere((item) => item.book.id == bookId);
  }

  void clearCart() {
    cart.clear();
  }

  Future<void> checkoutCart() async {
    if (cart.isEmpty) return;

    isLoadingBooks.value = true;
    final response = await transactionProvider.borrowBook(
      items: cart.map((item) => item.toJson()).toList(),
    );
    isLoadingBooks.value = false;

    if (response['success'] == true) {
      clearCart();
      Get.snackbar(
        '🎉 Horray! Berhasil',
        'Buku berhasil dipinjam. Menunggu persetujuan admin.',
        backgroundColor: const Color(0xFFE0E7FF),
        colorText: const Color(0xFF3730A3),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        icon: Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5), size: 28),
      );
      fetchAvailableBooks();
      fetchStudentStats();
      fetchMyHistory();
    } else {
      Get.snackbar('Oops! Gagal 😢', response['message'] ?? 'Gagal checkout');
    }
  }

  Future<void> borrowBook(int bookId, {int quantity = 1}) async {
    final response = await transactionProvider.borrowBook(
      bookId: bookId,
      durasiHari: durasiHari.value,
      quantity: quantity,
    );
    if (response['success'] == true) {
      Get.snackbar(
        '🎉 Horray! Berhasil',
        'Buku berhasil dipinjam. Menunggu persetujuan admin.',
        backgroundColor: const Color(
          0xFFE0E7FF,
        ), // AppColors.indigo background light
        colorText: const Color(0xFF3730A3), // AppColors.indigo text dark
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        icon: Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4F46E5),
          size: 28,
        ),
        boxShadows: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
      // Reset duration back to default
      durasiHari.value = 7;
      fetchAvailableBooks(); // Refresh stock
      fetchStudentStats(); // Refresh stats
      fetchMyHistory(); // Refresh history
    } else {
      Get.snackbar(
        'Oops! Gagal 😢',
        response['message'] ?? 'Tidak dapat meminjam buku ini',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        icon: Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFDC2626),
          size: 28,
        ),
        boxShadows: [
          BoxShadow(
            color: const Color(0xFFE11D48).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  Future<void> returnBookSiswa(int transactionId) async {
    final response = await transactionProvider.returnBookSiswa(transactionId);
    if (response['success'] == true) {
      Get.snackbar(
        '✅ Berhasil',
        'Buku berhasil dikembalikan',
        backgroundColor: const Color(0xFFE0E7FF),
        colorText: const Color(0xFF3730A3),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        icon: Icon(
          Icons.check_circle_rounded,
          color: Color(0xFF4F46E5),
          size: 28,
        ),
        boxShadows: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
      fetchMyHistory();
      fetchStudentStats();
      fetchAvailableBooks();
    } else {
      Get.snackbar(
        'Oops! Gagal 😢',
        response['message'] ?? 'Gagal mengembalikan buku',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF991B1B),
        snackPosition: SnackPosition.TOP,
        margin: EdgeInsets.all(16),
        borderRadius: 16,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        icon: Icon(
          Icons.error_outline_rounded,
          color: Color(0xFFDC2626),
          size: 28,
        ),
        boxShadows: [
          BoxShadow(
            color: const Color(0xFFE11D48).withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      );
    }
  }

  Future<void> confirmPickup(int transactionId) async {
    final response = await transactionProvider.studentConfirmPickup(transactionId);
    if (response['success'] == true) {
      Get.snackbar(
        'Berhasil',
        'Buku sekarang sedang Anda pinjam',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF065F46),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Color(0xFF059669)),
      );
      fetchMyHistory();
    } else {
      Get.snackbar(
        'Gagal',
        response['message'] ?? 'Gagal konfirmasi pengambilan',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF7F1D1D),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Color(0xFFDC2626)),
      );
    }
  }

  Future<void> returnTransactionItem(
    int transactionId,
    int itemId,
  ) async {
    final response = await transactionProvider.returnTransactionItem(
      transactionId,
      itemId,
    );
    if (response['success'] == true) {
      Get.snackbar(
        'Berhasil',
        'Buku berhasil dikembalikan',
        backgroundColor: const Color(0xFFDCFCE7),
        colorText: const Color(0xFF065F46),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.check_circle, color: Color(0xFF059669)),
      );
      fetchMyHistory();
    } else {
      Get.snackbar(
        'Gagal',
        response['message'] ?? 'Gagal mengembalikan buku',
        backgroundColor: const Color(0xFFFEE2E2),
        colorText: const Color(0xFF7F1D1D),
        snackPosition: SnackPosition.TOP,
        icon: const Icon(Icons.error, color: Color(0xFFDC2626)),
      );
    }
  }

  // Alias for confirmPickup specifically for student confirmation
  Future<void> studentConfirmPickup(int transactionId) async {
    return confirmPickup(transactionId);
  }

  void logout() async {
    await _storageService.clearToken();
    Get.offAllNamed(Routes.LOGIN);
  }
}
