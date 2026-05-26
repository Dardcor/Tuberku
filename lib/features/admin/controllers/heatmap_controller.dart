import 'package:flutter/foundation.dart';
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

  // Filter States
  final selectedZoneFilter = 'Semua'.obs;
  final selectedStatusFilter = 'Aktif'.obs; // Default lihat kasus aktif
  
  // Bottom Sheet Data
  final selectedDistrict = 'Semua'.obs;
  final districts = <String>[].obs;
  
  // Real data for presentation
  final districtStats = <String, Map<String, int>>{}.obs;

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
      final result = await _supabase.getPatients(); // Fetch ALL patients to get both active and recovered
      patients.assignAll(result);
      _calculateStats();
      _buildMarkers();
    } catch (e) {
      debugPrint('[HeatmapController] loadData error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    final stats = <String, Map<String, int>>{};
    
    // Daftar kecamatan bawaan (Default Surabaya)
    final uniqueDistricts = <String>{
      'Genteng', 
      'Wonokromo', 
      'Gubeng', 
      'Tegalsari', 
      'Tambaksari'
    };
    
    // Inisialisasi semua kecamatan dasar dengan nilai 0
    for (final dist in uniqueDistricts) {
      stats[dist] = {'active': 0, 'recovered': 0, 'tracing': 0};
    }
    
    for (final p in patients) {
      final dist = p.district ?? 'Lainnya';
      uniqueDistricts.add(dist);
      
      if (!stats.containsKey(dist)) {
        stats[dist] = {'active': 0, 'recovered': 0, 'tracing': 0};
      }
      
      if (p.isActive) {
        stats[dist]!['active'] = (stats[dist]!['active'] ?? 0) + 1;
      } else {
        stats[dist]!['recovered'] = (stats[dist]!['recovered'] ?? 0) + 1;
      }
    }
    
    final sortedDistricts = uniqueDistricts.toList()..sort();
    districts.assignAll(['Semua', ...sortedDistricts]);
    
    if (districts.isNotEmpty && (selectedDistrict.value == 'Semua' || !districts.contains(selectedDistrict.value))) {
      selectedDistrict.value = 'Semua';
    }
    districtStats.value = stats;
  }

  void setDistrict(String district) {
    selectedDistrict.value = district;
    _buildMarkers();
    // Animate map to district center could be added here
  }

  void setZoneFilter(String zone) {
    selectedZoneFilter.value = zone;
    _buildMarkers();
  }

  void setStatusFilter(String status) {
    selectedStatusFilter.value = status;
    _buildMarkers();
  }

  void _buildMarkers() {
    final newMarkers = <Marker>{};
    
    for (final p in patients) {
      // 1. Filter Status Kasus
      if (selectedStatusFilter.value == 'Aktif' && !p.isActive) continue;
      if (selectedStatusFilter.value == 'Sembuh' && p.isActive) continue;

      // 2. Filter Zona
      if (selectedZoneFilter.value != 'Semua' && (p.zone?.toLowerCase() ?? '') != selectedZoneFilter.value.toLowerCase()) continue;

      // 3. Filter Kecamatan
      final pDistrict = p.district ?? 'Lainnya';
      if (selectedDistrict.value != 'Semua' && pDistrict != selectedDistrict.value) continue;

      if (p.domicileLat != null && p.domicileLng != null) {
        double hue = BitmapDescriptor.hueRed;
        if (p.zone == 'kuning') hue = BitmapDescriptor.hueYellow;
        if (p.zone == 'hijau') hue = BitmapDescriptor.hueGreen;
        
        // Pengecualian warna jika pasien sudah sembuh (biru/cyan)
        if (!p.isActive) hue = BitmapDescriptor.hueCyan;
        
        newMarkers.add(_createCustomMarker(
          p.id, 
          p.domicileLat!, 
          p.domicileLng!, 
          p.fullName ?? 'Pasien', 
          hue
        ));
      }
    }

    markers.assignAll(newMarkers);
  }

  Marker _createCustomMarker(String id, double lat, double lng, String title, double hue) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(title: title),
    );
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
    // Set map style if needed
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
