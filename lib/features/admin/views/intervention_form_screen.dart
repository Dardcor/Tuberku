import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../app/config/app_constants.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/intervention_controller.dart';

class InterventionFormScreen extends GetView<InterventionController> {
  const InterventionFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tindak Lanjut'),
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          bottom: TabBar(
            onTap: controller.changeTab,
            indicatorColor: AppColors.accent,
            indicatorWeight: 3,
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.white.withValues(alpha: 0.6),
            labelStyle: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'Kirim Pesan'),
              Tab(text: 'Tandai Zona'),
              Tab(text: 'Catat Kunjungan'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSendMessageTab(),
            _buildMarkZoneTab(),
            _buildRecordVisitTab(context),
          ],
        ),
      ),
    );
  }

  // ─── Tab 1: Kirim Pesan ───────────────────────────────

  Widget _buildSendMessageTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Pasien', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Pilih pasien...',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                value: controller.selectedPatientId.value.isEmpty
                    ? null
                    : controller.selectedPatientId.value,
                items: controller.patients.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(
                      'ID: ${p.id.substring(0, 8)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.selectedPatientId.value = val ?? '';
                },
              )),
          const SizedBox(height: 20),
          Text('Jenis Pesan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Obx(() => Column(
                children: [
                  _buildRadioTile('pengingat', 'Pengingat Minum Obat'),
                  _buildRadioTile('edukasi', 'Edukasi Kesehatan'),
                  _buildRadioTile('kunjungan', 'Jadwal Kunjungan'),
                  _buildRadioTile('lainnya', 'Lainnya'),
                ],
              )),
          const SizedBox(height: 20),
          Text('Isi Pesan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller.messageController,
            maxLines: 5,
            maxLength: 500,
            decoration: const InputDecoration(
              hintText: 'Tulis pesan untuk pasien...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.successLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Preview Notifikasi',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pesan dari Petugas',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Isi pesan akan muncul di sini...',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Obx(() => AppButton(
                text: 'Kirim',
                icon: Icons.send,
                onPressed: controller.sendMessage,
                isLoading: controller.isLoading.value,
              )),
        ],
      ),
    );
  }

  Widget _buildRadioTile(String value, String label) {
    return RadioListTile<String>(
      title: Text(label, style: AppTextStyles.bodyMedium),
      value: value,
      groupValue: controller.messageType.value,
      onChanged: (val) => controller.messageType.value = val ?? 'pengingat',
      activeColor: AppColors.primary,
      contentPadding: EdgeInsets.zero,
      dense: true,
    );
  }

  // ─── Tab 2: Tandai Zona ───────────────────────────────

  Widget _buildMarkZoneTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Area', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          TextField(
            onChanged: (val) => controller.selectedArea.value = val,
            decoration: const InputDecoration(
              hintText: 'Masukkan nama kelurahan/kecamatan...',
              prefixIcon: Icon(Icons.location_on_outlined),
            ),
          ),
          const SizedBox(height: 24),
          Text('Level Zona', style: AppTextStyles.titleMedium),
          const SizedBox(height: 12),
          Obx(() => Column(
                children: [
                  _buildZoneRadio(
                    AppConstants.zoneMerah,
                    'Zona Merah',
                    'Area dengan risiko tinggi penularan TBC',
                    AppColors.danger,
                  ),
                  const SizedBox(height: 8),
                  _buildZoneRadio(
                    AppConstants.zonaKuning,
                    'Zona Kuning',
                    'Area dengan risiko sedang penularan TBC',
                    AppColors.warning,
                  ),
                  const SizedBox(height: 8),
                  _buildZoneRadio(
                    AppConstants.zonaHijau,
                    'Zona Hijau',
                    'Area dengan risiko rendah penularan TBC',
                    AppColors.success,
                  ),
                ],
              )),
          const SizedBox(height: 32),
          Obx(() => AppButton(
                text: 'Tandai Zona',
                icon: Icons.flag,
                onPressed: controller.markZone,
                isLoading: controller.isLoading.value,
              )),
        ],
      ),
    );
  }

  Widget _buildZoneRadio(
    String value,
    String label,
    String description,
    Color color,
  ) {
    final isSelected = controller.selectedZoneLevel.value == value;
    return GestureDetector(
      onTap: () => controller.selectedZoneLevel.value = value,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.08) : AppColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? color : AppColors.textHint,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.titleMedium.copyWith(
                      fontSize: 14,
                      color: isSelected ? color : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Tab 3: Catat Kunjungan ───────────────────────────

  Widget _buildRecordVisitTab(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pilih Pasien', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Obx(() => DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  hintText: 'Pilih pasien...',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                value: controller.visitPatientId.value.isEmpty
                    ? null
                    : controller.visitPatientId.value,
                items: controller.patients.map((p) {
                  return DropdownMenuItem(
                    value: p.id,
                    child: Text(
                      'ID: ${p.id.substring(0, 8)}',
                      style: AppTextStyles.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  controller.visitPatientId.value = val ?? '';
                },
              )),
          const SizedBox(height: 20),
          Text('Tanggal Kunjungan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          Obx(() => GestureDetector(
                onTap: () => controller.selectVisitDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        controller.visitDate.value != null
                            ? DateFormat('dd MMMM yyyy')
                                .format(controller.visitDate.value!)
                            : 'Pilih tanggal...',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: controller.visitDate.value != null
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 20),
          Text('Catatan Kunjungan', style: AppTextStyles.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: controller.visitNotesController,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Tulis catatan kunjungan...',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 32),
          Obx(() => AppButton(
                text: 'Simpan Kunjungan',
                icon: Icons.save,
                onPressed: controller.saveVisit,
                isLoading: controller.isLoading.value,
              )),
        ],
      ),
    );
  }
}
