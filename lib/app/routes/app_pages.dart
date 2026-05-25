import 'package:get/get.dart';
import 'app_routes.dart';
import '../../features/auth/bindings/auth_binding.dart';
import '../../features/auth/views/role_selection_screen.dart';
import '../../features/auth/views/activation_screen.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/petugas_login_screen.dart';
import '../../features/auth/views/consent_gps_screen.dart';
import '../../features/patient/bindings/patient_binding.dart';
import '../../features/patient/views/patient_dashboard_screen.dart';
import '../../features/patient/views/article_list_screen.dart';
import '../../features/patient/views/article_detail_screen.dart';
import '../../features/patient/views/facility_map_screen.dart';
import '../../features/patient/views/facility_detail_screen.dart';
import '../../features/tuberku_ai/bindings/ai_binding.dart';
import '../../features/tuberku_ai/views/ai_chat_screen.dart';
import '../../features/admin/bindings/admin_binding.dart';
import '../../features/admin/views/heatmap_screen.dart';
import '../../features/admin/views/tracing_timeline_screen.dart';
import '../../features/admin/views/tracing_detail_screen.dart';
import '../../features/profile/views/profile_screen.dart';
import '../../features/profile/bindings/profile_binding.dart';
import '../../features/admin/views/main_admin_screen.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.roleSelection;

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.roleSelection,
      page: () => const RoleSelectionScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.activation,
      page: () => const ActivationScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: AppRoutes.petugasLogin,
      page: () => const PetugasLoginScreen(),
    ),
    GetPage(
      name: AppRoutes.consentGps,
      page: () => const ConsentGpsScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.patientDashboard,
      page: () => const PatientDashboardScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.articleList,
      page: () => const ArticleListScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.articleDetail,
      page: () => const ArticleDetailScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.facilityMap,
      page: () => const FacilityMapScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.facilityDetail,
      page: () => const FacilityDetailScreen(),
      binding: PatientBinding(),
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AiChatScreen(),
      binding: AiBinding(),
    ),
    GetPage(
      name: AppRoutes.adminDashboard,
      page: () => const MainAdminScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.heatmap,
      page: () => const HeatmapScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.tracingTimeline,
      page: () => const TracingTimelineScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.tracingDetail,
      page: () => const TracingDetailScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
  ];
}
