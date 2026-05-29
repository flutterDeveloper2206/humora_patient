import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();

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
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is ResetPasswordLinkSent) {
            Future.delayed(const Duration(seconds: 2), () {
              if (context.mounted) {
                context.push('/otp');
              }
            });
          }
        },
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 26.h),
                    Text(
                      "Enter the email address associated with your account, and we'll email you a link to reset your password.",
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
                            controller: emailController,
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
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: emailController,
                      builder: (context, value, child) {
                        return BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            bool isLoading = state is AuthLoading;
                            bool isEmailValidFormat = RegExp(
                              r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                            ).hasMatch(emailController.text);
                            bool isButtonEnabled =
                                isEmailValidFormat && !isLoading;

                            return CommonButton(
                              text: "Send reset link",
                              isLoading: isLoading,
                              backgroundColor: isEmailValidFormat
                                  ? AppColors.primary
                                  : Color(0XFFFFF2F5),
                              textColor: isButtonEnabled
                                  ? AppColors.white
                                  : AppColors.textHint,
                              borderRadius: 12.r,
                              onPressed: isButtonEnabled
                                  ? () {
                                      context.read<AuthBloc>().add(
                                        ResetPasswordRequested(
                                          emailController.text,
                                        ),
                                      );
                                    }
                                  : () {}, // Disabled state, no action
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              // Link Sent Info Box
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  if (state is ResetPasswordLinkSent) {
                    return Positioned(
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
                              "A link to reset your password has been sent to ${state.email}",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 13.sp,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            InkWell(
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  ResetPasswordLinkClosed(),
                                );
                              },
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
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
