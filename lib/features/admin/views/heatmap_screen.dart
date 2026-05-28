import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/heatmap_controller.dart';
import '../controllers/main_admin_controller.dart';

class HeatmapScreen extends GetView<HeatmapController> {
  const HeatmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.hasError.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat peta',
            subtitle: 'Periksa koneksi internet Anda',
            buttonText: 'Coba Lagi',
            onButtonPressed: controller.refresh,
          );
        }

        return Stack(
          children: [
            // Google Maps
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(-7.250445, 112.768845),
                zoom: 12,
              ),
              markers: controller.markers.toSet(),
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              onMapCreated: controller.onMapCreated,
            ),

            // Top overlay (Back button, Filters)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () {
                        Get.find<MainAdminController>().changeTab(0);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text('Zona', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 20),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primary, // Dark green
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text('Kecamatan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('Live', style: TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Legend
            Positioned(
              bottom: 300, // Above bottom sheet
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem(Colors.red, 'High Case'),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.orange, 'Medium'),
                    const SizedBox(height: 8),
                    _buildLegendItem(Colors.yellow, 'Low Case'),
                  ],
                ),
              ),
            ),

            // Bottom Sheet Data
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomSheet(),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.bodySmall),
      ],
    );
  }

  Widget _buildBottomSheet() {
    return Container(
      height: 280,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Tabs
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: controller.districts.length,
              itemBuilder: (context, index) {
                final district = controller.districts[index];
                return Obx(() {
                  final isSelected = controller.selectedDistrict.value == district;
                  return GestureDetector(
                    onTap: () => controller.setDistrict(district),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primary : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          district,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          const Divider(height: 1),
          
          // Stats row
          Padding(
            padding: const EdgeInsets.all(16),
            child: Obx(() {
              final stats = controller.districtStats[controller.selectedDistrict.value] ?? {'active': 0, 'adherence': 0, 'tracing': 0};
              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem('${stats['active']}', 'Kasus Aktif', Colors.red),
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildStatItem('${stats['adherence']}%', 'Patuh Obat', AppColors.primary),
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildStatItem('${stats['tracing']}', 'Tracing', Colors.brown),
                  ),
                ],
              );
            }),
          ),
          const Divider(height: 1),
          
          // Patient List (Mock)
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildPatientItem(
                  'P1',
                  'Pasien 014 - ${controller.selectedDistrict.value}',
                  'Risiko Tinggi • Mangkir 2 Hari',
                  Colors.red.shade100,
                  Colors.red.shade700,
                ),
                const SizedBox(height: 12),
                _buildPatientItem(
                  'P2',
                  'Pasien 089 - ${controller.selectedDistrict.value}',
                  'Pemantauan • Stabil',
                  Colors.lime.shade200,
                  const Color(0xFF808000),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPatientItem(String avatar, String name, String status, Color avatarBg, Color statusColor) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: avatarBg,
          child: Text(
            avatar,
            style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(status, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward, size: 16),
        ),
      ],
    );
  }
}
