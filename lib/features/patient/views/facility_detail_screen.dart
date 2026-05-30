import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/models/facility_model.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/status_badge.dart';

class FacilityDetailScreen extends StatelessWidget {
  const FacilityDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final facility = Get.arguments as FacilityModel?;

    if (facility == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Fasilitas')),
        body: const Center(child: Text('Fasilitas tidak ditemukan')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Fasilitas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Facility info
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_pharmacy,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              facility.name,
                              style: AppTextStyles.titleLarge,
                            ),
                            const SizedBox(height: 4),
                            StatusBadge(
                              text: facility.type.toUpperCase(),
                              type: BadgeType.blue,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (facility.address != null) ...[
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            facility.address!,
                            style: AppTextStyles.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (facility.phone != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.phone,
                            size: 16, color: AppColors.textHint),
                        const SizedBox(width: 8),
                        Text(facility.phone!, style: AppTextStyles.bodyMedium),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Opening hours
            if (facility.openingHours != null) ...[
              Text('Jam Operasional', style: AppTextStyles.titleMedium),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: facility.openingHours!.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            entry.key,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            entry.value.toString(),
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Navigation button
            AppButton(
              text: 'Petunjuk Arah',
              icon: Icons.navigation,
              onPressed: () async {
                final url = Uri.parse(
                  'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}',
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

}
