import 'package:get/get.dart';
import '../../../../../../data/providers/book_provider.dart';
import '../../../../../../data/providers/transaction_provider.dart';
import '../controllers/student_dashboard_controller.dart';

class StudentDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookProvider>(() => BookProvider());
    Get.lazyPut<TransactionProvider>(() => TransactionProvider());
    Get.lazyPut<StudentDashboardController>(
      () => StudentDashboardController(
        bookProvider: Get.find<BookProvider>(),
        transactionProvider: Get.find<TransactionProvider>(),
      ),
    );
  }
}
