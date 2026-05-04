import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/location_service.dart';
import '../../../core/models/facility_model.dart';

class FacilityMapController extends GetxController {
  final _supabase = Get.find<SupabaseService>();
  final _location = Get.find<LocationService>();

  final isLoading = true.obs;
  final facilities = <FacilityModel>[].obs;
  final filteredFacilities = <FacilityModel>[].obs;
  final markers = <Marker>{}.obs;
  final selectedFilter = 'Terdekat'.obs;
  final hasError = false.obs;

  final filters = ['Terdekat', 'Rifampicin', 'Isoniazid', 'FDC'];

  final Rx<Position?> userPosition = Rx<Position?>(null);
  final Rx<FacilityModel?> selectedFacility = Rx<FacilityModel?>(null);

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
      // Get user location
      userPosition.value = await _location.getCurrentPosition();

      // Get facilities from Supabase
      final result = await _supabase.getFacilities();

      // Calculate distances if position available
      if (userPosition.value != null) {
        _location.getNearestFacilities(result, userPosition.value!);
      }

      facilities.assignAll(result);
      _applyFilter();
      _buildMarkers();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
    _buildMarkers();
  }

  void _applyFilter() {
    var result = facilities.toList();

    switch (selectedFilter.value) {
      case 'Rifampicin':
        result =
            result.where((f) => f.rifampicinStatus == 'tersedia').toList();
        break;
      case 'Isoniazid':
        result =
            result.where((f) => f.isoniazidStatus == 'tersedia').toList();
        break;
      case 'FDC':
        result = result.where((f) => f.fdcStatus == 'tersedia').toList();
        break;
      case 'Terdekat':
      default:
        // Already sorted by distance
        break;
    }

    filteredFacilities.assignAll(result);
  }

  void _buildMarkers() {
    final newMarkers = <Marker>{};

    for (final facility in filteredFacilities) {
      newMarkers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude, facility.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            facility.hasStock
                ? BitmapDescriptor.hueGreen
                : BitmapDescriptor.hueRed,
          ),
          infoWindow: InfoWindow(
            title: facility.name,
            snippet: facility.formattedDistance,
          ),
          onTap: () => selectFacility(facility),
        ),
      );
    }

    markers.assignAll(newMarkers);
  }

  void selectFacility(FacilityModel facility) {
    selectedFacility.value = facility;
  }

  void onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  LatLng get initialCameraPosition {
    if (userPosition.value != null) {
      return LatLng(
        userPosition.value!.latitude,
        userPosition.value!.longitude,
      );
    }
    // Default: Surabaya
    return const LatLng(-7.2575, 112.7521);
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
