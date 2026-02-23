import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../common/widgets/common_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/expertise_bloc.dart';
import '../bloc/expertise_event.dart';
import '../bloc/expertise_state.dart';
import '../models/expertise_model.dart';

class PrimaryExpertiseScreen extends StatelessWidget {
  const PrimaryExpertiseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ExpertiseSelectionBloc()..add(LoadExpertiseOptions()),
      child: const PrimaryExpertiseView(),
    );
  }
}

class PrimaryExpertiseView extends StatelessWidget {
  const PrimaryExpertiseView({super.key});

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
          "Primary Expertise",
          style: AppTextStyles.titleMedium
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 24.h),
            child: Text(
              "Choose the areas where you have the most\nexperience and confidence.",
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<ExpertiseSelectionBloc, ExpertiseSelectionState>(
              builder: (context, state) {
                if (state is ExpertiseLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ExpertiseLoaded) {
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.45,
                        ),
                    itemCount: state.options.length,
                    itemBuilder: (context, index) {
                      final option = state.options[index];
                      final isSelected = state.selectedId == option.id;

                      return _ExpertiseCard(
                        option: option,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<ExpertiseSelectionBloc>().add(
                            SelectExpertise(option.id),
                          );
                        },
                      );
                    },
                  );
                } else if (state is ExpertiseError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BlocBuilder<ExpertiseSelectionBloc, ExpertiseSelectionState>(
        builder: (context, state) {
          final isEnabled =
              state is ExpertiseLoaded && state.selectedId != null;
          return CommonButton(
            text: "Confirm",
            isDisabled: !isEnabled,
            onPressed: () {
              // Navigate further
              context.push('/specialization');
            },
            borderRadius: 12.r,
          );
        },
      ),
    );
  }
}

class _ExpertiseCard extends StatelessWidget {
  final ExpertiseModel option;
  final bool isSelected;
  final VoidCallback onTap;

  const _ExpertiseCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppColors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CommonImage(
                  path: option.image,
                  width: 42.w,
                  height: 40.w,
                  fit: BoxFit.contain,
                ),
                _buildRadioIcon(),
              ],
            ),
            Text(
              option.value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                // color: AppColors.textPrimary,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadioIcon() {
    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.black : AppColors.border,
        ),
      ),
      child: Center(
        child: isSelected
            ? Container(
                width: 14.w,
                height: 14.w,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.black,
                ),
              )
            : null,
      ),
    );
  }
}
