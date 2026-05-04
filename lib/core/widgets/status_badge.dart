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
        return AppColors.badgeRedBg;
      case BadgeType.yellow:
        return AppColors.badgeYellowBg;
      case BadgeType.green:
        return AppColors.badgeGreenBg;
      case BadgeType.blue:
        return AppColors.badgeBlueBg;
    }
  }

  Color get _textColor {
    switch (type) {
      case BadgeType.red:
        return AppColors.badgeRedText;
      case BadgeType.yellow:
        return AppColors.badgeYellowText;
      case BadgeType.green:
        return AppColors.badgeGreenText;
      case BadgeType.blue:
        return AppColors.badgeBlueText;
    }
  }
}
