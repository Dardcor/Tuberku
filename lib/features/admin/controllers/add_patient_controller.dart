import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/config/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import 'heatmap_controller.dart';
import 'admin_dashboard_controller.dart';
import 'admin_profile_controller.dart';
import 'main_admin_controller.dart';
import 'dart:math';

class AddPatientController extends GetxController {
  final _supabase = Get.find<SupabaseService>();
  
  final patientIdController = TextEditingController();
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  
  final addressController = TextEditingController();
  final latController = TextEditingController();
  final lngController = TextEditingController();
  final selectedDistrict = Rx<String?>(null);
  
  final selectedPuskesmas = Rx<String?>(null);
  final selectedTbType = Rx<String?>(null);
  final isGpsEnabled = true.obs;
  final isLoading = false.obs;

  // Google Maps support
  final markers = <Marker>{}.obs;

  static const List<String> surabayaTimurDistricts = [
    'Gubeng',
    'Gunung Anyar',
    'Sukolilo',
    'Tambaksari',
    'Mulyorejo',
    'Rungkut',
    'Tenggilis Mejoyo',
  ];

  static const List<String> surabayaTimurFaskes = [
    'Puskesmas Mulyorejo',
    'Puskesmas Rungkut',
    'Puskesmas Kalirungkut',
    'Puskesmas Sukolilo',
    'Puskesmas Gunung Anyar',
    'Puskesmas Menur',
    'Puskesmas Gubeng Masjid',
    'Puskesmas Tambaksari',
    'Puskesmas Pacar Keling',
    'Puskesmas Gading',
  ];

  @override
  void onInit() {
    super.onInit();
    _generatePatientId();
    latController.addListener(_updateMarkerFromText);
    lngController.addListener(_updateMarkerFromText);
  }

  void updatePosition(LatLng position) {
    // Remove listeners temporarily to avoid circular triggers
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

  Future<void> _generatePatientId() async {
    final count = await _supabase.countPatients();
    final sequence = (count + 1).toString().padLeft(4, '0');
    patientIdController.text = 'TB-${DateTime.now().year}-$sequence';
  }

  @override
  void onClose() {
    patientIdController.dispose();
    nameController.dispose();
    nikController.dispose();
    phoneController.dispose();
    addressController.dispose();
    latController.dispose();
    lngController.dispose();
    dateController.dispose();
    super.onClose();
  }

  Future<void> savePatient() async {
    if (nameController.text.isEmpty || 
        nikController.text.isEmpty || 
        phoneController.text.isEmpty ||
        addressController.text.isEmpty ||
        latController.text.isEmpty ||
        lngController.text.isEmpty ||
        selectedDistrict.value == null ||
        selectedTbType.value == null ||
        selectedPuskesmas.value == null) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Harap lengkapi semua data wajib termasuk wilayah, faskes, tipe TB, dan domisili', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading.value = true;
    try {
      // Generate 6-digit random activation code
      final random = Random();
      final activationCode = List.generate(6, (index) => random.nextInt(10)).join();
      
      final user = _supabase.currentUser;

      // Save to Supabase with created_by field (fallback if column not migrated yet)
      try {
        await _supabase.client.from('patients').insert({
          'profile_id': null,
          'full_name': nameController.text.trim(),
          'nik': nikController.text.trim(),
          'phone': phoneController.text.trim(),
          'facility_name': selectedPuskesmas.value,
          'district': selectedDistrict.value,
          'activation_code': activationCode,
          'address': addressController.text.trim(),
          'domicile_lat': double.tryParse(latController.text.trim()),
          'domicile_lng': double.tryParse(lngController.text.trim()),
          'diagnosis_date': dateController.text,
          'tb_type': selectedTbType.value,
          'zone': 'hijau',
          'is_active': true,
          'created_by': user?.id,
        });
      } catch (e) {
        // Fallback: insert without created_by if database doesn't have the column yet
        if (e.toString().contains('created_by') || e.toString().contains('column')) {
          await _supabase.client.from('patients').insert({
            'profile_id': null,
            'full_name': nameController.text.trim(),
            'nik': nikController.text.trim(),
            'phone': phoneController.text.trim(),
            'facility_name': selectedPuskesmas.value,
            'district': selectedDistrict.value,
            'activation_code': activationCode,
            'address': addressController.text.trim(),
            'domicile_lat': double.tryParse(latController.text.trim()),
            'domicile_lng': double.tryParse(lngController.text.trim()),
            'diagnosis_date': dateController.text,
            'tb_type': selectedTbType.value,
            'zone': 'hijau',
            'is_active': true,
          });
        } else {
          rethrow;
        }
      }
      
      // Auto load new data by refreshing dashboard and map controllers
      if (Get.isRegistered<HeatmapController>()) {
        Get.find<HeatmapController>().refresh();
      }
      if (Get.isRegistered<AdminDashboardController>()) {
        Get.find<AdminDashboardController>().refresh();
      }
      if (Get.isRegistered<AdminProfileController>()) {
        Get.find<AdminProfileController>().onInit(); // refresh stats in profile
      }
      
      Get.defaultDialog(
        title: 'Pasien Berhasil Didaftarkan',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Kode Aktivasi Pasien:'),
            const SizedBox(height: 8),
            Text(activationCode, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('Berikan kode ini kepada pasien untuk aktivasi akun mereka.', textAlign: TextAlign.center),
          ],
        ),
        confirm: TextButton(
          onPressed: () {
            Get.back();
            if (Get.isRegistered<MainAdminController>()) {
              Get.find<MainAdminController>().changeTab(0);
            }
          },
          child: const Text('OK'),
        ),
      );
      
      // Reset form
      nameController.clear();
      nikController.clear();
      phoneController.clear();
      addressController.clear();
      latController.clear();
      lngController.clear();
      dateController.clear();
      selectedDistrict.value = null;
      selectedPuskesmas.value = null;
      selectedTbType.value = null;
      _generatePatientId();
    } catch (e) {
      Get.snackbar('Gagal Menyimpan', 'Terjadi kesalahan: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}
