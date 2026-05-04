import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/routes/app_routes.dart';
import '../../../core/widgets/loading_shimmer.dart';
import '../../../core/widgets/empty_state.dart';
import '../controllers/tracing_controller.dart';
import '../widgets/tracing_timeline_item.dart';

class TracingTimelineScreen extends GetView<TracingController> {
  const TracingTimelineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Tracing Mobilitas'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: LoadingShimmer(itemCount: 5, height: 100),
          );
        }

        if (controller.hasError.value) {
          return EmptyState(
            icon: Icons.error_outline,
            title: 'Gagal memuat data tracing',
            subtitle: 'Periksa koneksi internet Anda',
            buttonText: 'Coba Lagi',
            onButtonPressed: controller.refresh,
          );
        }

        if (controller.tracingLogs.isEmpty) {
          return const EmptyState(
            icon: Icons.timeline,
            title: 'Belum ada data tracing',
            subtitle: 'Data tracing mobilitas pasien akan muncul di sini',
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: AppColors.primary,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: controller.tracingLogs.length,
            itemBuilder: (context, index) {
              final tracing = controller.tracingLogs[index];
              final isLast = index == controller.tracingLogs.length - 1;

              // Date divider
              Widget? dateDivider;
              if (index == 0 ||
                  _isDifferentDay(
                    controller.tracingLogs[index - 1].visitedAt,
                    tracing.visitedAt,
                  )) {
                dateDivider = _buildDateDivider(tracing.visitedAt);
              }

              // Determine dot color based on simple heuristics
              Color dotColor;
              if (index % 3 == 0) {
                dotColor = AppColors.danger;
              } else if (index % 3 == 1) {
                dotColor = AppColors.warning;
              } else {
                dotColor = AppColors.success;
              }

              return Column(
                children: [
                  if (dateDivider != null) dateDivider,
                  TracingTimelineItem(
                    patientId: tracing.patientId?.substring(0, 8) ?? '-',
                    tracingRef: tracing.tracingRef ?? '-',
                    time: tracing.visitedAt != null
                        ? DateFormat('HH:mm').format(tracing.visitedAt!)
                        : '-',
                    area: tracing.placeName ?? '-',
                    dotColor: dotColor,
                    isLast: isLast,
                    onTap: () {
                      controller.selectTracing(tracing);
                      Get.toNamed(
                        AppRoutes.tracingDetail,
                        arguments: tracing,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }

  bool _isDifferentDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return true;
    return a.year != b.year || a.month != b.month || a.day != b.day;
  }

  Widget _buildDateDivider(DateTime? date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            date != null ? DateFormat('dd MMMM yyyy').format(date) : '-',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
