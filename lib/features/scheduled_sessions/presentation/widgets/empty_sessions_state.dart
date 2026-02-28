import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class EmptySessionsState extends StatelessWidget {
  const EmptySessionsState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          CommonImage(
            path: 'assets/image/emptyimage.png',
            height: 280.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 32.h),
          Text(
            "You don't have any appointment for today.",
            textAlign: TextAlign.center,
            style: AppTextStyles.h1.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            "Let's add a new one to improve your health state.",
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              fontSize: 16.sp,
              color: const Color(0xff717171),
              fontWeight: FontWeight.w400,
            ),
          ),
          const Spacer(),
          // Explore Healers Button
          GestureDetector(
            onTap: () => context.go('/healers-list'),
            child: Container(
              height: 54.h,
              margin: EdgeInsets.only(bottom: 32.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Explore Healers',
                    style: AppTextStyles.button
                  ),
                  SizedBox(width: 8.w),
                  Icon(Icons.chevron_right, color: Colors.white, size: 20.sp),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
