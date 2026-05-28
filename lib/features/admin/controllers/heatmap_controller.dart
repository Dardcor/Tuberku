<<<<<<< HEAD
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

  // Bottom Sheet Data
  final selectedDistrict = 'Genteng'.obs;
  final districts = ['Genteng', 'Wonokromo', 'Gubeng'].obs;
  
  // Dummy data for presentation
  final districtStats = {
    'Genteng': {'active': 14, 'adherence': 68, 'tracing': 3},
    'Wonokromo': {'active': 21, 'adherence': 82, 'tracing': 5},
    'Gubeng': {'active': 8, 'adherence': 91, 'tracing': 1},
  }.obs;

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

  void setDistrict(String district) {
    selectedDistrict.value = district;
    // Animate map to district center could be added here
  }

  void _buildMarkers() {
    final newMarkers = <Marker>{};
    
    // Default location (Surabaya)
    final centerLat = -7.250445;
    final centerLng = 112.768845;

    // Create dummy markers for presentation based on the image
    newMarkers.add(_createCustomMarker('m1', centerLat + 0.01, centerLng - 0.01, '14', BitmapDescriptor.hueRed));
    newMarkers.add(_createCustomMarker('m2', centerLat - 0.02, centerLng + 0.01, '7', BitmapDescriptor.hueYellow));
    newMarkers.add(_createCustomMarker('m3', centerLat + 0.03, centerLng + 0.02, '3', BitmapDescriptor.hueGreen));
    newMarkers.add(_createCustomMarker('m4', centerLat - 0.01, centerLng + 0.03, '9', BitmapDescriptor.hueGreen));

    markers.assignAll(newMarkers);
  }

  Marker _createCustomMarker(String id, double lat, double lng, String count, double hue) {
    return Marker(
      markerId: MarkerId(id),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(title: '$count Kasus'),
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
=======
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
    
    // Hilangkan semua label POI (Tempat umum) dan Transit agar peta bersih
    const String mapStyle = '''
    [
      {
        "featureType": "poi",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "transit",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
    ''';
    
    controller.setMapStyle(mapStyle);
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
