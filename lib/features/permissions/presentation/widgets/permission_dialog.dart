import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../common/widgets/common_button.dart';

class PermissionDialog extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onConfirm;
  final VoidCallback onSkip;
  final VoidCallback onClose;

  const PermissionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.onConfirm,
    required this.onSkip,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: onClose,
                  child: Icon(Icons.close, color: AppColors.black, size: 18.sp),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      title,
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 20.sp), // Balance for the close icon
              ],
            ),
          ),
          const Divider(height: 1),
          SizedBox(height: 32.h),

          // Icon in Circle
          Container(
            width: 70.w,
            height: 70.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBF0), // Light pink
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE91E63), // Pink/Red
              size: 28.sp,
            ),
          ),
          SizedBox(height: 32.h),

          // Description
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              description,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.black,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(height: 32.h),

          const Divider(height: 1),

          // Buttons
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: CommonButton(
                    text: 'Go to settings',
                    backgroundColor: const Color(0xFF1A1A1A),
                    borderRadius: 12.r,
                    textStyle: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    onPressed: onConfirm,
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: onSkip,
                  child: Text(
                    'No thanks',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
