import 'package:get/get.dart';
import '../../../../../../data/providers/book_provider.dart';
import '../../../../../../data/providers/transaction_provider.dart';
import '../../../../../../data/providers/anggota_provider.dart';
import '../../../../../../data/providers/pengaturan_provider.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookProvider>(() => BookProvider());
    Get.lazyPut<TransactionProvider>(() => TransactionProvider());
    Get.lazyPut<AnggotaProvider>(() => AnggotaProvider());
    Get.lazyPut<PengaturanProvider>(() => PengaturanProvider());
    Get.lazyPut<AdminDashboardController>(
      () => AdminDashboardController(
        bookProvider: Get.find<BookProvider>(),
        transactionProvider: Get.find<TransactionProvider>(),
        anggotaProvider: Get.find<AnggotaProvider>(),
        pengaturanProvider: Get.find<PengaturanProvider>(),
      ),
    );
  }
}
