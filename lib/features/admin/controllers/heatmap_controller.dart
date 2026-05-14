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
