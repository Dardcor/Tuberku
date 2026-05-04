import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';

class HeatmapController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final hasError = false.obs;
  final patients = <PatientModel>[].obs;
  final markers = <Marker>{}.obs;
  final selectedFilter = 'Semua'.obs;

  final filters = ['Semua', 'Zona Merah', 'Zona Kuning', 'Zona Hijau'];

  GoogleMapController? mapController;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    hasError.value = false;

    try {
      final result = await _supabase.getActivePatients();
      patients.assignAll(result);
      _buildMarkers();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _buildMarkers();
  }

  void _buildMarkers() {
    final newMarkers = <Marker>{};
    var filtered = patients.toList();

    switch (selectedFilter.value) {
      case 'Zona Merah':
        filtered = filtered.where((p) => p.zone == 'merah').toList();
        break;
      case 'Zona Kuning':
        filtered = filtered.where((p) => p.zone == 'kuning').toList();
        break;
      case 'Zona Hijau':
        filtered = filtered.where((p) => p.zone == 'hijau').toList();
        break;
    }

    for (final patient in filtered) {
      if (patient.domicileLat == null || patient.domicileLng == null) continue;

      final hue = _getMarkerHue(patient.zone);
      newMarkers.add(
        Marker(
          markerId: MarkerId(patient.id),
          position: LatLng(patient.domicileLat!, patient.domicileLng!),
          icon: BitmapDescriptor.defaultMarkerWithHue(hue),
          infoWindow: InfoWindow(
            title: 'Pasien ${patient.id.substring(0, 8)}',
            snippet: 'Zona: ${patient.zone ?? "-"}',
          ),
        ),
      );
    }

    markers.assignAll(newMarkers);
  }

  double _getMarkerHue(String? zone) {
    switch (zone) {
      case 'merah':
        return BitmapDescriptor.hueRed;
      case 'kuning':
        return BitmapDescriptor.hueYellow;
      case 'hijau':
        return BitmapDescriptor.hueGreen;
      default:
        return BitmapDescriptor.hueOrange;
    }
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
