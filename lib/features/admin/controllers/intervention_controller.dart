import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import '../../../app/config/app_constants.dart';

class InterventionController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = false.obs;
  final patients = <PatientModel>[].obs;
  final selectedTabIndex = 0.obs;

  // Pesan
  final selectedPatientId = ''.obs;
  final messageType = 'pengingat'.obs;
  final messageController = TextEditingController();

  // Zona
  final selectedArea = ''.obs;
  final selectedZoneLevel = AppConstants.zoneMerah.obs;

  // Kunjungan
  final visitPatientId = ''.obs;
  final visitNotesController = TextEditingController();
  final visitDate = Rx<DateTime?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadPatients();
  }

  @override
  void onClose() {
    messageController.dispose();
    visitNotesController.dispose();
    super.onClose();
  }

  Future<void> _loadPatients() async {
    try {
      final result = await _supabase.getActivePatients();
      patients.assignAll(result);
    } catch (_) {
      // Silently fail
    }
  }

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  // ─── Kirim Pesan ──────────────────────────────────────

  Future<void> sendMessage() async {
    if (selectedPatientId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih pasien terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (messageController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Isi pesan tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final adminId = _supabase.currentUser?.id ?? '';
      await _supabase.sendNotification(
        patientId: selectedPatientId.value,
        sentBy: adminId,
        title: 'Pesan dari Petugas',
        message: messageController.text.trim(),
      );

      await _supabase.logIntervention(
        adminId: adminId,
        patientId: selectedPatientId.value,
        type: AppConstants.interventionPesan,
        notes: messageController.text.trim(),
      );

      messageController.clear();
      Get.snackbar(
        'Berhasil',
        'Pesan berhasil dikirim',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mengirim pesan. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Tandai Zona ──────────────────────────────────────

  Future<void> markZone() async {
    if (selectedArea.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih area terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Update all patients in the area
      final adminId = _supabase.currentUser?.id ?? '';
      await _supabase.logIntervention(
        adminId: adminId,
        patientId: '',
        type: AppConstants.interventionZona,
        zoneMarked: selectedZoneLevel.value,
        notes: 'Tandai zona ${selectedZoneLevel.value} untuk ${selectedArea.value}',
      );

      Get.snackbar(
        'Berhasil',
        'Zona berhasil ditandai',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menandai zona. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ─── Catat Kunjungan ──────────────────────────────────

  Future<void> saveVisit() async {
    if (visitPatientId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Pilih pasien terlebih dahulu',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      final adminId = _supabase.currentUser?.id ?? '';
      await _supabase.logIntervention(
        adminId: adminId,
        patientId: visitPatientId.value,
        type: AppConstants.interventionKunjungan,
        notes: visitNotesController.text.trim(),
      );

      visitNotesController.clear();
      visitDate.value = null;
      Get.snackbar(
        'Berhasil',
        'Kunjungan berhasil dicatat',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal mencatat kunjungan. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectVisitDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      visitDate.value = picked;
    }
  }
}
