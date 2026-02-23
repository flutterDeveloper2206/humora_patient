import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/bank_bloc.dart';
import '../bloc/bank_event.dart';
import '../bloc/bank_state.dart';
import '../models/bank_model.dart';
import '../widgets/connect_bank_sheet.dart';

class BankSelectionScreen extends StatelessWidget {
  const BankSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BankBloc()..add(LoadBanks()),
      child: const BankSelectionView(),
    );
  }
}

class BankSelectionView extends StatelessWidget {
  const BankSelectionView({super.key});

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
        title: Text("Select your bank", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: BlocBuilder<BankBloc, BankState>(
        builder: (context, state) {
          if (state.status == BankStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchBar(context),
                      SizedBox(height: 16.h),
                      Text("Select your bank", style: AppTextStyles.bodyLarge),
                      SizedBox(height: 16.h),
                      if (state.filteredPopularBanks.isNotEmpty)
                        _buildPopularBanksGrid(
                          context,
                          state.filteredPopularBanks,
                          state.selectedBank,
                        )
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: Text(
                            "No popular banks found matching your search.",
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      Text("All banks", style: AppTextStyles.bodyLarge),
                      Divider(color: AppColors.divider),
                      _buildAllBanksList(
                        context,
                        state.filteredBanks,
                        state.selectedBank,
                      ),
                      if (state.filteredBanks.isEmpty &&
                          state.filteredPopularBanks.isEmpty)
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 40.h),
                          child: Center(
                            child: Text(
                              "No banks found for '${state.searchQuery}'",
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, state.selectedBank),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: TextField(
        onChanged: (value) => context.read<BankBloc>().add(SearchBanks(value)),
        decoration: InputDecoration(
          hintText: "Search by bank name",
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          icon: Icon(Icons.search, color: AppColors.textSecondary, size: 20.sp),
          border: InputBorder.none,
          // contentPadding: EdgeInsets.symmetric(vertical: 14.h),
        ),
      ),
    );
  }

  Widget _buildPopularBanksGrid(
    BuildContext context,
    List<BankModel> banks,
    BankModel? selected,
  ) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16.h,
        crossAxisSpacing: 16.w,
        childAspectRatio: 0.80,
      ),
      itemCount: banks.length,
      itemBuilder: (context, index) {
        final bank = banks[index];
        final isSelected = selected?.id == bank.id;
        return GestureDetector(
          onTap: () => context.read<BankBloc>().add(SelectBank(bank)),
          child: Column(
            children: [
              Container(
                height: 80.w,
                width: 80.w,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.border.withOpacity(0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.account_balance_outlined,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                bank.name,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAllBanksList(
    BuildContext context,
    List<BankModel> banks,
    BankModel? selected,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: banks.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: AppColors.border.withOpacity(0.2)),
      itemBuilder: (context, index) {
        final bank = banks[index];
        final isSelected = selected?.id == bank.id;
        return ListTile(
          onTap: () => context.read<BankBloc>().add(SelectBank(bank)),
          leading: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.surface1,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance,
              size: 16.sp,
              color: AppColors.textSecondary,
            ),
          ),
          title: Text(
            bank.name,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
          trailing: isSelected
              ? Icon(Icons.check_circle, color: AppColors.primary, size: 20.sp)
              : null,
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, BankModel? selected) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isDisabled: selected == null,
        onPressed: () async {
          final result = await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            backgroundColor: AppColors.transparent,
            builder: (context) => const ConnectBankSheet(),
          );

          if (result == true) {
            if (context.mounted && selected != null) {
              context.push('/bank-details', extra: selected);
            }
          }
        },
        borderRadius: 12.r,
      ),
    );
  }
}
