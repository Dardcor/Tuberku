import 'package:flutter/material.dart';
import '../../../app/config/app_colors.dart';

class ZoneBadge extends StatelessWidget {
  final String zone;

  const ZoneBadge({super.key, required this.zone});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: _textColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String get _label {
    switch (zone) {
      case 'merah':
        return 'Zona Merah';
      case 'kuning':
        return 'Zona Kuning';
      case 'hijau':
        return 'Zona Hijau';
      default:
        return 'N/A';
    }
  }

  Color get _backgroundColor {
    switch (zone) {
      case 'merah':
        return AppColors.dangerLight;
      case 'kuning':
        return AppColors.warningLight;
      case 'hijau':
        return AppColors.successLight;
      default:
        return AppColors.background;
    }
  }

  Color get _textColor {
    switch (zone) {
      case 'merah':
        return AppColors.badgeRedText;
      case 'kuning':
        return AppColors.badgeYellowText;
      case 'hijau':
        return AppColors.badgeGreenText;
      default:
        return AppColors.textSecondary;
    }
  }

  Color get _dotColor {
    switch (zone) {
      case 'merah':
        return AppColors.danger;
      case 'kuning':
        return AppColors.warning;
      case 'hijau':
        return AppColors.success;
      default:
        return AppColors.textHint;
    }
  }
}
