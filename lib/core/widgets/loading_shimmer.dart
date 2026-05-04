import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../app/config/app_colors.dart';

class LoadingShimmer extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  final int itemCount;
  final Axis direction;

  const LoadingShimmer({
    super.key,
    this.height = 80,
    this.width = double.infinity,
    this.borderRadius = 12,
    this.itemCount = 3,
    this.direction = Axis.vertical,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.border,
      highlightColor: AppColors.cardBg,
      child: direction == Axis.vertical
          ? Column(
              children: List.generate(itemCount, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    height: height,
                    width: width,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                );
              }),
            )
          : Row(
              children: List.generate(itemCount, (index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    height: height,
                    width: 160,
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
                );
              }),
            ),
    );
  }
}
