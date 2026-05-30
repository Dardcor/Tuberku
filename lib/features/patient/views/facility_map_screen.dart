<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/facility_map_controller.dart';
import '../widgets/facility_marker.dart';

class FacilityMapScreen extends GetView<FacilityMapController> {
  const FacilityMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Fasilitas Kesehatan'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: LoadingShimmer(itemCount: 1, height: 300),
          );
        }

        if (controller.hasError.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat peta',
            subtitle: 'Periksa koneksi internet dan izin lokasi',
            buttonText: 'Coba Lagi',
            onButtonPressed: controller.refresh,
          );
        }

        return Stack(
          children: [
            // Google Maps
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.initialCameraPosition,
                  zoom: 13,
                ),
                markers: controller.markers.toSet(),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                style: '''
[
  {
    "featureType": "poi",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.medical",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.business",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.business.pharmacy",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.healthcare",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.government",
    "stylers": [{ "visibility": "off" }]
  }
]
''',
                onMapCreated: controller.onMapCreated,
              ),
            ),
            // Filter chips
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => controller.setFilter(filter),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardBg,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Bottom sheet with facility list
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Handle
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fasilitas Kesehatan',
                              style: AppTextStyles.titleMedium,
                            ),
                            Text(
                              '${controller.filteredFacilities.length} lokasi',
                              style: AppTextStyles.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Expanded(
                        child: controller.filteredFacilities.isEmpty
                            ? const Center(
                                child: Text('Tidak ada fasilitas ditemukan'),
                              )
                            : ListView.separated(
                                controller: scrollController,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: controller.filteredFacilities.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final facility =
                                      controller.filteredFacilities[index];
                                  return FacilityMarker(
                                    name: facility.name,
                                    distance: facility.formattedDistance,
                                    hasStock: facility.hasStock,
                                    onTap: () {
                                      Get.toNamed(
                                        AppRoutes.facilityDetail,
                                        arguments: facility,
                                      );
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
=======
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/facility_map_controller.dart';
import '../widgets/facility_marker.dart';

class FacilityMapScreen extends GetView<FacilityMapController> {
  const FacilityMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: LoadingShimmer(itemCount: 1, height: 300),
          );
        }

        if (controller.hasError.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat peta',
            subtitle: 'Periksa koneksi internet dan izin lokasi',
            buttonText: 'Coba Lagi',
            onButtonPressed: controller.refresh,
          );
        }

        return Stack(
          children: [
            // Google Maps
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: controller.initialCameraPosition,
                  zoom: 13,
                ),
                markers: controller.markers.toSet(),
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                style: '''
[
  {
    "featureType": "poi",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.medical",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.business",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.business.pharmacy",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.healthcare",
    "stylers": [{ "visibility": "on" }]
  },
  {
    "featureType": "poi.government",
    "stylers": [{ "visibility": "off" }]
  }
]
''',
                onMapCreated: controller.onMapCreated,
              ),
            ),
            // Filter chips
            Positioned(
              top: 12,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final isSelected =
                        controller.selectedFilter.value == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => controller.setFilter(filter),
                      selectedColor: AppColors.primary,
                      backgroundColor: AppColors.cardBg,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? AppColors.white
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Bottom sheet with facility list
            DraggableScrollableSheet(
              initialChildSize: 0.3,
              minChildSize: 0.1,
              maxChildSize: 0.7,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: CustomScrollView(
                    controller: scrollController,
                    slivers: [
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Handle
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Fasilitas Kesehatan',
                                    style: AppTextStyles.titleMedium,
                                  ),
                                  Text(
                                    '${controller.filteredFacilities.length} lokasi',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        ),
                      ),
                      controller.filteredFacilities.isEmpty
                          ? const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                  child: Text('Tidak ada fasilitas ditemukan'),
                                ),
                              ),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final facility =
                                        controller.filteredFacilities[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: FacilityMarker(
                                        name: facility.name,
                                        distance: facility.formattedDistance,
                                        onTap: () {
                                          Get.toNamed(
                                            AppRoutes.facilityDetail,
                                            arguments: facility,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  childCount: controller.filteredFacilities.length,
                                ),
                              ),
                            ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
<<<<<<< HEAD
=======
>>>>>>> 579452a358692d1a6d2721fd9e3b7d13a27b3b41
>>>>>>> 61294c55f3372314335c2f33d8cd895c5b5f3b2f
