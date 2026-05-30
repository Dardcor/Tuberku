import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/models/tracing_model.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../controllers/tracing_controller.dart';

class TracingDetailScreen extends GetView<TracingController> {
  const TracingDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracing = Get.arguments as TracingModel?;

    if (tracing == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Analisis Jalur')),
        body: const Center(child: Text('Data tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analisis Jalur Pasien'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient info strip
            Container(
              padding: const EdgeInsets.all(16),
              color: AppColors.primary.withValues(alpha: 0.05),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID: ${tracing.patientId?.substring(0, 8) ?? "-"}',
                          style: AppTextStyles.titleMedium,
                        ),
                        Text(
                          'Ref: ${tracing.tracingRef ?? "-"}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dangerLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'PRIORITY',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Map (50% screen)
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.4,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    tracing.latitude ?? -7.2575,
                    tracing.longitude ?? 112.7521,
                  ),
                  zoom: 14,
                ),
                markers: {
                  if (tracing.latitude != null && tracing.longitude != null)
                    Marker(
                      markerId: const MarkerId('tracing_point'),
                      position: LatLng(
                        tracing.latitude!,
                        tracing.longitude!,
                      ),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed,
                      ),
                      infoWindow: InfoWindow(
                        title: tracing.placeName ?? 'Lokasi',
                      ),
                    ),
                },
                myLocationEnabled: false,
                zoomControlsEnabled: true,
                mapToolbarEnabled: false,
              ),
            ),
            // Stop details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detail Perjalanan',
                    style: AppTextStyles.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Obx(() {
                    if (controller.isLoading.value) {
                      return const LoadingShimmer(itemCount: 3, height: 60);
                    }

                    if (controller.patientTracingLogs.isEmpty) {
                      return AppCard(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'Tidak ada data perjalanan tambahan',
                              style: AppTextStyles.bodyMedium,
                            ),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: controller.patientTracingLogs
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final log = entry.value;
                        return _buildStopItem(index + 1, log);
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStopItem(int number, TracingModel log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$number',
                  style: const TextStyle(
                    color: AppColors.danger,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.placeName ?? 'Lokasi tidak diketahui',
                    style: AppTextStyles.titleMedium.copyWith(fontSize: 13),
                  ),
                  if (log.visitedAt != null)
                    Text(
                      DateFormat('dd MMM yyyy, HH:mm').format(log.visitedAt!),
                      style: AppTextStyles.bodySmall,
                    ),
                ],
              ),
            ),
            const Icon(
              Icons.location_on,
              size: 16,
              color: AppColors.danger,
            ),
          ],
        ),
      ),
    );
  }
}
