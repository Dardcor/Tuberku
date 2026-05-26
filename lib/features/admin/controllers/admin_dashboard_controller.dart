import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
  final yellowZoneCount = 0.obs;
  final greenZoneCount = 0.obs;
  final activeTracingCount = 0.obs;

  // Admin Info
  final adminName = 'Petugas'.obs;
  final adminCity = 'Surabaya'.obs;

  // Data
  final patients = <PatientModel>[].obs;
  final recentTracing = <TracingModel>[].obs;
  final previewMarkers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final user = _supabase.currentUser;
      if (user != null) {
        final profile = await _supabase.getProfile(user.id);
        if (profile != null && profile.fullName.isNotEmpty) {
          adminName.value = profile.fullName;
        }
      }

      final results = await Future.wait([
        _supabase.countActivePatients(),
        _supabase.countPatientsByZone('merah'),
        _supabase.countPatientsByZone('kuning'),
        _supabase.countPatientsByZone('hijau'),
        _supabase.getRecentTracingLogs(days: 7),
        _supabase.getActivePatients(),
      ]);

      activePatients.value = results[0] as int;
      redZoneCount.value = results[1] as int;
      yellowZoneCount.value = results[2] as int;
      greenZoneCount.value = results[3] as int;

      final tracingList = results[4] as List<TracingModel>;
      recentTracing.assignAll(tracingList);
      activeTracingCount.value = tracingList.length;

      patients.assignAll(results[5] as List<PatientModel>);
      _buildPreviewMarkers();
    } catch (e) {
      debugPrint('[AdminDashboardController] loadData error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _buildPreviewMarkers() {
    final markers = <Marker>{};
    for (final p in patients) {
      if (p.domicileLat != null && p.domicileLng != null && p.isActive) {
        double hue = BitmapDescriptor.hueRed;
        if (p.zone == 'kuning') hue = BitmapDescriptor.hueYellow;
        if (p.zone == 'hijau') hue = BitmapDescriptor.hueGreen;
        markers.add(Marker(
          markerId: MarkerId('prev_${p.id}'),
          position: LatLng(p.domicileLat!, p.domicileLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        ));
      }
    }
    previewMarkers.assignAll(markers);
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
