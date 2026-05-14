import 'package:get/get.dart';
import 'app_routes.dart';
import '../presentation/splash/bindings/splash_binding.dart';
import '../presentation/splash/views/splash_view.dart';
import '../presentation/auth/login/bindings/login_binding.dart';
import '../presentation/auth/login/views/login_view.dart';
import '../presentation/auth/register/bindings/register_binding.dart';
import '../presentation/auth/register/views/register_view.dart';
import '../presentation/admin/dashboard/bindings/admin_dashboard_binding.dart';
import '../presentation/admin/dashboard/views/admin_dashboard_view.dart';
import '../presentation/siswa/dashboard/bindings/student_dashboard_binding.dart';
import '../presentation/siswa/dashboard/views/student_dashboard_view.dart';

class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: Routes.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.ADMIN_DASHBOARD,
      page: () => const AdminDashboardView(),
      binding: AdminDashboardBinding(),
    ),
    GetPage(
      name: Routes.STUDENT_DASHBOARD,
      page: () => const StudentDashboardView(),
      binding: StudentDashboardBinding(),
    ),
  ];
}
