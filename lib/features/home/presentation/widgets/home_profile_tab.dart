import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeProfileTab extends StatelessWidget {
  const HomeProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 120.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.person_outline_rounded, size: 64.sp, color: AppColors.textHint),
              SizedBox(height: 16.h),
              Text(
                'Profile',
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Profile settings coming soon.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
