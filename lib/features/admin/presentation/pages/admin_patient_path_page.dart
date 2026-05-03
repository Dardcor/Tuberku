import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// DUMMY DATA
final mockPatientPathInfo = {
  'id': 'ID-TBC-2024-0891',
  'timeRange': 'Hari ini, 08:00 - 13:00',
  'riskLevel': 'Tinggi',
};

final List<Map<String, dynamic>> mockPathTimeline = [
  {
    'time': '08:00',
    'location': 'Rumah Pasien',
    'status': 'Aman',
    'statusColor': AppColors.success,
  },
  {
    'time': '09:30',
    'location': 'Pasar Genteng',
    'status': 'Kontak!',
    'statusColor': AppColors.danger,
    'description': 'Berada di area padat selama 45 menit',
  },
  {
    'time': '10:45',
    'location': 'Apotek Sehat',
    'status': 'Aman',
    'statusColor': AppColors.success,
  },
  {
    'time': '12:00',
    'location': 'Masjid Al-Akbar',
    'status': 'Risiko Sedang',
    'statusColor': AppColors.warning,
  },
];

class AdminPatientPathPage extends StatelessWidget {
  const AdminPatientPathPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analisis Jalur Pasien', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Column(
        children: [
          // Tags Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                _buildTag('# ${mockPatientPathInfo['id']?.substring(mockPatientPathInfo['id']!.length - 4)}', AppColors.primaryBackground, AppColors.primaryDark),
                const SizedBox(width: 8),
                _buildTag(mockPatientPathInfo['timeRange']!, Colors.grey[200]!, AppColors.textPrimary),
                const Spacer(),
                _buildTag('! ${mockPatientPathInfo['riskLevel']}', AppColors.danger.withOpacity(0.1), AppColors.danger, isBold: true),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Map Area
                  Container(
                    height: 250,
                    width: double.infinity,
                    color: const Color(0xFFC8DEC3),
                    child: Stack(
                      children: [
                        const Center(child: Icon(Icons.map, size: 100, color: Colors.white54)),
                        // Mock Path nodes
                        CustomPaint(
                          size: const Size(double.infinity, 250),
                          painter: _MockNodePainter(),
                        ),
                      ],
                    ),
                  ),

                  // Timeline
                  Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Perjalanan',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        ...List.generate(mockPathTimeline.length, (index) {
                          final item = mockPathTimeline[index];
                          final isLast = index == mockPathTimeline.length - 1;
                          return _buildTimelineItem(item, isLast, index + 1);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.notifications_outlined, size: 18),
                        label: const Text('Kirim Notifikasi'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.location_on_outlined, size: 18),
                        label: const Text('Tandai Lokasi'),
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Catat Hasil Analisis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor, {bool isBold = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> item, bool isLast, int stepNum) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Time
          SizedBox(
            width: 50,
            child: Text(
              item['time'],
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
          ),
          const SizedBox(width: 8),
          
          // Line and dot
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: item['statusColor'],
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: item['statusColor'].withOpacity(0.4),
                      blurRadius: 4,
                    )
                  ]
                ),
                child: Center(
                  child: Text('$stepNum', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(item['location'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item['statusColor'].withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item['status'],
                          style: TextStyle(color: item['statusColor'], fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  ),
                  if (item.containsKey('description')) ...[
                    const SizedBox(height: 4),
                    Text(
                      item['description'],
                      style: const TextStyle(color: AppColors.danger, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MockNodePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..lineTo(size.width * 0.4, size.height * 0.5)
      ..lineTo(size.width * 0.7, size.height * 0.4)
      ..lineTo(size.width * 0.6, size.height * 0.2);

    canvas.drawPath(path, linePaint);

    // Nodes
    final points = [
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.4, size.height * 0.5),
      Offset(size.width * 0.7, size.height * 0.4),
      Offset(size.width * 0.6, size.height * 0.2),
    ];

    final colors = [AppColors.success, AppColors.danger, AppColors.success, AppColors.warning];

    for (int i = 0; i < points.length; i++) {
      if (colors[i] == AppColors.danger) {
        canvas.drawCircle(points[i], 24, Paint()..color = AppColors.danger.withOpacity(0.2));
      }
      canvas.drawCircle(points[i], 8, Paint()..color = Colors.white);
      canvas.drawCircle(points[i], 6, Paint()..color = colors[i]);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
