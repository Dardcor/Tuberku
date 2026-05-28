import 'package:flutter/material.dart';
import '../../../app/config/app_colors.dart';
import '../../../core/widgets/status_badge.dart';

class FacilityMarker extends StatelessWidget {
  final String name;
  final String distance;
  final bool hasStock;
  final VoidCallback? onTap;

  const FacilityMarker({
    super.key,
    required this.name,
    required this.distance,
    required this.hasStock,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasStock
                    ? AppColors.successLight
                    : AppColors.dangerLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.local_pharmacy,
                color: hasStock ? AppColors.success : AppColors.danger,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textHint,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        distance,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StatusBadge(
              text: hasStock ? 'Tersedia' : 'Habis',
              type: hasStock ? BadgeType.green : BadgeType.red,
            ),
          ],
        ),
      ),
    );
  }
}
