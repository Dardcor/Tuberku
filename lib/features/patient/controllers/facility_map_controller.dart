<<<<<<< HEAD
=======
<<<<<<< HEAD
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
      final isApotek = facility.type.toLowerCase().contains('apotek') || 
                       facility.name.toLowerCase().contains('apotek');
      
      newMarkers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude, facility.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isApotek 
                ? BitmapDescriptor.hueAzure // Blue for Pharmacies
                : (facility.hasStock
                    ? BitmapDescriptor.hueGreen // Green for Medical with stock
                    : BitmapDescriptor.hueRed), // Red for Medical without stock
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
    _fitMarkers();
  }

  void _fitMarkers() {
    if (markers.isEmpty || mapController == null) return;

    List<LatLng> points = markers.map((m) => m.position).toList();
    if (userPosition.value != null) {
      points.add(LatLng(userPosition.value!.latitude, userPosition.value!.longitude));
    }

    if (points.isEmpty) return;

    LatLngBounds bounds = _boundsFromLatLngList(points);
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) minLat = latLng.latitude;
      if (maxLat == null || latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (minLng == null || latLng.longitude < minLng) minLng = latLng.longitude;
      if (maxLng == null || latLng.longitude > maxLng) maxLng = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  LatLng get initialCameraPosition {
    if (userPosition.value != null) {
      return LatLng(
        userPosition.value!.latitude,
        userPosition.value!.longitude,
      );
    }
    
    if (filteredFacilities.isNotEmpty) {
      return LatLng(
        filteredFacilities.first.latitude,
        filteredFacilities.first.longitude,
      );
    }
    
    // Default: Bandung center
    return const LatLng(-6.9175, 107.6191);
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
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

  final filters = ['Terdekat', 'Puskesmas', 'Klinik', 'Apotek'];

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
      userPosition.value = await _location.getCurrentPosition();
      final result = await _supabase.getFacilities();

      if (userPosition.value != null) {
        _location.getNearestFacilities(result, userPosition.value!);
      }

      facilities.assignAll(result);
      _applyFilter();
    } catch (_) {
      hasError.value = true;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    _applyFilter();
  }

  void _applyFilter() {
    var result = facilities.toList();

    // 1. Filter by proximity (within 50km) if user position is available
    if (userPosition.value != null) {
      result = result.where((f) {
        final distance = Geolocator.distanceBetween(
          userPosition.value!.latitude,
          userPosition.value!.longitude,
          f.latitude,
          f.longitude,
        );
        return distance <= 50000; // 50km
      }).toList();
    }

    // 2. Filter by type
    switch (selectedFilter.value) {
      case 'Puskesmas':
        result = result.where((f) => f.type.toLowerCase().contains('puskesmas')).toList();
        break;
      case 'Klinik':
        result = result.where((f) => f.type.toLowerCase().contains('klinik')).toList();
        break;
      case 'Apotek':
        result = result.where((f) => f.type.toLowerCase().contains('apotek')).toList();
        break;
      case 'Terdekat':
      default:
        // Already sorted by distance in _loadData
        break;
    }

    filteredFacilities.assignAll(result);
    _buildMarkers();
  }

  void _buildMarkers() {
    final newMarkers = <Marker>{};

    for (final facility in filteredFacilities) {
      final isApotek = facility.type.toLowerCase().contains('apotek') || 
                       facility.name.toLowerCase().contains('apotek');
      
      newMarkers.add(
        Marker(
          markerId: MarkerId(facility.id),
          position: LatLng(facility.latitude, facility.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            isApotek 
                ? BitmapDescriptor.hueAzure 
                : BitmapDescriptor.hueGreen 
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
    _fitMarkers();
  }

  void _fitMarkers() {
    if (markers.isEmpty || mapController == null) return;

    List<LatLng> points = markers.map((m) => m.position).toList();
    if (userPosition.value != null) {
      points.add(LatLng(userPosition.value!.latitude, userPosition.value!.longitude));
    }

    if (points.isEmpty) return;

    LatLngBounds bounds = _boundsFromLatLngList(points);
    mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? minLat, maxLat, minLng, maxLng;
    for (final latLng in list) {
      if (minLat == null || latLng.latitude < minLat) minLat = latLng.latitude;
      if (maxLat == null || latLng.latitude > maxLat) maxLat = latLng.latitude;
      if (minLng == null || latLng.longitude < minLng) minLng = latLng.longitude;
      if (maxLng == null || latLng.longitude > maxLng) maxLng = latLng.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

  LatLng get initialCameraPosition {
    if (userPosition.value != null) {
      return LatLng(userPosition.value!.latitude, userPosition.value!.longitude);
    }
    
    if (filteredFacilities.isNotEmpty) {
      return LatLng(filteredFacilities.first.latitude, filteredFacilities.first.longitude);
    }
    
    return const LatLng(-7.250445, 112.768845);
  }

  Future<void> refresh() async {
    await _loadData();
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
