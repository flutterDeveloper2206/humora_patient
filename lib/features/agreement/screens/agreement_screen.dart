import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/agreement_bloc.dart';
import '../bloc/agreement_event.dart';
import '../bloc/agreement_state.dart';

class AgreementScreen extends StatelessWidget {
  const AgreementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AgreementBloc(),
      child: const AgreementView(),
    );
  }
}

class AgreementView extends StatelessWidget {
  const AgreementView({super.key});

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
        title: Text("Agreement", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: BlocBuilder<AgreementBloc, AgreementState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 26.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System & Compliance",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w500,
                          fontSize: 22.sp,
                          letterSpacing: -0.5,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        "Manage your agreements, visibility, and system preferences.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 48.h),
                      _buildLargeCheckboxItem(
                        context,
                        isActive: state.termsAccepted,
                        onToggle: () =>
                            context.read<AgreementBloc>().add(ToggleTerms()),
                        title: "Agree to Platform Terms & Policies",
                        subtitle:
                            "I confirm that I have read and agree to the platform’s terms and policies.",
                      ),
                      SizedBox(height: 32.h),
                      _buildLargeCheckboxItem(
                        context,
                        isActive: state.ethicsAccepted,
                        onToggle: () =>
                            context.read<AgreementBloc>().add(ToggleEthics()),
                        title: "Content & Ethical Guidelines Acceptance",
                        subtitle:
                            "I confirm that my services and content will follow ethical and platform guidelines.",
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLargeCheckboxItem(
    BuildContext context, {
    required bool isActive,
    required VoidCallback onToggle,
    required String title,
    required String subtitle,
  }) {
    return InkWell(
      onTap: onToggle,
      splashColor: AppColors.transparent,
      highlightColor: AppColors.transparent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 25.w,
            height: 25.w,
            decoration: BoxDecoration(
              color: isActive ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: isActive ? AppColors.black : AppColors.border,
                width: 2,
              ),
            ),
            child: isActive
                ? Icon(Icons.check, color: AppColors.white, size: 22.sp)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AgreementState state) {
    final isReady = state.termsAccepted && state.ethicsAccepted;
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Get started",
        isDisabled: !isReady,
        onPressed: () {
          // Proceed to notification permission
          context.push('/notification-permission');
        },
        borderRadius: 12.r,
      ),
    );
  }
}
