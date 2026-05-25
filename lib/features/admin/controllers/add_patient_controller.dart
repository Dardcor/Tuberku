import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import 'dart:math';

class AddPatientController extends GetxController {
  final _supabase = Get.find<SupabaseService>();
  
  final patientIdController = TextEditingController();
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final phoneController = TextEditingController();
  final dateController = TextEditingController();
  
  final selectedPuskesmas = Rx<String?>(null);
  final isGpsEnabled = true.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _generatePatientId();
  }

  void _generatePatientId() {
    final random = Random().nextInt(9000) + 1000;
    patientIdController.text = 'TB-2023-$random';
  }

  @override
  void onClose() {
    patientIdController.dispose();
    nameController.dispose();
    nikController.dispose();
    phoneController.dispose();
    dateController.dispose();
    super.onClose();
  }

  Future<void> savePatient() async {
    if (nameController.text.isEmpty || nikController.text.isEmpty || phoneController.text.isEmpty) {
      Get.snackbar('Error', 'Harap lengkapi semua data wajib', 
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100);
      return;
    }

    isLoading.value = true;
    try {
      // Generate 6-digit random activation code
      final random = Random();
      final activationCode = List.generate(6, (index) => random.nextInt(10)).join();
      
      // Save to Supabase
      await _supabase.client.from('patients').insert({
        'profile_id': null, // Will be set by patient during activation
        'activation_code': activationCode,
        'address': '', // You might want to add field for this
        'diagnosis_date': dateController.text,
        'tb_type': 'BTA+', // Default or from UI
      });
      
      Get.defaultDialog(
        title: 'Pasien Berhasil Didaftarkan',
        content: Column(
          children: [
            Text('Kode Aktivasi Pasien:'),
            Text(activationCode, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)),
            Text('Berikan kode ini kepada pasien untuk aktivasi akun mereka.'),
          ],
        ),
        confirm: TextButton(onPressed: () => Get.back(), child: Text('OK')),
      );
      
      // Reset form
      nameController.clear();
      nikController.clear();
      phoneController.clear();
      dateController.clear();
      selectedPuskesmas.value = null;
      _generatePatientId();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data pasien: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}
