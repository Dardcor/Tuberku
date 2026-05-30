import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import '../controllers/heatmap_controller.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/add_patient_controller.dart';

class PatientDetailController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = false.obs;
  final patient = Rxn<PatientModel>();

  // Form Fields
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final dateController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();

  final selectedPuskesmas = Rxn<String>();
  final selectedTbType = Rxn<String>();
  final selectedDistrict = Rxn<String>();
  final selectedZone = 'hijau'.obs;
  final isActive = true.obs;

  // Google Maps support
  final markers = <Marker>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is PatientModel) {
      setPatient(arg);
    }
    latController.addListener(_updateMarkerFromText);
    lngController.addListener(_updateMarkerFromText);
  }

  @override
  void onClose() {
    latController.removeListener(_updateMarkerFromText);
    lngController.removeListener(_updateMarkerFromText);
    nameController.dispose();
    nikController.dispose();
    phoneController.dispose();
    addressController.dispose();
    dateController.dispose();
    latController.dispose();
    lngController.dispose();
    super.onClose();
  }

  void updatePosition(LatLng position) {
    latController.removeListener(_updateMarkerFromText);
    lngController.removeListener(_updateMarkerFromText);
    
    latController.text = position.latitude.toStringAsFixed(6);
    lngController.text = position.longitude.toStringAsFixed(6);
    
    markers.assign(
      Marker(
        markerId: const MarkerId('selected_domicile'),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    latController.addListener(_updateMarkerFromText);
    lngController.addListener(_updateMarkerFromText);
  }

  void _updateMarkerFromText() {
    final lat = double.tryParse(latController.text);
    final lng = double.tryParse(lngController.text);
    if (lat != null && lng != null) {
      markers.assign(
        Marker(
          markerId: const MarkerId('selected_domicile'),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
  }

  void setPatient(PatientModel p) {
    patient.value = p;
    nameController.text = p.fullName ?? '';
    nikController.text = p.nik ?? '';
    phoneController.text = p.phone ?? '';
    addressController.text = p.address ?? '';
    latController.text = p.domicileLat?.toString() ?? '';
    lngController.text = p.domicileLng?.toString() ?? '';
    
    if (p.diagnosisDate != null) {
      dateController.text = '${p.diagnosisDate!.month}/${p.diagnosisDate!.day}/${p.diagnosisDate!.year}';
    } else {
      dateController.text = '';
    }

    // Safety fallback/normalization to avoid Dropdown assertion errors
    String? facility = p.facilityName;
    if (facility != null && !AddPatientController.surabayaTimurFaskes.contains(facility)) {
      facility = null;
    }
    selectedPuskesmas.value = facility;

    String? tb = p.tbType;
    const validTbTypes = ['BTA+', 'BTA-', 'TBC Anak', 'Ekstra Paru', 'MDR'];
    if (tb != null && !validTbTypes.contains(tb)) {
      tb = null;
    }
    selectedTbType.value = tb;

    String? dist = p.district;
    if (dist != null) {
      if (dist.startsWith('Kecamatan ')) {
        dist = dist.replaceAll('Kecamatan ', '');
      }
      dist = dist.trim();
      if (!AddPatientController.surabayaTimurDistricts.contains(dist)) {
        dist = null;
      }
    }
    selectedDistrict.value = dist;

    // Load initial marker if lat/lng are present
    final dLat = p.domicileLat;
    final dLng = p.domicileLng;
    if (dLat != null && dLng != null) {
      markers.assign(
        Marker(
          markerId: const MarkerId('selected_domicile'),
          position: LatLng(dLat, dLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    } else {
      markers.clear();
    }

    selectedZone.value = p.zone ?? 'hijau';
    isActive.value = p.isActive;
  }



  Future<void> updatePatientData() async {
    final current = patient.value;
    if (current == null) return;

    if (nameController.text.isEmpty || nikController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Nama, NIK, dan Telepon wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading.value = true;
    try {
      DateTime? diagnosisDate;
      if (dateController.text.isNotEmpty) {
        final parts = dateController.text.split('/');
        if (parts.length == 3) {
          diagnosisDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        }
      }

      final data = {
        'full_name': nameController.text.trim(),
        'nik': nikController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'facility_name': selectedPuskesmas.value,
        'district': selectedDistrict.value,
        'tb_type': selectedTbType.value ?? 'BTA+',
        'zone': selectedZone.value,
        'is_active': isActive.value,
        'domicile_lat': double.tryParse(latController.text.trim()),
        'domicile_lng': double.tryParse(lngController.text.trim()),
        if (diagnosisDate != null) 'diagnosis_date': diagnosisDate.toIso8601String(),
      };

      await _supabase.updatePatient(current.id, data);

      // Re-fetch patient data from db to update the view
      final updatedResult = await _supabase.client
          .from('patients')
          .select()
          .eq('id', current.id)
          .single();
      
      final updatedPatient = PatientModel.fromJson(updatedResult);
      patient.value = updatedPatient;

      // Refresh Heatmap and Dashboard data to reflect updates immediately
      if (Get.isRegistered<HeatmapController>()) {
        Get.find<HeatmapController>().refresh();
      }
      if (Get.isRegistered<AdminDashboardController>()) {
        Get.find<AdminDashboardController>().refresh();
      }

      Get.defaultDialog(
        title: 'Berhasil',
        content: const Text('Data pasien berhasil diperbarui'),
        confirm: TextButton(
          onPressed: () {
            Get.back(); // close dialog
            Get.back(); // return to detail screen
          },
          child: const Text('OK'),
        ),
      );
    } catch (e) {
      Get.snackbar('Gagal Memperbarui', 'Terjadi kesalahan: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}
