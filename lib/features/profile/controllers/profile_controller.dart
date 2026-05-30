<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';
import '../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final user = _supabase.client.auth.currentUser;
      if (user != null) {
        final profile = await _supabase.getProfile(user.id);
        userProfile.value = profile;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.client.auth.signOut();
      Get.offAllNamed(AppRoutes.roleSelection);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: ${e.toString()}');
    }
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/models/user_model.dart';
import '../../../core/models/patient_model.dart';
import '../../../app/routes/app_routes.dart';

class ProfileController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final isLoading = true.obs;
  final Rx<UserModel?> userProfile = Rx<UserModel?>(null);
  final Rx<PatientModel?> patientData = Rx<PatientModel?>(null);

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    try {
      final user = _supabase.client.auth.currentUser;
      if (user != null) {
        final profile = await _supabase.getProfile(user.id);
        userProfile.value = profile;
        if (profile?.role == 'patient') {
          patientData.value = await _supabase.getPatientByProfileId(user.id);
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat profil: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.client.auth.signOut();
      Get.offAllNamed(AppRoutes.roleSelection);
    } catch (e) {
      Get.snackbar('Error', 'Gagal logout: ${e.toString()}');
    }
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
