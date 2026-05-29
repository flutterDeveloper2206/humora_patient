import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/specialization_bloc.dart';
import '../bloc/specialization_event.dart';
import '../bloc/specialization_state.dart';
import 'package:humora_patient/features/specialization/data/models/specialization_model.dart';

class SpecializationSelectionScreen extends StatelessWidget {
  const SpecializationSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SpecializationBloc()..add(LoadSpecializations()),
      child: const SpecializationSelectionView(),
    );
  }
}

class SpecializationSelectionView extends StatelessWidget {
  const SpecializationSelectionView({super.key});

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
        title: Text("Specialization Areas", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocBuilder<SpecializationBloc, SpecializationState>(
        builder: (context, state) {
          if (state is SpecializationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is SpecializationLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                  child: Text(
                    "Specialization offered",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: state.options.length,
                    itemBuilder: (context, index) {
                      final item = state.options[index];
                      final isSelected = state.selectedIds.contains(item.id);

                      return _buildSelectionItem(context, item, isSelected);
                    },
                  ),
                ),
                _buildBottomBar(context, state.selectedIds.length),
              ],
            );
          } else if (state is SpecializationError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildSelectionItem(
    BuildContext context,
    SpecializationModel item,
    bool isSelected,
  ) {
    return InkWell(
      highlightColor: AppColors.transparent,
      splashColor: AppColors.transparent,
      onTap: () =>
          context.read<SpecializationBloc>().add(ToggleSpecialization(item.id)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              item.value,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.transparent,
                borderRadius: BorderRadius.circular(6.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: AppColors.white, size: 16)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, int selectedCount) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () {
              context.read<SpecializationBloc>().add(ClearAllSpecializations());
            },
            child: Text(
              "Clear all",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(
            width: 180.w,
            child: CommonButton(
              text: "$selectedCount Selected",
              onPressed: () {
                context.push('/certificates');
              },
              borderRadius: 12.r,
            ),
          ),
        ],
      ),
    );
  }
}
