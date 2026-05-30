<<<<<<< HEAD
=======
<<<<<<< HEAD
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
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:get/get.dart';
import '../controllers/patient_dashboard_controller.dart';
import '../controllers/article_controller.dart';
import '../controllers/facility_map_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class PatientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PatientDashboardController>(
      () => PatientDashboardController(),
    );
    Get.lazyPut<ArticleController>(() => ArticleController());
    Get.lazyPut<FacilityMapController>(() => FacilityMapController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
