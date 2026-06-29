import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../widgets/common_button.dart';
import '../widgets/common_image.dart';

class CommonSuccessScreen extends StatefulWidget {
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
  State<CommonSuccessScreen> createState() => _CommonSuccessScreenState();
}

class _CommonSuccessScreenState extends State<CommonSuccessScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.buttonText == 'Decline Call') {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          context.pop();
          context.push('/video-call');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLite,
      body: Column(
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
                        path: widget.imagePath,
                        width: double.infinity,
                        height: 300.h,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    // Success Icon (Starburst/Cloud shape)
                    if (widget.icon.isNotEmpty)
                      CommonImage(
                        path: widget.icon,
                        width: double.infinity,
                        height: 84.h,
                        fit: BoxFit.contain,
                      ),
                    if (widget.icon.isNotEmpty) SizedBox(height: 24.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        widget.title,
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
                        widget.subtitle,
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
            if (widget.buttonText != 'Decline Call') ...{
              Column(
                children: [
                  const Divider(height: 1),
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: CommonButton(
                      text: widget.buttonText,
                      onPressed: widget.onButtonPressed,
                      borderRadius: 12.r,
                    ),
                  ),
                ],
              ),
            } else ...{
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: widget.onButtonPressed,
                      child: Container(
                        height: 60.w,
                        width: 60.w,
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: CommonImage(path: 'assets/image/streamline-plump_call-hang-up.png'),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Decline Call",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            },
          ],
        ),
    );
  }
}
