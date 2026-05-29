import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DayChip extends StatelessWidget {
  final String dayName;
  final String dayNumber;
  final bool isSelected;
  final VoidCallback onTap;

  const DayChip({
    super.key,
    required this.dayName,
    required this.dayNumber,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(12.r),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              dayName,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? AppColors.white : AppColors.textSecondary,
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (dayNumber != "-") ...[
              SizedBox(height: 8.h),
              Container(
                height: 24.w,width: 24.w,
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color:!isSelected ?const Color(0xFFF7F7F7): AppColors.white,
                  borderRadius: BorderRadius.circular(100)
                ),
                child: Center(
                  child: Text(
                    dayNumber,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
