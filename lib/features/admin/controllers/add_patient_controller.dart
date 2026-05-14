import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      // Logic to save to Supabase would go here
      await Future.delayed(const Duration(seconds: 1)); // Simulate network request
      
      Get.snackbar('Sukses', 'Data pasien berhasil disimpan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900);
      
      // Reset form
      nameController.clear();
      nikController.clear();
      phoneController.clear();
      dateController.clear();
      selectedPuskesmas.value = null;
      _generatePatientId();
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data pasien',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}
