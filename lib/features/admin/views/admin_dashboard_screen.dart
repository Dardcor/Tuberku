import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tb_care/core/models/tracing_model.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/main_admin_controller.dart';
import '../widgets/stat_mini_card.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TB-Control Center',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.white,
              ),
            ),
            Text(
              'Admin - Kota Surabaya',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16, left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.white,
              child: Text(
                'AD',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
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
                _buildStatsGrid(),
                const SizedBox(height: 24),
                _buildMapPreview(),
                const SizedBox(height: 24),
                _buildTracingSection(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
          crossAxisCount: 3, // Ubah ke 3 kolom
          crossAxisSpacing: 8, // Sedikit diperkecil agar cukup
          mainAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 0.9, // Disesuaikan agar kotak tidak terlalu tinggi
          children: [
            StatMiniCard(
              title: 'Kasus Aktif',
              value: '${controller.activePatients.value}',
              icon: Icons.settings_outlined,
              iconColor: AppColors.danger,
              subtitle: '+12 mgg ini',
            ),
            StatMiniCard(
              title: 'Tracing',
              value: '${controller.activeTracingCount.value}',
              icon: Icons.person_search_outlined,
              iconColor: AppColors.danger,
              badge: 'CRITICAL',
              badgeColor: AppColors.danger,
              subtitle: 'kontak',
            ),
            StatMiniCard(
              title: 'Zona Merah',
              value: '${controller.redZoneCount.value}',
              icon: Icons.warning_amber_rounded,
              iconColor: AppColors.danger,
              badge: 'CRITICAL',
              badgeColor: AppColors.danger,
              subtitle: 'kecamatan',
            ),
          ],
        ));
  }

  Widget _buildMapPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Persebaran Kasus', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: () {
                Get.find<MainAdminController>().changeTab(1); // Go to Heatmap Tab
              },
              child: Row(
                children: [
                  Text(
                    'Fullscreen',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 16, color: AppColors.primary),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => Get.find<MainAdminController>().changeTab(1),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.successLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Stack(
              children: [
                // Mock map background pattern or color
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Opacity(
                      opacity: 0.1,
                      child: Image.asset(
                        'assets/images/map_placeholder.png', // Assuming we have or just use an icon
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.map,
                          size: 100,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                // Mock map heatspots
                Positioned(
                  top: 80,
                  left: 140,
                  child: _buildHeatSpot('14', AppColors.danger),
                ),
                Positioned(
                  bottom: 40,
                  right: 80,
                  child: _buildHeatSpot('7', AppColors.warning),
                ),
                Positioned(
                  top: 20,
                  left: 90,
                  child: _buildHeatSpot('9', AppColors.success),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeatSpot(String count, Color color) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 15,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 40,
            spreadRadius: 30,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
              child: Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 24, shadows: [
            Shadow(color: Colors.black26, blurRadius: 2, offset: Offset(0, 1))
          ]),
        ],
      ),
    );
  }

  Widget _buildTracingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tracing Terbaru', style: AppTextStyles.titleLarge),
            TextButton(
              onPressed: () => Get.toNamed(AppRoutes.tracingTimeline),
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
        Obx(() {
          if (controller.recentTracing.isEmpty) {
            // Mock data for UI presentation based on the image
            return Column(
              children: [
                _buildTracingCard('Gubeng, SBY'),
                _buildTracingCard('Wonokromo, SBY'),
              ],
            );
          }

          return Column(
            children: controller.recentTracing.take(2).map((tracing) {
              return _buildTracingCard(tracing.placeName ?? 'Unknown Location', tracing: tracing);
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _buildTracingCard(String location, {TracingModel? tracing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.route_outlined,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {
              if (tracing != null) {
                Get.toNamed(AppRoutes.tracingDetail, arguments: tracing);
              }
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'Detail',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

