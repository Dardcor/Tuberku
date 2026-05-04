import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/patient_model.dart';
import '../../../core/models/user_model.dart';
import '../../../app/config/app_constants.dart';
import '../../../app/routes/app_routes.dart';

class AuthController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  // Activation
  final activationCode = ''.obs;
  final phoneNumber = ''.obs;
  final isActivating = false.obs;

  // GPS Consent
  final gpsConsent = false.obs;
  final isSubmittingConsent = false.obs;

  // Current patient
  final Rx<PatientModel?> currentPatient = Rx<PatientModel?>(null);

  final codeControllers = List.generate(6, (_) => TextEditingController());
  final phoneController = TextEditingController();

  @override
  void onClose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    phoneController.dispose();
    super.onClose();
  }

  String get fullCode {
    return codeControllers.map((c) => c.text).join();
  }

  Future<void> activateAccount() async {
    final code = fullCode;
    final phone = phoneController.text.trim();

    if (code.length != 6) {
      Get.snackbar(
        'Error',
        'Masukkan 6 digit kode aktivasi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    if (phone.isEmpty) {
      Get.snackbar(
        'Error',
        'Masukkan nomor HP',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isActivating.value = true;

    try {
      final patient = await _supabase.activatePatient(code);

      if (patient == null) {
        Get.snackbar(
          'Gagal',
          'Kode aktivasi tidak ditemukan. Hubungi petugas kesehatan Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
        );
        isActivating.value = false;
        return;
      }

      // Create auth user with phone as email-like identifier
      final email = '$phone@tuberku.local';
      final password = code;

      try {
        final authResponse = await _supabase.signUp(
          email: email,
          password: password,
        );

        if (authResponse.user != null) {
          // Create profile
          await _supabase.upsertProfile(UserModel(
            id: authResponse.user!.id,
            role: AppConstants.rolePasien,
            fullName: '',
            phone: phone,
            createdAt: DateTime.now(),
          ));
        }
      } catch (_) {
        // User might already exist, try sign in
        await _supabase.signIn(email: email, password: password);
      }

      currentPatient.value = patient;
      Get.offAllNamed(AppRoutes.consentGps);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Terjadi kesalahan. Coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isActivating.value = false;
    }
  }

  Future<void> submitGpsConsent() async {
    if (!gpsConsent.value) return;

    isSubmittingConsent.value = true;

    try {
      if (currentPatient.value != null) {
        await _supabase.updateGpsConsent(
          currentPatient.value!.id,
          consent: true,
        );
      }
      Get.offAllNamed(AppRoutes.patientDashboard);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal menyimpan persetujuan. Coba lagi.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isSubmittingConsent.value = false;
    }
  }

  void navigateToActivation() {
    Get.toNamed(AppRoutes.activation);
  }

  void navigateToAdminDashboard() {
    Get.offAllNamed(AppRoutes.adminDashboard);
  }
}
