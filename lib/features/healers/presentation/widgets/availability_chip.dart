import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AvailabilityChip extends StatelessWidget {
  final String label;
  final bool isAvailable;
  final String? time;

  const AvailabilityChip({
    super.key,
    required this.label,
    required this.isAvailable,
    this.time,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isAvailable
        ? const Color(0xFFFFF2F5)
        : const Color(0xFFF5F5F5);
    final Color borderColor = isAvailable
        ? AppColors.primary.withValues(alpha: 0.15)
        : const Color(0xFFE6E8EA);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFFFDE8EB)
                  : const Color(0xFFE6E8EA),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.calendar_month_rounded,
              color: isAvailable ? AppColors.primary : AppColors.textSecondary,
              size: 14.sp,
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isAvailable ? AppColors.textPrimary : const Color(0xFF989C9F),
                  fontWeight: FontWeight.w600,
                  fontSize: 11.sp,
                  height: 1.15,
                ),
              ),
              if (time != null) ...[
                SizedBox(height: 2.h),
                Text(
                  time!,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isAvailable ? AppColors.primary : const Color(0xFF989C9F),
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                    height: 1.15,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
