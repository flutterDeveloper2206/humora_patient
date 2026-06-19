import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HealerRatingRow extends StatelessWidget {
  final double rating;
  final int reviewsCount;

  const HealerRatingRow({
    super.key,
    required this.rating,
    required this.reviewsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final isFull = index < rating.floor();
          final isHalf = index == rating.floor() && rating % 1 != 0;
          return Icon(
            isFull
                ? Icons.star_rounded
                : isHalf
                ? Icons.star_half_rounded
                : Icons.star_border_rounded,
            color: const Color(0xFFFCBF20),
            size: 18.sp,
          );
        }),
        SizedBox(width: 8.w),
        Text(
          rating.toStringAsFixed(1),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13.sp,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          "($reviewsCount reviews)",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 13.sp,
          ),
        ),
      ],
    );
  }
}
