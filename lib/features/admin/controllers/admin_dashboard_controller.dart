import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/models/tracing_model.dart';

class AdminDashboardController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final hasError = false.obs;

  // Stats
  final activePatients = 0.obs;
  final redZoneCount = 0.obs;
  final activeTracingCount = 0.obs;
  final kepatuhanPercentage = 79.obs; // Dummy data as requested

  // Data
  final patients = <PatientModel>[].obs;
  final recentTracing = <TracingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final results = await Future.wait([
        _supabase.countActivePatients(),
        _supabase.countPatientsByZone('merah'),
        _supabase.getRecentTracingLogs(days: 7),
        _supabase.getActivePatients(),
      ]);

      activePatients.value = results[0] as int;
      redZoneCount.value = results[1] as int;

      final tracingList = results[2] as List<TracingModel>;
      recentTracing.assignAll(tracingList);
      activeTracingCount.value = tracingList.length;

      patients.assignAll(results[3] as List<PatientModel>);
      
      // Keep kepatuhan at 79% for now
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
