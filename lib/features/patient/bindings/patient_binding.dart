import 'package:get/get.dart';
import '../controllers/patient_dashboard_controller.dart';
import '../controllers/article_controller.dart';
import '../controllers/facility_map_controller.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientDashboardController>(
      () => PatientDashboardController(),
    );
    Get.lazyPut<ArticleController>(() => ArticleController());
    Get.lazyPut<FacilityMapController>(() => FacilityMapController());
  }
}
