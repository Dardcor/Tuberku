import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/patient_dashboard_controller.dart';
import '../widgets/quick_access_card.dart';
import '../widgets/article_card.dart';
import 'package:intl/intl.dart';

class PatientDashboardScreen extends GetView<PatientDashboardController> {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: AppColors.textPrimary),
          onPressed: () {},
        ),
        title: Text(
          'Tuberku',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.primary),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.textPrimary,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.warning,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingShimmer(itemCount: 4),
          );
        }

        if (controller.hasError.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat data',
            subtitle: 'Periksa koneksi internet Anda',
            buttonText: 'Coba Lagi',
            onButtonPressed: controller.refresh,
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingCard(),
                const SizedBox(height: 24),
                _buildQuickAccessGrid(),
                const SizedBox(height: 24),
                _buildArticlesSection(),
                const SizedBox(height: 24),
                _buildAiBanner(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.currentTabIndex.value,
            onTap: (index) {
              switch (index) {
                case 0:
                  controller.changeTab(0);
                  break;
                case 1:
                  Get.toNamed(AppRoutes.aiChat);
                  break;
                case 2:
                  Get.toNamed(AppRoutes.facilityMap);
                  break;
                case 3:
                  Get.toNamed(AppRoutes.articleList);
                  break;
                case 4:
                  // Profile - future
                  break;
              }
            },
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
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy),
                label: 'Tuberku AI',
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

  Widget _buildGreetingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wb_sunny_outlined,
                  color: AppColors.accent, size: 20),
              const SizedBox(width: 8),
              Obx(() => Text(
                    'Halo, ${controller.userName.value.isNotEmpty ? controller.userName.value : 'Pasien'}!',
                    style: AppTextStyles.titleLarge.copyWith(
                      color: AppColors.white,
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Jangan lupa minum obat hari ini. Tetap semangat!',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        QuickAccessCard(
          icon: Icons.smart_toy,
          label: 'Tuberku AI',
          iconColor: AppColors.primary,
          onTap: () => Get.toNamed(AppRoutes.aiChat),
        ),
        QuickAccessCard(
          icon: Icons.local_pharmacy,
          label: 'Cari Apotek',
          iconColor: AppColors.warning,
          onTap: () => Get.toNamed(AppRoutes.facilityMap),
        ),
        QuickAccessCard(
          icon: Icons.article,
          label: 'Artikel',
          iconColor: AppColors.success,
          onTap: () => Get.toNamed(AppRoutes.articleList),
        ),
        QuickAccessCard(
          icon: Icons.notifications,
          label: 'Notifikasi',
          iconColor: AppColors.danger,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildArticlesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Artikel Terbaru', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.articleList),
              child: Text(
                'Lihat Semua',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 160,
          child: Obx(() {
            if (controller.articles.isEmpty) {
              return const Center(
                child: Text('Belum ada artikel'),
              );
            }
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount:
                  controller.articles.length > 4 ? 4 : controller.articles.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final article = controller.articles[index];
                return SizedBox(
                  width: 260,
                  child: ArticleCard(
                    source: article.source,
                    title: article.title,
                    date: article.pubDate != null
                        ? DateFormat('dd MMM yyyy').format(article.pubDate!)
                        : '',
                    readTime: article.readingTime,
                    onTap: () {
                      Get.toNamed(
                        AppRoutes.articleDetail,
                        arguments: article,
                      );
                    },
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildAiBanner() {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.aiChat),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Punya pertanyaan seputar TBC?',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanya Tuberku AI sekarang',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.primary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
