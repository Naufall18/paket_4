import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../../data/models/book_model.dart';
import '../../../../../../data/models/transaction_model.dart';
import '../../../../../../data/providers/book_provider.dart';
import '../../../../../../data/providers/transaction_provider.dart';
import '../../../../../../data/providers/anggota_provider.dart';
import '../../../../../../data/providers/auth_provider.dart';
import '../../../../../../data/models/anggota_model.dart';
import '../../../../../../data/services/storage_service.dart';
import '../../../../../../routes/app_routes.dart';
import '../../../../../../core/utils/snackbar_helper.dart';
import '../../../../../../data/providers/pengaturan_provider.dart';

class AdminDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final BookProvider bookProvider;
  final TransactionProvider transactionProvider;
  final AnggotaProvider anggotaProvider;
  final PengaturanProvider pengaturanProvider;
 
  AdminDashboardController({
    required this.bookProvider,
    required this.transactionProvider,
    required this.anggotaProvider,
    required this.pengaturanProvider,
  });

  final currentIndex = 0.obs;
  RxString get userName => _storageService.userName;
  RxString get userRole => _storageService.userRole;
  RxString get userPhoto => _storageService.userPhoto;
  // Observables for Books
  final books = <BookModel>[].obs;
  final isLoadingBooks = false.obs;
  
  final searchBookQuery = ''.obs;
  final selectedBookCategory = 'Semua'.obs;
  final bookCategories = <String>['Semua'].obs;

  List<BookModel> get filteredBooks {
    return books.where((book) {
      final matchesSearch = book.judul.toLowerCase().contains(searchBookQuery.value.toLowerCase()) ||
                            book.pengarang.toLowerCase().contains(searchBookQuery.value.toLowerCase());
      final matchesCategory = selectedBookCategory.value == 'Semua' || book.kategori == selectedBookCategory.value;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Observables for Transactions
  final transactions = <TransactionModel>[].obs;
  final isLoadingTransactions = false.obs;
  
  final searchTransactionQuery = ''.obs;
  final selectedTransactionStatus = 'Semua'.obs;
  final transactionStatuses = <String>['Semua'].obs;

  List<TransactionModel> get filteredTransactions {
    return transactions.where((trx) {
      final matchesSearch = (trx.user?.name?.toLowerCase() ?? '').contains(searchTransactionQuery.value.toLowerCase()) ||
                            (trx.book?.judul?.toLowerCase() ?? '').contains(searchTransactionQuery.value.toLowerCase()) ||
                            (trx.book?.kategori?.toLowerCase() ?? '').contains(searchTransactionQuery.value.toLowerCase());
      final selectedStatus = selectedTransactionStatus.value.toLowerCase();
      bool matchesStatus;
      if (selectedTransactionStatus.value == 'Semua') {
        matchesStatus = true;
      } else if (selectedTransactionStatus.value == 'Ditolak') {
        matchesStatus = trx.statusApproval.toLowerCase() == 'rejected';
      } else if (selectedTransactionStatus.value == 'Belum Bayar Denda') {
        matchesStatus = trx.denda > 0 && trx.statusBayarDenda == 'belum_bayar';
      } else if (selectedTransactionStatus.value == 'Lunas') {
        matchesStatus = trx.denda > 0 && trx.statusBayarDenda == 'lunas';
      } else {
        matchesStatus = trx.status.toLowerCase() == selectedStatus;
      }
      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Observables for Anggota
  final anggotas = <AnggotaModel>[].obs;
  final isLoadingAnggota = false.obs;
  final searchAnggotaQuery = ''.obs;
  final selectedAnggotaKelas = 'Semua'.obs;
  final selectedAnggotaTingkat = 'Semua'.obs;
  final selectedAnggotaJurusan = 'Semua'.obs;

  List<AnggotaModel> get filteredAnggotas {
    return anggotas.where((a) {
      final matchesSearch = a.name.toLowerCase().contains(searchAnggotaQuery.value.toLowerCase()) ||
                            (a.nis ?? '').toLowerCase().contains(searchAnggotaQuery.value.toLowerCase()) ||
                            (a.username ?? '').toLowerCase().contains(searchAnggotaQuery.value.toLowerCase());
      
      final k = a.kelas.toUpperCase();
      // Split "XI RPL" -> ["XI", "RPL"]
      final parts = k.split(' ');
      final tingkat = parts.isNotEmpty ? parts[0] : '';
      final jurusan = parts.length > 1 ? parts.sublist(1).join(' ') : '';

      final matchesKelas = selectedAnggotaKelas.value == 'Semua' || a.kelas == selectedAnggotaKelas.value;
      final matchesTingkat = selectedAnggotaTingkat.value == 'Semua' || tingkat == selectedAnggotaTingkat.value;
      final matchesJurusan = selectedAnggotaJurusan.value == 'Semua' || jurusan == selectedAnggotaJurusan.value;

      return matchesSearch && matchesKelas && matchesTingkat && matchesJurusan;
    }).toList();
  }

  List<String> get tingkatList {
    final list = anggotas.map((a) {
      final parts = a.kelas.toUpperCase().split(' ');
      return parts.isNotEmpty ? parts[0] : '';
    }).where((t) => t.isNotEmpty).toSet().toList();
    list.sort();
    return ['Semua', ...list];
  }

  List<String> get jurusanList {
    final list = anggotas.map((a) {
      final parts = a.kelas.toUpperCase().split(' ');
      return parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }).where((j) => j.isNotEmpty).toSet().toList();
    list.sort();
    return ['Semua', ...list];
  }

  List<String> get anggotaKelasList {
    final uniqueKelas = anggotas.map((a) => a.kelas ?? '').where((k) => k.isNotEmpty).toSet().toList();
    uniqueKelas.sort();
    return ['Semua', ...uniqueKelas];
  }

  List<AnggotaModel> get supportRequests {
    return anggotas.where((a) => a.supportRequest != null && a.supportRequest!.isNotEmpty).toList();
  }

  // Observables for Dashboard Stats
  final isLoadingDashboard = false.obs;
  final totalBuku = 0.obs;
  final totalAnggota = 0.obs;
  final peminjamanAktif = 0.obs;
  final bukuTerlambat = 0.obs;

  // Analytics Data
  final analyticsFilter = 'semua'.obs;
  final topBooks = <Map<String, dynamic>>[].obs;
  final kategoriStats = <Map<String, dynamic>>[].obs;
  final trenWaktu = <Map<String, dynamic>>[].obs;

  // Fines Recap
  int get totalFineAmount => transactions.fold(0, (sum, trx) => sum + trx.denda);
  int get lunasFineAmount => transactions.where((trx) => trx.statusBayarDenda == 'lunas').fold(0, (sum, trx) => sum + trx.denda);
  int get pendingFineAmount => transactions.where((trx) => trx.statusBayarDenda == 'belum_bayar').fold(0, (sum, trx) => sum + trx.denda);

  // Fine Settings
  final isLoadingSettings = false.obs;
  final settings = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboardStats();
    fetchTransactions(); // Load latest transactions for dashboard
    fetchBooks(); // Preload books
    fetchSettings(); // Load fine settings
  }

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 0) fetchDashboardStats();
    if (index == 1) fetchBooks();
    if (index == 2) fetchTransactions();
    if (index == 3) fetchAnggotas();
  }

  void changeAnalyticsFilter(String filter) {
    if (analyticsFilter.value == filter) return;
    analyticsFilter.value = filter;
    fetchDashboardStats();
  }

  Future<void> fetchDashboardStats() async {
    isLoadingDashboard.value = true;
    final response = await transactionProvider.getAdminDashboard(filter: analyticsFilter.value);
    if (response['success'] == true) {
      final data = response['data'] ?? {};
      totalBuku.value = data['total_buku'] ?? 0;
      totalAnggota.value = data['total_anggota'] ?? 0;
      peminjamanAktif.value = data['peminjaman_aktif'] ?? 0;
      bukuTerlambat.value = data['buku_terlambat'] ?? 0;

      // Analytics
      if (data['top_books'] != null) {
        topBooks.value = List<Map<String, dynamic>>.from(
          (data['top_books'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      if (data['kategori_stats'] != null) {
        kategoriStats.value = List<Map<String, dynamic>>.from(
          (data['kategori_stats'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
      if (data['tren_waktu'] != null) {
        trenWaktu.value = List<Map<String, dynamic>>.from(
          (data['tren_waktu'] as List).map((e) => Map<String, dynamic>.from(e)),
        );
      }
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal memuat statistik');
    }
    isLoadingDashboard.value = false;
  }

  Future<void> fetchBooks() async {
    isLoadingBooks.value = true;
    final response = await bookProvider.getBooks();
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      books.value = data.map((e) => BookModel.fromJson(e)).toList();
      
      final uniqueCategories = books.map((b) => b.kategori).toSet().toList();
      uniqueCategories.sort();
      bookCategories.value = ['Semua', ...uniqueCategories];
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal memuat buku');
    }
    isLoadingBooks.value = false;
  }

  Future<void> fetchTransactions() async {
    isLoadingTransactions.value = true;
    final response = await transactionProvider.getAdminTransactions();
    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      transactions.value = data
          .map((e) => TransactionModel.fromJson(e))
          .toList();
          
      final uniqueStatuses = transactions.map((t) => t.status).toSet().toList();
      uniqueStatuses.sort();
      // Always include Ditolak even if no rejected transactions exist yet
      final statusList = ['Semua', ...uniqueStatuses];
      if (!statusList.contains('Ditolak')) statusList.add('Ditolak');
      if (!statusList.contains('Belum Bayar Denda')) statusList.add('Belum Bayar Denda');
      if (!statusList.contains('Lunas')) statusList.add('Lunas');
      transactionStatuses.value = statusList;
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal memuat transaksi');
    }
    isLoadingTransactions.value = false;
  }

  Future<void> payFine(int transactionId) async {
    final response = await transactionProvider.payFine(transactionId);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Berhasil', 'Denda telah ditandai sebagai Lunas');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal memproses pembayaran');
    }
  }

  Future<void> returnBookWithCondition(int transactionId, {
    String kondisiBuku = 'baik',
    String? catatanKondisi,
    int? dendaKerusakan,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await transactionProvider.returnBook(
      transactionId,
      kondisiBuku: kondisiBuku,
      catatanKondisi: catatanKondisi,
      dendaKerusakan: dendaKerusakan,
      items: items,
    );
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Selesai', 'Buku telah selesai dikembalikan');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal mengembalikan buku');
    }
  }

  Future<void> approveBorrowing(int transactionId, {
    String kondisiBuku = 'baik',
    String? catatanKondisi,
    List<Map<String, dynamic>>? items,
  }) async {
    final response = await transactionProvider.approveBorrowing(
      transactionId,
      kondisiBuku: kondisiBuku,
      catatanKondisi: catatanKondisi,
      items: items,
    );
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Selesai', 'Peminjaman telah disetujui');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal menyetujui peminjaman');
    }
  }

  Future<void> markAsTaken(int transactionId) async {
    final response = await transactionProvider.markAsTaken(transactionId);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Berhasil', 'Buku ditandai telah diambil oleh siswa');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal memproses status pengambilan');
    }
  }

  Future<void> confirmPickup(int transactionId) async {
    final response = await transactionProvider.confirmPickup(transactionId);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Berhasil', 'Pengambilan buku dikonfirmasi');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal konfirmasi pengambilan');
    }
  }

  Future<void> rejectBorrowing(int transactionId) async {
    final response = await transactionProvider.rejectBorrowing(transactionId);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Selesai', 'Peminjaman telah ditolak');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal menolak peminjaman');
    }
  }

  Future<void> deleteTransaction(int transactionId) async {
    final response = await transactionProvider.deleteTransaction(transactionId);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Sukses', 'Transaksi berhasil dihapus');
      fetchTransactions();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal menghapus transaksi');
    }
  }

  Future<void> deleteBook(int id) async {
    final response = await bookProvider.deleteBook(id);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Sukses', 'Buku berhasil dihapus');
      fetchBooks();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal menghapus buku');
    }
  }

  Future<void> addBook(Map<String, String> data, {XFile? image}) async {
    final response = await bookProvider.addBook(data, image);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Berhasil', 'Buku baru telah berhasil ditambahkan ke katalog');
      fetchBooks();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal menambahkan buku');
    }
  }

  Future<void> editBook(
    int id,
    Map<String, String> data, {
    XFile? image,
  }) async {
    final response = await bookProvider.updateBook(id, data, image);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Berhasil', 'Informasi buku berhasil diperbarui');
      fetchBooks();
    } else {
      SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal memperbarui buku');
    }
  }

  Future<void> registerStudent(
    String name,
    String username,
    String email,
    String password,
    String nis,
    String kelas,
  ) async {
    try {
      final data = {
        'name': name,
        'username': username,
        'email': email,
        'password': password,
        'nis': nis,
        'kelas': kelas,
      };
      final response = await anggotaProvider.addAnggota(data);
      if (response['success'] == true) {
        SnackbarHelper.showSuccess('Sukses', 'Siswa berhasil didaftarkan');
        fetchDashboardStats();
        fetchAnggotas();
      } else {
        SnackbarHelper.showError('Error', response['message'] ?? 'Gagal mendaftarkan siswa');
      }
    } catch (e) {
      SnackbarHelper.showError('Error', 'Terjadi kesalahan: $e');
    }
  }

  Future<void> fetchAnggotas({String? search}) async {
    isLoadingAnggota.value = true;
    if (search != null) searchAnggotaQuery.value = search;
    final response = await anggotaProvider.getAnggotas(
      search: searchAnggotaQuery.value,
    );

    if (response['success'] == true && response['data'] != null) {
      final List<dynamic> data = response['data'];
      anggotas.value = data.map((e) => AnggotaModel.fromJson(e)).toList();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal memuat data anggota');
    }
    isLoadingAnggota.value = false;
  }

  Future<void> updateAnggota(int id, Map<String, dynamic> data) async {
    final response = await anggotaProvider.updateAnggota(id, data);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Sukses', 'Data anggota berhasil diperbarui');
      fetchAnggotas();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal memperbarui data anggota');
    }
  }

  Future<void> deleteAnggota(int id) async {
    final response = await anggotaProvider.deleteAnggota(id);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Sukses', 'Anggota berhasil dihapus');
      fetchAnggotas();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal menghapus anggota');
    }
  }

  Future<void> toggleAnggotaStatus(int id) async {
    final response = await anggotaProvider.toggleAnggotaStatus(id);
    if (response['success'] == true) {
      SnackbarHelper.showSuccess('Sukses', 'Status anggota berhasil diubah');
      fetchAnggotas();
      fetchDashboardStats();
    } else {
      SnackbarHelper.showError('Error', response['message'] ?? 'Gagal mengubah status anggota');
    }
  }

  void logout() async {
    await _storageService.clearToken();
    Get.offAllNamed(Routes.LOGIN);
  }

  Future<void> fetchSettings() async {
    try {
      isLoadingSettings.value = true;
      final response = await pengaturanProvider.getSettings();
      if (response['success'] == true) {
        settings.assignAll(List<Map<String, dynamic>>.from(response['data']));
      }
    } catch (e) {
      debugPrint('Error fetching settings: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }

  Future<void> updateSettings(List<Map<String, dynamic>> updatedSettings) async {
    try {
      isLoadingSettings.value = true;
      final response = await pengaturanProvider.updateSettings(updatedSettings);
      if (response['success'] == true) {
        SnackbarHelper.showSuccess('Berhasil', 'Pengaturan denda berhasil diperbarui');
        fetchSettings();
      } else {
        SnackbarHelper.showError('Gagal', response['message'] ?? 'Gagal memperbarui pengaturan');
      }
    } catch (e) {
      SnackbarHelper.showError('Gagal', 'Gagal memperbarui pengaturan: $e');
    } finally {
      isLoadingSettings.value = false;
    }
  }
}
