import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/tracing_model.dart';

class TracingController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final hasError = false.obs;
  final tracingLogs = <TracingModel>[].obs;

  // Detail view
  final Rx<TracingModel?> selectedTracing = Rx<TracingModel?>(null);
  final patientTracingLogs = <TracingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _supabase.getTracingLogs();
      tracingLogs.assignAll(result);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPatientTracing(String patientId) async {
    isLoading.value = true;
    try {
      final result = await _supabase.getTracingLogs(patientId: patientId);
      patientTracingLogs.assignAll(result);
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void selectTracing(TracingModel tracing) {
    selectedTracing.value = tracing;
    if (tracing.patientId != null) {
      loadPatientTracing(tracing.patientId!);
    }
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
