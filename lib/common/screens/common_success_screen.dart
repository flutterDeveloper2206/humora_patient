import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/common_button.dart';
import '../widgets/common_image.dart';

class CommonSuccessScreen extends StatelessWidget {
  final String imagePath;
  final String icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onButtonPressed;

  const CommonSuccessScreen({
    super.key,
    required this.imagePath,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 40.h),
                    // Top Illustration
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: CommonImage(
                        path: imagePath,
                        width: double.infinity,
                        height: 300.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Success Icon (Starburst/Cloud shape)
                    CommonImage(
                      path: icon,
                      width: double.infinity,
                      height: 84.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 24.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h2.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),

                    // Subtitle
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40.w),
                      child: Text(
                        subtitle,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),

            // Bottom Button with Divider
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.all(24.w),
              child: CommonButton(
                text: buttonText,
                onPressed: onButtonPressed,
                borderRadius: 12.r,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
