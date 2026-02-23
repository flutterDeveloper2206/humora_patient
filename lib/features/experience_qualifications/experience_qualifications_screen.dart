import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'bloc/experience_bloc.dart';
import 'bloc/experience_event.dart';
import 'bloc/experience_state.dart';

class ExperienceQualificationsScreen extends StatelessWidget {
  const ExperienceQualificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ExperienceBloc(),
      child: const ExperienceQualificationsView(),
    );
  }
}

class ExperienceQualificationsView extends StatelessWidget {
  const ExperienceQualificationsView({super.key});

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
        title: Text(
          "Experience & Qualifications",
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocConsumer<ExperienceBloc, ExperienceState>(
        listener: (context, state) {
          if (state.status == ExperienceStatus.success) {
            context.push('/certifications');
          } else if (state.status == ExperienceStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred"),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Practice method",
                        style: AppTextStyles.bodyLarge
                      ),
                      SizedBox(height: 12.h),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: AppColors.border.withOpacity(0.5),
                          ),
                        ),
                        child: TextField(
                          maxLines: 1,
                          onChanged: (val) => context
                              .read<ExperienceBloc>()
                              .add(UpdatePracticeMethod(val)),
                          style: AppTextStyles.bodyMedium,
                          decoration: InputDecoration(
                            hintText: "Enter description of practice method",
                            hintStyle: AppTextStyles.bodySmall.copyWith(
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16.w),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, ExperienceState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isLoading: state.status == ExperienceStatus.loading,
        isDisabled: !state.isValid,
        onPressed: () {
          context.read<ExperienceBloc>().add(SubmitExperience());
        },
        borderRadius: 12.r,
      ),
    );
  }
}
