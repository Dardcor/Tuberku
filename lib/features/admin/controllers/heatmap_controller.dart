import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import '../controllers/add_patient_controller.dart';

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

      // Fetch zones from db
      final zonesList = await _supabase.getZones();

      // Fetch tracing logs to calculate tracing count per district
      final tracingLogs = await _supabase.getTracingLogs();
      
      _calculateStats(zonesList, tracingLogs);
      _buildMarkers();
    } catch (e) {
      debugPrint('[HeatmapController] loadData error: $e');
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats(List<Map<String, dynamic>> zones, List<dynamic> tracingLogs) {
    final stats = <String, Map<String, int>>{};
    final uniqueDistricts = <String>{...AddPatientController.surabayaTimurDistricts};
    
    // Inisialisasi semua kecamatan dasar dengan nilai 0
    for (final dist in uniqueDistricts) {
      stats[dist] = {'active': 0, 'recovered': 0, 'tracing': 0};
    }
    stats['Semua'] = {'active': 0, 'recovered': 0, 'tracing': 0};
    
    for (final p in patients) {
      String dist = p.district ?? 'Lainnya';
      if (dist.startsWith('Kecamatan ')) {
        dist = dist.replaceAll('Kecamatan ', '');
      }
      
      if (!stats.containsKey(dist)) {
        stats[dist] = {'active': 0, 'recovered': 0, 'tracing': 0};
      }
      
      if (p.isActive) {
        stats[dist]!['active'] = (stats[dist]!['active'] ?? 0) + 1;
        stats['Semua']!['active'] = (stats['Semua']!['active'] ?? 0) + 1;
      } else {
        stats[dist]!['recovered'] = (stats[dist]!['recovered'] ?? 0) + 1;
        stats['Semua']!['recovered'] = (stats['Semua']!['recovered'] ?? 0) + 1;
      }
    }

    // Count tracing logs per district
    for (final log in tracingLogs) {
      final patient = patients.firstWhereOrNull((p) => p.id == log.patientId);
      if (patient != null) {
        String dist = patient.district ?? 'Lainnya';
        if (dist.startsWith('Kecamatan ')) {
          dist = dist.replaceAll('Kecamatan ', '');
        }
        if (stats.containsKey(dist)) {
          stats[dist]!['tracing'] = (stats[dist]!['tracing'] ?? 0) + 1;
        }
        stats['Semua']!['tracing'] = (stats['Semua']!['tracing'] ?? 0) + 1;
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
      String pDistrict = p.district ?? 'Lainnya';
      if (pDistrict.startsWith('Kecamatan ')) {
        pDistrict = pDistrict.replaceAll('Kecamatan ', '');
      }
      if (selectedDistrict.value != 'Semua' && pDistrict != selectedDistrict.value) continue;

      if (p.domicileLat != null && p.domicileLng != null) {
        double hue = BitmapDescriptor.hueRed;
        if (p.zone == 'kuning') hue = BitmapDescriptor.hueYellow;
        if (p.zone == 'hijau') hue = BitmapDescriptor.hueGreen;
        
        // Pengecualian warna jika pasien sudah sembuh (biru/cyan)
        if (!p.isActive) hue = BitmapDescriptor.hueCyan;
        
        newMarkers.add(_createCustomMarker(
          p, 
          p.domicileLat!, 
          p.domicileLng!, 
          p.fullName ?? 'Pasien', 
          hue
        ));
      }
    }

    markers.assignAll(newMarkers);
  }

  Marker _createCustomMarker(PatientModel patient, double lat, double lng, String title, double hue) {
    return Marker(
      markerId: MarkerId(patient.id),
      position: LatLng(lat, lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      infoWindow: InfoWindow(
        title: title,
        snippet: 'Ketuk untuk lihat detail',
        onTap: () {
          Get.toNamed('/admin/patient/detail', arguments: patient);
        },
      ),
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
