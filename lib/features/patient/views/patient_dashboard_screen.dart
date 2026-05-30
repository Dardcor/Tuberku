import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../controllers/patient_dashboard_controller.dart';
import '../controllers/article_controller.dart';
import '../controllers/facility_map_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../views/patient_dashboard_content.dart';
import '../views/facility_map_screen.dart';
import '../views/article_list_screen.dart';
import '../../profile/views/profile_screen.dart';

class PatientDashboardScreen extends GetView<PatientDashboardController> {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Tuberku',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.white,
            ),
            onPressed: () => Get.toNamed(AppRoutes.patientNotifications),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Obx(() => IndexedStack(
            index: controller.currentTabIndex.value,
            children: [
              const PatientDashboardContent(),
              GetBuilder<FacilityMapController>(
                init: FacilityMapController(),
                builder: (_) => const FacilityMapScreen(),
              ),
              GetBuilder<ArticleController>(
                init: ArticleController(),
                builder: (_) => const ArticleListScreen(),
              ),
              GetBuilder<ProfileController>(
                init: ProfileController(),
                builder: (_) => const ProfileScreen(),
              ),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentTabIndex.value,
            onTap: controller.changeTab,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.textSecondary,
            backgroundColor: AppColors.cardBg,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home),
                label: 'Beranda',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.map_outlined),
                activeIcon: Icon(Icons.map),
                label: 'Peta',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: 'Artikel',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Profil',
              ),
            ],
          )),
    );
  }
}
