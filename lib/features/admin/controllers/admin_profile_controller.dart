import 'package:get/get.dart';
import '../../../core/services/supabase_service.dart';
import '../../../app/routes/app_routes.dart';

class AdminProfileController extends GetxController {
  final _supabase = Get.find<SupabaseService>();

  final name = 'Memuat...'.obs;
  final email = ''.obs;
  final role = 'Petugas Surveilans TBC'.obs;
  final facility = 'Puskesmas Surabaya'.obs;
  final nip = 'NIP. 19850101 201001 1 001'.obs;

  final supervisedPatients = 0.obs;
  final tracingsCompleted = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      // Menghitung jumlah pasien yang saat ini diawasi
      supervisedPatients.value = await _supabase.countActivePatients();
      
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
        if (profile.fullName != null && profile.fullName!.isNotEmpty) {
          name.value = profile.fullName!;
        } else {
          name.value = 'Petugas Tuberku';
        }
        
        if (profile.facilityName != null && profile.facilityName!.isNotEmpty) {
          facility.value = profile.facilityName!;
        }
        
        if (profile.role.isNotEmpty) {
          // Format role dari database (misal: "admin" -> "Petugas / Admin")
          role.value = profile.role.toUpperCase() == 'ADMIN' 
              ? 'Petugas Surveilans TBC' 
              : profile.role;
        }
      } else {
        name.value = 'Petugas Tuberku';
      }
    }
  }

  Future<void> logout() async {
    await _supabase.signOut();
    Get.offAllNamed(AppRoutes.roleSelection);
  }
}
