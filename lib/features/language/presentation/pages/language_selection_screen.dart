import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/language_bloc.dart';
import '../bloc/language_event.dart';
import '../bloc/language_state.dart';
import 'package:humora_patient/features/language/data/models/language_model.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LanguageBloc()..add(LoadLanguages()),
      child: const LanguageSelectionView(),
    );
  }
}

class LanguageSelectionView extends StatelessWidget {
  const LanguageSelectionView({super.key});

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
            size: 28,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Select language",
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocBuilder<LanguageBloc, LanguageState>(
        builder: (context, state) {
          if (state is LanguageLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is LanguageLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
                  child: Text(
                    "Language offered",
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    itemCount: state.languages.length,
                    itemBuilder: (context, index) {
                      final language = state.languages[index];
                      final isSelected = state.selectedIds.contains(
                        language.id,
                      );

                      return _buildLanguageItem(context, language, isSelected);
                    },
                  ),
                ),
                _buildBottomBar(context, state.selectedIds.length),
              ],
            );
          } else if (state is LanguageError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox();
        },
      ),
    );
  }

  Widget _buildLanguageItem(
    BuildContext context,
    LanguageModel language,
    bool isSelected,
  ) {
    return InkWell(
      highlightColor: AppColors.transparent,
      splashColor: AppColors.transparent,
      onTap: () =>
          context.read<LanguageBloc>().add(ToggleLanguage(language.id)),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language.languageName,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 16.sp,
                color: AppColors.textPrimary,
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
                  width: 1.5,
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
              context.read<LanguageBloc>().add(ClearAllLanguages());
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
                context.push(
                  '/primary-expertise',

                );
              },
              borderRadius: 12.r,
            ),
          ),
        ],
      ),
    );
  }
}
