import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/facility_model.dart';

class LocationService extends GetxService {
  Future<LocationService> init() async {
    return this;
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
