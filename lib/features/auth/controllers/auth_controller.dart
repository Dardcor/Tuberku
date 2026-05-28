<<<<<<< HEAD
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

  String get fullCode {
    return codeControllers.map((c) => c.text).join();
  }

  // Registration
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneRegisterController = TextEditingController();
  final passwordController = TextEditingController();
  final isObscure = true.obs;
  final isRegistering = false.obs;

  @override
  void onClose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    phoneRegisterController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneRegisterController.text.trim();
    final password = passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Semua field wajib diisi',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    if (password.length < 6) {
      Get.snackbar('Error', 'Password minimal 6 karakter',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
      return;
    }

    isRegistering.value = true;

    try {
      final response = await _supabase.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
        },
      );

      if (response.user != null) {
        Get.snackbar('Berhasil', 'Akun berhasil dibuat. Silakan login.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
        
        Get.offAllNamed(AppRoutes.roleSelection);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendaftar: ${e.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    } finally {
      isRegistering.value = false;
    }
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

  void navigateToLogin() {
    Get.toNamed(AppRoutes.login);
  }

  void navigateToAdminDashboard() {
    Get.offAllNamed(AppRoutes.adminDashboard);
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }
}
=======
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
  final isActivating = false.obs;

  // GPS Consent
  final gpsConsent = false.obs;
  final isSubmittingConsent = false.obs;

  // Current patient
  final Rx<PatientModel?> currentPatient = Rx<PatientModel?>(null);

  final codeControllers = List.generate(6, (_) => TextEditingController());
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final isObscure = true.obs;
  final isObscureConfirm = true.obs;

  String get fullCode {
    return codeControllers.map((c) => c.text).join();
  }

  // Registration
  final nameController = TextEditingController();
  final emailRegisterController = TextEditingController();
  final passwordRegisterController = TextEditingController();
  final isRegistering = false.obs;

  @override
  void onClose() {
    for (final controller in codeControllers) {
      controller.dispose();
    }
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    nameController.dispose();
    emailRegisterController.dispose();
    passwordRegisterController.dispose();
    super.onClose();
  }

  Future<void> activateAccount() async {
    final code = fullCode;
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (code.length != 6) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Masukkan 6 digit kode aktivasi', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return;
    }

    if (email.isEmpty || !GetUtils.isEmail(email)) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Masukkan alamat email yang valid', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return;
    }

    if (password.length < 6) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Password minimal 6 karakter', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return;
    }
    
    if (password != confirmPassword) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Konfirmasi password tidak cocok', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      return;
    }

    isActivating.value = true;

    try {
      String? userId;
      try {
        final authResponse = await _supabase.signUp(email: email, password: password);
        if (authResponse.user != null) {
          userId = authResponse.user!.id;
          await _supabase.upsertProfile(UserModel(
            id: userId,
            role: AppConstants.rolePasien,
            fullName: '',
            phone: '', // Pass empty string because phone is required in UserModel
            createdAt: DateTime.now(),
          ));
        }
      } catch (e) {
        if (e.toString().contains('already registered') || e.toString().contains('User already exists')) {
          final signInResponse = await _supabase.signIn(email: email, password: password);
          userId = signInResponse.user?.id;
        } else {
          rethrow;
        }
      }
      
      if (userId != null) {
          final success = await _supabase.activatePatient(code, userId);
          if (!success) {
            if (Get.isSnackbarOpen) return;
            Get.snackbar('Error', 'Gagal mengaktifkan pasien. Kode tidak valid atau sudah digunakan.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
            return;
          }
          Get.snackbar('Berhasil', 'Akun berhasil diaktivasi.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
          Get.offAllNamed(AppRoutes.consentGps);
      } else {
         if (Get.isSnackbarOpen) return;
         Get.snackbar('Error', 'Gagal membuat kredensial akun.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
      }
    } catch (e) {
      debugPrint('[AuthController] activateAccount error: $e');
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Terjadi kesalahan saat aktivasi.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isActivating.value = false;
    }
  }

  Future<void> submitGpsConsent() async {
    if (!gpsConsent.value) return;
    isSubmittingConsent.value = true;
    try {
      if (currentPatient.value != null) {
        await _supabase.updateGpsConsent(currentPatient.value!.id, consent: true);
      }
      Get.offAllNamed(AppRoutes.patientDashboard);
    } catch (e) {
      if (Get.isSnackbarOpen) return;
      Get.snackbar('Error', 'Gagal menyimpan persetujuan.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.red.shade100);
    } finally {
      isSubmittingConsent.value = false;
    }
  }

  void navigateToActivation() => Get.toNamed(AppRoutes.activation);
  void navigateToLogin() => Get.toNamed(AppRoutes.login);
  void navigateToAdminDashboard() => Get.offAllNamed(AppRoutes.adminDashboard);
}
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
