import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/utils/common_flushbar.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/healing_focus_bloc.dart';
import '../bloc/healing_focus_event.dart';
import '../bloc/healing_focus_state.dart';
import 'package:humora_patient/features/healing_focus/data/models/healing_focus_models.dart';
import '../widgets/healing_dropdown_field.dart';

class HealingFocusScreen extends StatefulWidget {
  const HealingFocusScreen({super.key});

  @override
  State<HealingFocusScreen> createState() => _HealingFocusScreenState();
}

class _HealingFocusScreenState extends State<HealingFocusScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HealingFocusBloc()..add(LoadHealingFocusData()),
      child: BlocConsumer<HealingFocusBloc, HealingFocusState>(
        listener: (context, state) {
          if (state is HealingFocusSaved) {
            context.push(
              '/success',
              extra: {
                'imagePath': 'assets/image/healingsuccess.png',
                'icon': 'assets/images/right.png',
                'title': "Thank You!",
                'subtitle':
                    "Based on your concern, we’ll match you\nwith Certified Healers who specialize\nin similar issues.",
                'buttonText': "Got it!",
                'onButtonPressed': () => context.push('/home'),
              },
            );
          } else if (state is HealingFocusError) {
            CommonFlushbar.error(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              centerTitle: true,
              title: Text(
                'Physical Well-Being',
                style: AppTextStyles.titleMedium,
              ),
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(0.5.h),
                child: Container(color: AppColors.divider, height: 0.5.h),
              ),
              leading: IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: AppColors.textPrimary,
                  size: 18.sp,
                ),
              ),
            ),
            body: SafeArea(
              child:
                  state is HealingFocusLoading || state is HealingFocusInitial
                  ? const Center(child: CircularProgressIndicator())
                  : state is HealingFocusLoaded
                  ? _buildContent(context, state)
                  : const Center(child: Text("Error loading data")),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, HealingFocusLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Center(
          child: CommonImage(
            path: 'assets/image/physical_wellbeing.png',
            height: 250.h,
            fit: BoxFit.contain,
          ),
        ),
        SizedBox(height: 24.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Your healing focus?",
            style: AppTextStyles.h2.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Row(
            children: state.categories.map((category) {
              final isSelected = state.selectedCategoryIds.contains(
                category.id,
              );
              return Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: GestureDetector(
                  onTap: () {
                    context.read<HealingFocusBloc>().add(
                      ToggleCategorySelection(category.id),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected ? AppColors.black : AppColors.border,
                        // width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Text(
                      category.name,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SizedBox(height: 24.h),
        Expanded(child: _buildSpecializationsGrid(context, state)),
        Divider(),
        _buildBottomNavigation(context, state),
      ],
    );
  }

  Widget _buildSpecializationsGrid(
    BuildContext context,
    HealingFocusLoaded state,
  ) {
    // If categories are selected, filter specializations to only those categories
    // Otherwise, show all specializations
    final filteredSpecializations = state.selectedCategoryIds.isEmpty
        ? state.specializations
        : state.specializations
              .where((s) => state.selectedCategoryIds.contains(s.categoryId))
              .toList();

    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 2.5,
      ),
      itemCount: filteredSpecializations.length,
      itemBuilder: (context, index) {
        final specialization = filteredSpecializations[index];
        final isSelected = state.selectedSpecializationIds.contains(
          specialization.id,
        );

        return GestureDetector(
          onTap: () {
            context.read<HealingFocusBloc>().add(
              ToggleSpecializationSelection(specialization.id),
            );
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFF5F8) : AppColors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isSelected ? const Color(0xFFFFD1DC) : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Checkbox
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFE95470)
                        : AppColors.white,
                    borderRadius: BorderRadius.circular(6.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFE95470)
                          : AppColors.border,
                    ),
                  ),
                  child: isSelected
                      ? Icon(Icons.check, color: AppColors.white, size: 14.sp)
                      : null,
                ),
                SizedBox(width: 8.w),
                // Icon
                Container(
                  width: 26.w,
                  height: 26.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5), // Light grey background
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    specialization.icon,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
                SizedBox(width: 8.w),
                // Text
                Expanded(
                  child: Text(
                    specialization.name,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    HealingFocusLoaded state,
  ) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 10.h),
      decoration: BoxDecoration(color: AppColors.background),
      child: Row(
        children: [
          TextButton(
            onPressed: () => context.pop(),
            child: Text(
              'Back',
              style: AppTextStyles.bodyLarge.copyWith(
                decoration: TextDecoration.underline,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: 140.w,
            height: 48.h,
            child: CommonButton(
              text: 'Next',
              isLoading: state.isSaving,
              backgroundColor: AppColors.primary,
              borderRadius: 10.r,
              textStyle: AppTextStyles.bodyLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              onPressed: () {
                context.read<HealingFocusBloc>().add(SaveHealingFocus());
              },
            ),
          ),
        ],
      ),
    );
  }
}
