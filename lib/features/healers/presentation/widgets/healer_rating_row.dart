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
      children: [
        ...List.generate(5, (index) {
          final isFull = index < rating.floor();
          final isHalf = index == rating.floor() && rating % 1 != 0;
          return Icon(
            isFull
                ? Icons.star
                : isHalf
                ? Icons.star_half
                : Icons.star_border,
            color: const Color(0xFFFCBF20),
            size: 16.sp,
          );
        }),
        SizedBox(width: 4.w),
        Text(
          rating.toString(),
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w500,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          "($reviewsCount)",
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
