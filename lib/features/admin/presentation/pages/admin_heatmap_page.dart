import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// DUMMY DATA (Easy to replace with API later)
final mockHeatmapStats = {
  'location': 'Genteng',
  'activeCases': 14,
  'adherencePercent': 68,
  'tracingCount': 3,
};

final List<Map<String, dynamic>> mockHeatmapPatients = [
  {
    'name': 'Pasien 014 - Genteng',
    'status': 'Risiko Tinggi',
    'statusColor': AppColors.danger,
    'description': 'Tidak lapor minum obat 3 hari. Mobilitas tinggi di zona merah.',
  },
  {
    'name': 'Pasien 009 - Tambaksari',
    'status': 'Risiko Sedang',
    'statusColor': AppColors.warning,
    'description': 'Patuh minum obat. Berada di sekitar suspect.',
  },
  {
    'name': 'Pasien 021 - Gubeng',
    'status': 'Risiko Rendah',
    'statusColor': AppColors.success,
    'description': 'Patuh minimum obat. Mobilitas rendah.',
  },
];

class AdminHeatmapPage extends StatelessWidget {
  const AdminHeatmapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Map Mock
          Container(
            color: const Color(0xFFC8DEC3), // Map ground color mock
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                   // Heat mock 1
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.danger.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.danger.withOpacity(0.4),
                          blurRadius: 50,
                          spreadRadius: 20,
                        )
                      ]
                    ),
                  ),
                   // Heat mock 2
                  Positioned(
                    top: 100,
                    right: -50,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.warning.withOpacity(0.3),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.warning.withOpacity(0.4),
                            blurRadius: 40,
                            spreadRadius: 15,
                          )
                        ]
                      ),
                    ),
                  ),
                  const Icon(Icons.map, size: 100, color: Colors.white54),
                  const Text('Peta Interaktif (Mock)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          // Top Overlays
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Dropdowns/Chips
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildChip('Zona', Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          _buildChip('Kecamatan', Icons.keyboard_arrow_down),
                          const SizedBox(width: 8),
                          _buildChip('Live', Icons.circle, iconColor: AppColors.danger),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomSheet(context),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, IconData icon, {Color iconColor = AppColors.textSecondary}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(width: 4),
          Icon(icon, size: 16, color: iconColor),
        ],
      ),
    );
  }

  Widget _buildBottomSheet(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.45,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  mockHeatmapStats['location'] as String,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('Detail Area', style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _buildStatItem('${mockHeatmapStats['activeCases']}', 'Kasus Aktif'),
                const SizedBox(width: 16),
                _buildStatItem('${mockHeatmapStats['adherencePercent']}%', 'Patuh Obat'),
                const SizedBox(width: 16),
                _buildStatItem('${mockHeatmapStats['tracingCount']}', 'Tracing'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: mockHeatmapPatients.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final patient = mockHeatmapPatients[index];
                return _buildPatientCard(patient);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                patient['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: patient['statusColor'].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  patient['status'],
                  style: TextStyle(
                    color: patient['statusColor'],
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            patient['description'],
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
