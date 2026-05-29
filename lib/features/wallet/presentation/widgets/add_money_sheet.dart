import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/stripe_config.dart';
import '../bloc/wallet_bloc.dart';
import '../bloc/wallet_event.dart';
import '../bloc/wallet_state.dart';

class AddMoneySheet extends StatefulWidget {
  final String currencySymbol;

  const AddMoneySheet({super.key, required this.currencySymbol});

  static Future<void> show(BuildContext context, String currencySymbol) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<WalletBloc>(),
        child: AddMoneySheet(currencySymbol: currencySymbol),
      ),
    );
  }

  @override
  State<AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<AddMoneySheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  int? _selectedPreset;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  static const _presets = [100, 200, 500, 1000];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _animController.dispose();
    super.dispose();
  }

  double? get _amount {
    if (_selectedPreset != null) return _selectedPreset!.toDouble();
    final text = _amountController.text.trim();
    if (text.isEmpty) return null;
    return double.tryParse(text);
  }

  void _submit() {
    final amount = _amount;
    if (amount == null || amount <= 0) return;
    context.read<WalletBloc>().add(WalletTopUpRequested(amount));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Add money',
                    style: AppTextStyles.h2.copyWith(fontSize: 22.sp),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Min ${widget.currencySymbol}${StripeConfig.minimumTopUpAmount.toStringAsFixed(0)} · Secured by Stripe',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 10.h,
                    children: _presets.map((value) {
                      final selected = _selectedPreset == value;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedPreset = value;
                            _amountController.clear();
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: 18.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primaryLite
                                : Colors.white,
                            borderRadius: BorderRadius.circular(14.r),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.divider,
                              width: selected ? 1.5 : 1,
                            ),
                          ),
                          child: Text(
                            '${widget.currencySymbol}$value',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    onChanged: (_) => setState(() => _selectedPreset = null),
                    style: AppTextStyles.h3,
                    decoration: InputDecoration(
                      prefixText: '${widget.currencySymbol} ',
                      prefixStyle: AppTextStyles.h3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      hintText: 'Custom amount',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                      ),
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14.r),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  BlocBuilder<WalletBloc, WalletState>(
                    buildWhen: (p, c) =>
                        p.isTopUpInProgress != c.isTopUpInProgress,
                    builder: (context, state) {
                      final amount = _amount;
                      final valid = amount != null &&
                          amount >= StripeConfig.minimumTopUpAmount;

                      return CommonButton(
                        text: state.isTopUpInProgress
                            ? 'Processing...'
                            : 'Pay with Stripe',
                        isLoading: state.isTopUpInProgress,
                        isDisabled: !valid || state.isTopUpInProgress,
                        onPressed: _submit,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
