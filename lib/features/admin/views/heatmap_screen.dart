import 'package:flutter/material.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/heatmap_controller.dart';

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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Obx(() => Row(
                        children: [
                          PopupMenuButton<String>(
                            onSelected: controller.setZoneFilter,
                            itemBuilder: (context) => ['Semua', 'Merah', 'Kuning', 'Hijau']
                                .map((z) => PopupMenuItem(value: z, child: Text(z)))
                                .toList(),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 130),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: controller.selectedZoneFilter.value == 'Semua' ? Colors.white : AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.selectedZoneFilter.value == 'Semua' ? 'Zona' : controller.selectedZoneFilter.value, 
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: controller.selectedZoneFilter.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down, 
                                    size: 20,
                                    color: controller.selectedZoneFilter.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: controller.setDistrict,
                            itemBuilder: (context) => controller.districts
                                .map((d) => PopupMenuItem(value: d, child: Text(d)))
                                .toList(),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 160),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: controller.selectedDistrict.value == 'Semua' ? Colors.white : AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.selectedDistrict.value == 'Semua' ? 'Kecamatan' : controller.selectedDistrict.value, 
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: controller.selectedDistrict.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down, 
                                    size: 20,
                                    color: controller.selectedDistrict.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            onSelected: controller.setStatusFilter,
                            itemBuilder: (context) => ['Semua', 'Aktif', 'Sembuh']
                                .map((s) => PopupMenuItem(value: s, child: Text(s)))
                                .toList(),
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 140),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: controller.selectedStatusFilter.value == 'Semua' ? Colors.white : AppColors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      controller.selectedStatusFilter.value == 'Semua' ? 'Status Kasus' : controller.selectedStatusFilter.value, 
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: controller.selectedStatusFilter.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_drop_down, 
                                    size: 20,
                                    color: controller.selectedStatusFilter.value == 'Semua' ? AppColors.textPrimary : Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      )),
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
              final stats = controller.districtStats[controller.selectedDistrict.value] ?? {'active': 0, 'recovered': 0, 'tracing': 0};
              return Row(
                children: [
                  Expanded(
                    child: _buildStatItem('${stats['active']}', 'Kasus Aktif', Colors.red),
                  ),
                  Container(height: 30, width: 1, color: Colors.grey.shade200),
                  Expanded(
                    child: _buildStatItem('${stats['recovered']}', 'Sembuh', AppColors.success),
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
          
          // Patient List
          Expanded(
            child: Obx(() {
              final districtPatients = controller.patients.where((p) {
                String pDistrict = p.district ?? 'Lainnya';
                if (pDistrict.startsWith('Kecamatan ')) {
                  pDistrict = pDistrict.replaceAll('Kecamatan ', '');
                }
                final matchesDistrict = controller.selectedDistrict.value == 'Semua' || pDistrict == controller.selectedDistrict.value;
                
                final matchesStatus = controller.selectedStatusFilter.value == 'Semua' ||
                    (controller.selectedStatusFilter.value == 'Aktif' && p.isActive) ||
                    (controller.selectedStatusFilter.value == 'Sembuh' && !p.isActive);

                final matchesZone = controller.selectedZoneFilter.value == 'Semua' ||
                    (p.zone?.toLowerCase() ?? '') == controller.selectedZoneFilter.value.toLowerCase();

                return matchesDistrict && matchesStatus && matchesZone;
              }).toList();

              if (districtPatients.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada data pasien di wilayah ini',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: districtPatients.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final p = districtPatients[index];
                  final name = p.fullName ?? 'Pasien ${p.id.substring(0, min(5, p.id.length))}';
                  
                  // Tentukan warna status
                  Color statusColor = AppColors.success;
                  Color avatarBg = AppColors.successLight;
                  String statusText = 'Sembuh';
                  
                  if (p.isActive) {
                    if (p.zone == 'merah') {
                      statusColor = Colors.red.shade700;
                      avatarBg = Colors.red.shade100;
                      statusText = 'Risiko Tinggi';
                    } else if (p.zone == 'kuning') {
                      statusColor = const Color(0xFF808000);
                      avatarBg = Colors.lime.shade200;
                      statusText = 'Pemantauan';
                    } else {
                      statusColor = AppColors.success;
                      avatarBg = AppColors.successLight;
                      statusText = 'Stabil';
                    }
                  }

                  final patientStatus = p.isActive ? 'Aktif' : 'Sembuh';
                  final fullSubtitle = '$patientStatus ($statusText) • ${p.tbType ?? "BTA+"} • Kecamatan ${p.district ?? "-"}';

                  return GestureDetector(
                    onTap: () {
                      Get.toNamed('/admin/patient/detail', arguments: p);
                    },
                    child: _buildPatientItem(
                      name.substring(0, 1).toUpperCase(),
                      name,
                      fullSubtitle,
                      avatarBg,
                      statusColor,
                      p.profileId != null,
                    ),
                  );
                },
              );
            }),
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

  Widget _buildPatientItem(String avatar, String name, String status, Color avatarBg, Color statusColor, bool isActivated) {
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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isActivated ? Colors.green.shade50 : Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isActivated ? Colors.green.shade200 : Colors.blue.shade200,
                      ),
                    ),
                    child: Text(
                      isActivated ? 'Aktif' : 'Belum Aktivasi',
                      style: TextStyle(
                        color: isActivated ? Colors.green.shade800 : Colors.blue.shade800,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      status,
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
          child: const Icon(Icons.arrow_forward, size: 16),
        ),
      ],
    );
  }
}
