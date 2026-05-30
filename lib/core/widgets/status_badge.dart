import 'package:flutter/material.dart';
import '../../app/config/app_colors.dart';

enum BadgeType { red, yellow, green, blue }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (type) {
      case BadgeType.red:
        return AppColors.dangerLight;
      case BadgeType.yellow:
        return AppColors.warningLight;
      case BadgeType.green:
        return AppColors.successLight;
      case BadgeType.blue:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.red:
        return AppColors.danger;
      case BadgeType.yellow:
        return AppColors.warning;
      case BadgeType.green:
        return AppColors.success;
      case BadgeType.blue:
        return AppColors.primary;
    }
  }
}
