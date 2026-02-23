import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLinkSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text("Reset password", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 26.h),
                  Text(
                    "Enter the email address associated with you account, and we'll email you a link to reset your password.",
                    style: AppTextStyles.bodyMedium,
                  ),
                  SizedBox(height: 28.h),

                  // Custom Email Input Box
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Email",
                          style: AppTextStyles.label.copyWith(
                            fontSize: 10.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        TextField(
                          controller: _emailController,
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: "Enter your email",
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textHint,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 28.h),
                  CommonButton(
                    text: "Send reset link",
                    backgroundColor: _emailController.text.isEmpty
                        ? AppColors.primaryLite
                        : AppColors.primary,
                    textColor: _emailController.text.isEmpty
                        ? AppColors.textHint
                        : AppColors.white,
                    borderRadius: 12.r,
                    onPressed: () async {
                      if (_emailController.text.isNotEmpty) {
                        setState(() {
                          _isLinkSent = true;
                        });
                        await Future.delayed(Duration(seconds: 1));
                        context.push(
                          '/otp',

                        );
                      }
                    },
                  ),
                ],
              ),
            ),

            // Link Sent Info Box
            if (_isLinkSent)
              Positioned(
                bottom: 24.h,
                left: 24.w,
                right: 24.w,
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: AppColors.border.withOpacity(0.5),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.mail_outline,
                            size: 20.sp,
                            color: AppColors.textPrimary,
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            "Check your inbox!",
                            style: AppTextStyles.titleMedium.copyWith(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "A link to reset your password has been sent to ${_emailController.text}",
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      InkWell(
                        onTap: () => setState(() => _isLinkSent = false),
                        child: Text(
                          "Close",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
