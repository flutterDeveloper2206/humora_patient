import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/features/healing_sessions/widgets/pricing_card_healing.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/healing_sessions_bloc.dart';
import '../widgets/healing_input_field.dart';

class HealingSessionsSheet extends StatefulWidget {
  const HealingSessionsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider(
        create: (context) => HealingSessionsBloc(),
        child: const HealingSessionsSheet(),
      ),
    );
  }

  @override
  State<HealingSessionsSheet> createState() => _HealingSessionsSheetState();
}

class _HealingSessionsSheetState extends State<HealingSessionsSheet> {
  late TextEditingController _priceController;
  late TextEditingController _timeController;

  @override
  void initState() {
    super.initState();
    final state = context.read<HealingSessionsBloc>().state;
    _priceController = TextEditingController(
      text: state.sessionPrice.toStringAsFixed(2),
    );
    _timeController = TextEditingController(text: "${state.sessionTime}");
  }

  @override
  void dispose() {
    _priceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HealingSessionsBloc, HealingSessionsState>(
      listener: (context, state) {
        if (state.status == HealingSessionStatus.success) {
          context.push(
            '/success',
            extra: {
              'icon': 'assets/images/right.png',
              'imagePath': 'assets/images/rs.png', // Temporary illustration
              'title': "Request sent!",
              'subtitle':
                  "your request has been send to our team\nfor review. you will be notified\nonce its approved",
              'buttonText': "Got it!",
              'onButtonPressed': () => context.push(
                '/success',
                extra: {
                  'icon': 'assets/images/wrong.png',
                  'imagePath': 'assets/images/rw.png', // Temporary illustration
                  'title': "Request Not Approved",
                  'subtitle':
                      "your request was not approved by out\nteam.Please try again.",
                  'buttonText': "Got it!",
                  'onButtonPressed': () => context.go('/sessions'),
                },
              ),
            },
          );
        }
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(context),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
                child: BlocBuilder<HealingSessionsBloc, HealingSessionsState>(
                  builder: (context, state) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTabSwitcher(context, state),
                        SizedBox(height: 18.h),
                        _buildInputs(context, state),
                        SizedBox(height: 14.h),
                        const Divider(color: AppColors.divider),
                        SizedBox(height: 14.h),
                        Text(
                          "Pricing Setup Per Session",
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          "Session only available for audio/video call only",
                          style: AppTextStyles.caption.copyWith(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        _buildPricingRow(context, state),
                        SizedBox(height: 16.h),
                        _buildPlatformFee(),
                      ],
                    );
                  },
                ),
              ),
            ),
            _buildBottomButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 0.5.h),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 20.sp,
              ),
            ),
          ),
          Text("Healing Sessions", style: AppTextStyles.titleMedium),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher(BuildContext context, HealingSessionsState state) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundTab,
        border: Border.all(color: AppColors.black.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(30.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTabButton(
              context,
              title: "Personal Healing",
              isSelected: state.tab == HealingSessionTab.personal,
              onTap: () => context.read<HealingSessionsBloc>().add(
                const ToggleTab(HealingSessionTab.personal),
              ),
            ),
          ),
          Expanded(
            child: _buildTabButton(
              context,
              title: "Group Healing",
              isSelected: state.tab == HealingSessionTab.group,
              onTap: () => context.read<HealingSessionsBloc>().add(
                const ToggleTab(HealingSessionTab.group),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(title, style: AppTextStyles.bodyMedium),
      ),
    );
  }

  Widget _buildInputs(BuildContext context, HealingSessionsState state) {
    if (state.tab == HealingSessionTab.personal) {
      return Row(
        children: [
          Expanded(
            child: HealingInputField(
              label: "Min Pricing",
              value: "₹ ${state.minPrice.toStringAsFixed(0)}",
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              "—",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 20.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Expanded(
            child: HealingInputField(
              label: "Fixed Time",
              value: "${state.fixedTime} min",
              icon: Icon(
                Icons.timer_outlined,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: HealingInputField(
              label: "Max capacity",
              value: "${state.maxCapacity}",
              icon: Icon(
                Icons.person_outline,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              "—",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 20.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Expanded(
            child: HealingInputField(
              label: "Min Pricing",
              value: "₹ ${state.minPrice.toStringAsFixed(0)}",
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              "—",
              style: TextStyle(
                color: AppColors.textSecondary.withOpacity(0.5),
                fontSize: 20.sp,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
          Expanded(
            child: HealingInputField(
              label: "Fixed Time",
              value: "${state.fixedTime} min",
              icon: Icon(
                Icons.timer_outlined,
                size: 16.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildPricingRow(BuildContext context, HealingSessionsState state) {
    return PricingCardHealing(
      title: "Video Call",
      subtitle: "Video consultatio",
      imagePath: "assets/images/video.png",
      price: state.sessionPrice,
      time: state.sessionTime,
      onPriceChanged: (val) {
        final price = double.tryParse(val) ?? 0.0;
        context.read<HealingSessionsBloc>().add(UpdateSessionPrice(price));
      },
      onTimeChanged: (val) {
        final time = int.tryParse(val) ?? 0;
        context.read<HealingSessionsBloc>().add(UpdateSessionTime(time));
      },
    );
  }

  Widget _buildPlatformFee() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 14.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(
            "Platform Fee : 20%",
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: BlocBuilder<HealingSessionsBloc, HealingSessionsState>(
        builder: (context, state) {
          return CommonButton(
            text: "Confirm",
            isLoading: state.status == HealingSessionStatus.loading,
            onPressed: () {
              context.read<HealingSessionsBloc>().add(
                const SubmitHealingSessions(),
              );
            },
            borderRadius: 12.r,
          );
        },
      ),
    );
  }
}
