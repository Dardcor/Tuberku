import 'package:flutter/material.dart';
import '../../../app/config/app_colors.dart';

class SourceChip extends StatelessWidget {
  final String text;

  const SourceChip({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified,
            size: 12,
            color: AppColors.badgeGreenText,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.badgeGreenText,
            ),
          ),
        ],
      ),
    );
  }
}
