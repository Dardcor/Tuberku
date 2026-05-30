import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';
import '../../../app/routes/app_routes.dart';

class AdminProfileController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final name = 'Memuat...'.obs;
  final email = ''.obs;
  final role = ''.obs;
  final facility = ''.obs;
  final nip = ''.obs;

  final supervisedPatients = 0.obs;
  final tracingsCompleted = 0.obs;

  // Edit Profile controllers
  final fullNameEditController = TextEditingController();
  final phoneEditController = TextEditingController();
  final nipEditController = TextEditingController();
  final facilityEditController = TextEditingController();
  final selectedFacility = Rx<String?>(null);
  final isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _loadStats();
  }

  @override
  void onClose() {
    fullNameEditController.dispose();
    phoneEditController.dispose();
    nipEditController.dispose();
    facilityEditController.dispose();
    super.onClose();
  }

  Future<void> _loadStats() async {
    try {
      final user = _supabase.currentUser;
      if (user != null) {
        supervisedPatients.value = await _supabase.countActivePatientsForOfficer(user.id);
      } else {
        supervisedPatients.value = 0;
      }
      
      // Menghitung jumlah tracing yang diselesaikan bulan ini (30 hari terakhir)
      final recentTracings = await _supabase.getRecentTracingLogs(days: 30);
      tracingsCompleted.value = recentTracings.length;
    } catch (e) {
      // Error handling diam-diam agar UI tidak crash
    }
  }

  Future<void> _loadProfile() async {
    final user = _supabase.currentUser;
    if (user != null) {
      email.value = user.email ?? '';
      final profile = await _supabase.getProfile(user.id);
      if (profile != null) {
        if (profile.fullName.isNotEmpty) {
          name.value = profile.fullName;
        } else {
          name.value = 'Petugas Tuberku';
        }
        
        if (profile.facilityName != null && profile.facilityName!.isNotEmpty) {
          facility.value = profile.facilityName!;
        }
        
        if (profile.role.isNotEmpty) {
          role.value = profile.role.toUpperCase() == 'ADMIN' 
              ? 'Petugas Surveilans TBC' 
              : profile.role;
        }

        if (profile.nip != null && profile.nip!.isNotEmpty) {
          nip.value = 'NIP. ${profile.nip}';
        } else {
          nip.value = '';
        }

        // Populate edit controllers
        fullNameEditController.text = profile.fullName;
        phoneEditController.text = profile.phone;
        nipEditController.text = profile.nip ?? '';
        facilityEditController.text = profile.facilityName ?? '';
        selectedFacility.value = profile.facilityName;
      } else {
        name.value = 'Petugas Tuberku';
      }
    }
  }

  Future<void> updateProfile() async {
    final user = _supabase.currentUser;
    if (user == null) return;
    
    if (fullNameEditController.text.trim().isEmpty) {
      Get.snackbar('Gagal Memperbarui', 'Nama lengkap wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }
    
    isUpdating.value = true;
    try {
      final currentProfile = await _supabase.getProfile(user.id);
      final updated = UserModel(
        id: user.id,
        role: currentProfile?.role ?? 'petugas',
        fullName: fullNameEditController.text.trim(),
        email: user.email ?? currentProfile?.email ?? '',
        phone: phoneEditController.text.trim(),
        facilityName: selectedFacility.value ?? '',
        nip: nipEditController.text.trim(),
        createdAt: currentProfile?.createdAt ?? DateTime.now(),
      );
      
      await _supabase.upsertProfile(updated);
      
      // Reload details
      await _loadProfile();
      
      Get.back(); // Close bottomsheet/dialog
      Get.snackbar('Berhasil', 'Profil Anda berhasil diperbarui',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100);
    } catch (e) {
      Get.snackbar('Gagal Memperbarui', 'Terjadi kesalahan: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    } finally {
      isUpdating.value = false;
    }
  }

  Future<void> logout() async {
    await _supabase.signOut();
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
