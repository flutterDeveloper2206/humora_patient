import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/bank_details_bloc.dart';
import '../bloc/bank_details_event.dart';
import '../bloc/bank_details_state.dart';
import '../models/bank_model.dart';

class BankDetailsScreen extends StatelessWidget {
  final BankModel bank;

  const BankDetailsScreen({super.key, required this.bank});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => BankDetailsBloc(),
      child: BankDetailsView(bank: bank),
    );
  }
}

class BankDetailsView extends StatelessWidget {
  final BankModel bank;
  const BankDetailsView({super.key, required this.bank});

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
        title: Text("Bank Details", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocConsumer<BankDetailsBloc, BankDetailsState>(
        listener: (context, state) {
          if (state.status == BankDetailsStatus.success) {

            context.push('/security-number');
          } else if (state.status == BankDetailsStatus.error) {
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
                    vertical: 20.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildBankLogo(),
                      SizedBox(height: 24.h),
                      _buildLabel("Account holder name"),
                      _buildInputField(
                        hint: "Enter account holder name",
                        onChanged: (val) => context.read<BankDetailsBloc>().add(
                          UpdateAccountHolderName(val),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z\s]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _buildLabel("Account number"),
                      _buildInputField(
                        hint: "Enter Account number",
                        onChanged: (val) => context.read<BankDetailsBloc>().add(
                          UpdateAccountNumber(val),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _buildLabel("IFSC Code"),
                      _buildInputField(
                        hint: "Enter IFSC code",
                        onChanged: (val) => context.read<BankDetailsBloc>().add(
                          UpdateIFSCCode(val),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Z0-9]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _buildLabel("UPI"),
                      _buildInputField(
                        hint: "Enter UPI",
                        onChanged: (val) =>
                            context.read<BankDetailsBloc>().add(UpdateUPI(val)),
                      ),
                      SizedBox(height: 18.h),
                      _buildLabel("PAN number"),
                      _buildInputField(
                        hint: "Enter PAN number",
                        onChanged: (val) => context.read<BankDetailsBloc>().add(
                          UpdatePANNumber(val),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Z0-9]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      _buildLabel("GST number"),
                      _buildInputField(
                        hint: "Enter GST number",
                        onChanged: (val) => context.read<BankDetailsBloc>().add(
                          UpdateGSTNumber(val),
                        ),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[A-Z0-9]'),
                          ),
                        ],
                      ),
                      SizedBox(height: 32.h),
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

  Widget _buildBankLogo() {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: AppColors.white,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(8.w),
      child: const Icon(
        Icons.account_balance,
        color: Colors.blue,
      ), // SBI-like icon for demo or use bank logo
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String hint,
    required Function(String) onChanged,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: TextField(
        onChanged: onChanged,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        style: AppTextStyles.bodyMedium,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary.withOpacity(0.6),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context, BankDetailsState state) {
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
        isLoading: state.status == BankDetailsStatus.loading,
        isDisabled: !state.isValid,
        onPressed: () {
          context.read<BankDetailsBloc>().add(SubmitBankDetails());
        },
        borderRadius: 12.r,
      ),
    );
  }
}
