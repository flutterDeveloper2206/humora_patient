import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AvailabilityChip extends StatelessWidget {
  final String label;
  final bool isAvailable;

  const AvailabilityChip({
    super.key,
    required this.label,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isAvailable
        ? const Color(0xFFFFF2F5)
        : AppColors.transparent;
    // final Color textColor = isAvailable
    //     ? AppColors.primary
    //     : AppColors.textSecondary;
    final Color borderColor = isAvailable
        ? AppColors.primary.withOpacity(0.2)
        : Color(0xffE6E8EA);

    return Container(
      width: 84.w,
      padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isAvailable ? AppColors.textPrimary : Color(0xff989C9F),
              fontSize: 11.sp,
              height: 1.15,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.bodySmall.copyWith(
              color: isAvailable ? Color(0xffE81848) : Color(0xff989C9F),
              fontWeight: FontWeight.w400,
              fontSize: 10.sp,
              height: 1.15,
            ),
          ),
        ],
      ),
    );
  }
}
