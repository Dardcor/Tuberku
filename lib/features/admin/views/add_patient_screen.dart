import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../controllers/add_patient_controller.dart';
import '../controllers/main_admin_controller.dart';

class AddPatientScreen extends GetView<AddPatientController> {
  const AddPatientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Tambah Pasien Baru',
          style: AppTextStyles.titleMedium.copyWith(color: AppColors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lengkapi data di bawah ini untuk mendaftarkan pasien baru ke dalam sistem pemantauan.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            
            // IDENTITAS PASIEN
            _buildSection(
              title: 'IDENTITAS PASIEN',
              icon: Icons.badge_outlined,
              children: [
                _buildField(
                  label: 'ID Pasien (Otomatis)',
                  controller: controller.patientIdController,
                  readOnly: true,
                  filled: true,
                  fillColor: Colors.grey.shade200,
                ),
                _buildField(
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap pasien',
                  controller: controller.nameController,
                ),
                _buildField(
                  label: 'Nomor Induk Kependudukan (NIK)',
                  hint: '16 digit NIK',
                  controller: controller.nikController,
                  keyboardType: TextInputType.number,
                ),
                _buildField(
                  label: 'Nomor Telepon / WhatsApp',
                  hint: 'Contoh: 08123456789',
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
            
            // DATA PERAWATAN
            _buildSection(
              title: 'DATA PERAWATAN',
              icon: Icons.medical_services_outlined,
              children: [
                _buildField(
                  label: 'Tanggal Diagnosis',
                  hint: 'mm/dd/yyyy',
                  controller: controller.dateController,
                  suffixIcon: const Icon(Icons.calendar_today, size: 20, color: AppColors.textPrimary),
                  readOnly: true,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      controller.dateController.text = '${date.month}/${date.day}/${date.year}';
                    }
                  },
                ),
                const SizedBox(height: 16),
                Text('Puskesmas Rujukan Utama', style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Obx(() => DropdownButtonFormField<String>(
                  value: controller.selectedPuskesmas.value,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  hint: const Text('Pilih Fasilitas Kesehatan'),
                  items: const [
                    DropdownMenuItem(value: 'Puskesmas Genteng', child: Text('Puskesmas Genteng')),
                    DropdownMenuItem(value: 'Puskesmas Wonokromo', child: Text('Puskesmas Wonokromo')),
                    DropdownMenuItem(value: 'RSUD Dr. Soetomo', child: Text('RSUD Dr. Soetomo')),
                  ],
                  onChanged: (val) => controller.selectedPuskesmas.value = val,
                )),
              ],
            ),
            
            // IZIN & KEAMANAN
            _buildSection(
              title: 'IZIN & KEAMANAN',
              icon: Icons.security_outlined,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Izin Pelacakan Lokasi', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(
                            'Mengizinkan aplikasi mencatat lokasi untuk pemantauan zonasi wilayah pasien.',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                    Obx(() => Switch(
                      value: controller.isGpsEnabled.value,
                      onChanged: (val) => controller.isGpsEnabled.value = val,
                      activeColor: AppColors.primary,
                    )),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(16, 16, 16, MediaQuery.of(context).padding.bottom + 16),
        decoration: const BoxDecoration(
          color: AppColors.background,
        ),
        child: Obx(() => AppButton(
          text: 'SIMPAN DATA PASIEN',
          icon: Icons.save_outlined,
          isLoading: controller.isLoading.value,
          onPressed: controller.savePatient,
        )),
      ),
    );
  }

  Widget _buildSection({required String title, required IconData icon, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AppCard(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          ...children,
        ],
      ),
    ));
  }

  Widget _buildField({
    required String label,
    String? hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    bool filled = false,
    Color? fillColor,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            onTap: onTap,
            style: AppTextStyles.bodyMedium,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
              filled: filled || readOnly,
              fillColor: fillColor ?? (readOnly ? Colors.grey.shade100 : Colors.white),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: suffixIcon,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
