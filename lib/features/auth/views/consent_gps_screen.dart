import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../controllers/auth_controller.dart';

class ConsentGpsScreen extends GetView<AuthController> {
  const ConsentGpsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Persetujuan GPS'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 64,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Izin Penggunaan Lokasi',
                style: AppTextStyles.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data lokasi Anda akan digunakan untuk:',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildBulletPoint(
                      'Membantu petugas kesehatan memantau penyebaran TBC di wilayah Anda.',
                    ),
                    _buildBulletPoint(
                      'Menampilkan apotek dan fasilitas kesehatan terdekat.',
                    ),
                    _buildBulletPoint(
                      'Memberikan informasi zona rawan TBC di sekitar Anda.',
                    ),
                    _buildBulletPoint(
                      'Data dienkripsi dan hanya diakses oleh petugas kesehatan yang berwenang.',
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Checkbox
              Obx(() => Row(
                    children: [
                      Checkbox(
                        value: controller.gpsConsent.value,
                        onChanged: (val) {
                          controller.gpsConsent.value = val ?? false;
                        },
                        activeColor: AppColors.primary,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            controller.gpsConsent.value =
                                !controller.gpsConsent.value;
                          },
                          child: Text(
                            'Saya memahami dan menyetujui penggunaan data lokasi saya sesuai ketentuan di atas.',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
              const SizedBox(height: 16),
              Obx(() => AppButton(
                    text: 'SAYA SETUJU & LANJUTKAN',
                    onPressed: controller.gpsConsent.value
                        ? controller.submitGpsConsent
                        : null,
                    isLoading: controller.isSubmittingConsent.value,
                    icon: Icons.check_circle_outline,
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyMedium),
          ),
        ],
      ),
    );
  }
}
