import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

// DUMMY DATA
final mockTracingAlerts = [
  '1 titik interaksi kritis terdeteksi',
];

final List<Map<String, dynamic>> mockTracingLogs = [
  {
    'id': 'ID-TBC-2024-0891',
    'location': 'Kec. Genteng',
    'timeStart': '08:00',
    'timeEnd': '13:00',
    'pathStatus': [AppColors.warning, AppColors.danger, AppColors.success],
    'isCritical': true,
  },
  {
    'id': 'ID-TBC-2024-0812',
    'location': 'Kec. Gubeng',
    'timeStart': '09:00',
    'timeEnd': '15:00',
    'pathStatus': [AppColors.success, AppColors.success],
    'isCritical': false,
  },
];

class AdminTracingLogPage extends StatelessWidget {
  const AdminTracingLogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Log Tracing Mobilitas', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Alert Banner
            if (mockTracingAlerts.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.danger.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        mockTracingAlerts.first,
                        style: const TextStyle(
                          color: AppColors.danger,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Map Preview
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 200,
              decoration: BoxDecoration(
                color: const Color(0xFFE8E9F2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.map, size: 64, color: Colors.white),
                  // Mock intersecting paths
                  CustomPaint(
                    size: const Size(double.infinity, 200),
                    painter: _MockPathsPainter(),
                  ),
                  const Positioned(
                    bottom: 12,
                    right: 12,
                    child: Icon(Icons.fullscreen, color: Colors.black54),
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Log List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: mockTracingLogs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final log = mockTracingLogs[index];
                return _buildLogCard(log, context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(Map<String, dynamic> log, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                log['id'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (log['isCritical'] == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning, size: 12, color: AppColors.danger),
                      SizedBox(width: 4),
                      Text('! Tinggi', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${log['location']} • ${log['timeStart']} - ${log['timeEnd']}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          // Path visualizer mock
          Row(
            children: List.generate((log['pathStatus'] as List).length * 2 - 1, (index) {
              if (index % 2 == 1) return Expanded(child: Container(height: 2, color: AppColors.border));
              int colorIndex = index ~/ 2;
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: log['pathStatus'][colorIndex],
                  shape: BoxShape.circle,
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Analisis Jalur Pasien'),
            ),
          )
        ],
      ),
    );
  }
}

class _MockPathsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paint2 = Paint()
      ..color = AppColors.danger
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(size.width * 0.1, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.5, size.width * 0.8, size.height * 0.2);

    final path2 = Path()
      ..moveTo(size.width * 0.2, size.height * 0.1)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.4, size.width * 0.9, size.height * 0.9);

    canvas.drawPath(path1, paint1);
    canvas.drawPath(path2, paint2);

    // Intersection
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.42), 8, Paint()..color = AppColors.danger..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.42), 16, Paint()..color = AppColors.danger.withOpacity(0.3)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
