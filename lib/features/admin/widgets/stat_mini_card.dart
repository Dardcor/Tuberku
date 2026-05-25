import 'package:flutter/material.dart';
import '../../../app/config/app_colors.dart';
import '../../../app/config/app_text_styles.dart';
import '../../../core/widgets/app_card.dart';

class StatMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;
  final String? subtitle;
  final Widget? customValueWidget;

  const StatMiniCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor = AppColors.primary,
    this.badge,
    this.badgeColor,
    this.subtitle,
    this.customValueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Baris atas: Icon + Title
              Row(
                children: [
                  Icon(icon, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Baris bawah: Value + Subtitle
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (customValueWidget != null)
                    customValueWidget!
                  else
                    Text(
                      value,
                      style: AppTextStyles.headlineMedium.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        height: 1,
                      ),
                    ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle!,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 9,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
              // Tambahkan jarak bawah jika ada badge, agar tidak overlap
              if (badge != null) const SizedBox(height: 14),
            ],
          ),
          if (badge != null)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor ?? AppColors.danger,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
