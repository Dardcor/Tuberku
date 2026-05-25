import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/services/supabase_service.dart';
import '../../../app/routes/app_routes.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Get.find<SupabaseService>();
    final user = supabase.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Petugas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryLight,
              child: Icon(Icons.person, size: 60, color: AppColors.white),
            ),
            const SizedBox(height: 16),
            Text(
              user?.email ?? 'Petugas',
              style: AppTextStyles.titleMedium,
            ),
            const SizedBox(height: 32),
            _buildMenuItem(
              icon: Icons.logout,
              title: 'Keluar',
              color: AppColors.danger,
              onTap: () async {
                await supabase.signOut();
                Get.offAllNamed(AppRoutes.roleSelection);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = AppColors.textPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        onTap: onTap,
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
