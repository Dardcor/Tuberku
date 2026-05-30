<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/heatmap_controller.dart';
import '../controllers/tracing_controller.dart';
import '../controllers/intervention_controller.dart';
import '../controllers/main_admin_controller.dart';
import '../controllers/add_patient_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainAdminController>(() => MainAdminController());
    Get.lazyPut<AdminDashboardController>(
      () => AdminDashboardController(),
    );
    Get.lazyPut<HeatmapController>(() => HeatmapController());
    Get.lazyPut<TracingController>(() => TracingController());
    Get.lazyPut<InterventionController>(() => InterventionController());
    Get.lazyPut<AddPatientController>(() => AddPatientController());
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/heatmap_controller.dart';
import '../controllers/tracing_controller.dart';
import '../controllers/main_admin_controller.dart';
import '../controllers/add_patient_controller.dart';
import '../controllers/admin_profile_controller.dart';

class AdminBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainAdminController>(() => MainAdminController());
    Get.lazyPut<AdminDashboardController>(
      () => AdminDashboardController(),
    );
    Get.lazyPut<HeatmapController>(() => HeatmapController());
    Get.lazyPut<TracingController>(() => TracingController());
    Get.lazyPut<AddPatientController>(() => AddPatientController());
    Get.lazyPut<AdminProfileController>(() => AdminProfileController());
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
