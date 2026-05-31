import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/facility_model.dart';
import '../models/tracing_model.dart';
import '../models/patient_model.dart';
import 'supabase_service.dart';

class LocationService extends GetxService {
  Timer? _trackingTimer;
  PatientModel? _cachedPatient;

  Future<LocationService> init() async {
    startPeriodicTracking();
    return this;
  }

  @override
  void onClose() {
    stopPeriodicTracking();
    super.onClose();
  }

  void startPeriodicTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(const Duration(seconds: 5), (timer) async {
      await _trackAndUploadLocation();
    });
  }

  void stopPeriodicTracking() {
    _trackingTimer?.cancel();
    _trackingTimer = null;
    _cachedPatient = null;
  }

  void resetTrackingCache() {
    _cachedPatient = null;
  }

  Future<void> _trackAndUploadLocation() async {
    try {
      final supabase = Get.find<SupabaseService>();
      final currentUser = supabase.currentUser;
      if (currentUser == null) {
        _cachedPatient = null;
        debugPrint('[LocationService] No user logged in, skipping tracking');
        return;
      }

      // Selalu re-fetch patient data agar gps_consent selalu up-to-date
      // (tidak di-cache permanen, karena consent bisa berubah kapan saja)
      if (_cachedPatient == null) {
        final profile = await supabase.getProfile(currentUser.id);
        if (profile == null) {
          debugPrint('[LocationService] Profile not found for user ${currentUser.id}');
          return;
        }

        final role = (profile.role ?? '').toLowerCase().trim();
        final isPatient = role == 'patient' || role == 'pasien';
        if (!isPatient) {
          debugPrint('[LocationService] User role is "$role", not a patient — skipping');
          return;
        }

        final patient = await supabase.getPatientByProfileId(currentUser.id);
        if (patient == null) {
          debugPrint('[LocationService] No patient record found for profile ${currentUser.id}');
          return;
        }
        if (!patient.gpsConsent) {
          debugPrint('[LocationService] Patient ${patient.id} has gps_consent=false — skipping tracking');
          return;
        }
        _cachedPatient = patient;
        debugPrint('[LocationService] Patient loaded: ${patient.fullName}, gpsConsent=${patient.gpsConsent}');
      }

      // Upload lokasi
      final position = await getCurrentPosition();
      if (position == null) {
        debugPrint('[LocationService] Could not get GPS position');
        return;
      }

      final placeName =
          'Lat ${position.latitude.toStringAsFixed(5)}, Lng ${position.longitude.toStringAsFixed(5)}';

      final log = TracingModel(
        id: '',
        patientId: _cachedPatient!.id,
        tracingRef: 'TRC-${DateTime.now().millisecondsSinceEpoch ~/ 1000}',
        latitude: position.latitude,
        longitude: position.longitude,
        placeName: placeName,
        visitedAt: DateTime.now().toUtc(),
        createdAt: DateTime.now().toUtc(),
      );

      await supabase.insertTracingLog(log);
      debugPrint('[LocationService] ✅ Uploaded location: $placeName');

      // Hapus log lebih dari 10 menit
      await supabase.deleteOldTracingLogs(_cachedPatient!.id);
    } catch (e) {
      debugPrint('[LocationService] _trackAndUploadLocation error: $e');
    }
  }

  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return false;
    }

    if (permission == LocationPermission.deniedForever) return false;

    return true;
  }

  Future<Position?> getCurrentPosition() async {
    final hasPermission = await requestPermission();
    if (!hasPermission) return null;

    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (_) {
      return null;
    }
  }

  List<FacilityModel> getNearestFacilities(
    List<FacilityModel> facilities,
    Position position,
  ) {
    for (final facility in facilities) {
      final distanceMeters = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        facility.latitude,
        facility.longitude,
      );
      facility.distanceKm = distanceMeters / 1000;
    }
    facilities.sort((a, b) {
      final aDist = a.distanceKm ?? double.infinity;
      final bDist = b.distanceKm ?? double.infinity;
      return aDist.compareTo(bDist);
    });
    return facilities;
  }

  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}
