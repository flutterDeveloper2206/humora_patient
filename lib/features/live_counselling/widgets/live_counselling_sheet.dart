import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../bloc/live_counselling_bloc.dart';
import '../bloc/live_counselling_event.dart';
import '../bloc/live_counselling_state.dart';
import '../widgets/price_input_field.dart';
import '../widgets/pricing_card.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class LiveCounsellingSheet extends StatelessWidget {
  const LiveCounsellingSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LiveCounsellingBloc(),
      child: const LiveCounsellingSheetView(),
    );
  }

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const LiveCounsellingSheet(),
    );
  }
}

class LiveCounsellingSheetView extends StatelessWidget {
  const LiveCounsellingSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
              child: BlocBuilder<LiveCounsellingBloc, LiveCounsellingState>(
                builder: (context, state) {

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Price range",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "You can set price between this price range.",
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          PriceInputField(
                            label: "Minimum",
                            value: state.minPrice.toStringAsFixed(0),
                            onChanged: (val) {
                              final price =
                                  double.tryParse(val.replaceAll('₹', '')) ??
                                  0.0;
                              context.read<LiveCounsellingBloc>().add(
                                UpdateMinPrice(price),
                              );
                            },
                          ),
                          Text(
                            "—",
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 18.sp,
                            ),
                          ),
                          PriceInputField(
                            label: "Minimum",
                            value: state.maxPrice.toStringAsFixed(0),
                            onChanged: (val) {
                              final price =
                                  double.tryParse(val.replaceAll('₹', '')) ??
                                  0.0;
                              context.read<LiveCounsellingBloc>().add(
                                UpdateMaxPrice(price),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      const Divider(color: AppColors.divider),
                      SizedBox(height: 16.h),
                      Text(
                        "Pricing Setup Per Minute",
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      PricingCard(
                        title: "Chat",
                        subtitle: "Text consultatio",
                        imagePath: "assets/images/chat.png",
                        price: state.chatPrice,
                        onPriceChanged: (val) {
                          final price = double.tryParse(val) ?? 0.0;
                          context.read<LiveCounsellingBloc>().add(
                            UpdateChatPrice(price),
                          );
                        },
                      ),
                      PricingCard(
                        title: "Audio Call",
                        subtitle: "Audio consultatio",
                        imagePath: "assets/images/call.png",
                        price: state.audioPrice,
                        onPriceChanged: (val) {
                          final price = double.tryParse(val) ?? 0.0;
                          context.read<LiveCounsellingBloc>().add(
                            UpdateAudioPrice(price),
                          );
                        },
                      ),
                      PricingCard(
                        title: "Video Call",
                        subtitle: "Video consultatio",
                        imagePath: "assets/images/video.png",
                        price: state.videoPrice,
                        onPriceChanged: (val) {
                          final price = double.tryParse(val) ?? 0.0;
                          context.read<LiveCounsellingBloc>().add(
                            UpdateVideoPrice(price),
                          );
                        },
                      ),
                      SizedBox(height: 8.h),
                      _buildFreeCallCheckbox(context, state),
                      SizedBox(height: 20.h),
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
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                size: 24.sp,
              ),
            ),
          ),
          Text(
            "Live Counselling",
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeCallCheckbox(
    BuildContext context,
    LiveCounsellingState state,
  ) {
    return GestureDetector(
      onTap: () => context.read<LiveCounsellingBloc>().add(ToggleFreeCall()),
      child: Row(
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              color: state.isFreeCallEnabled
                  ? AppColors.darkButton
                  : AppColors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: state.isFreeCallEnabled
                    ? AppColors.darkButton
                    : AppColors.divider,
                width: 2,
              ),
            ),
            child: state.isFreeCallEnabled
                ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Free 5 min Call",
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "First 5 minutes free for new client",
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformFee() {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.info_outline, size: 16.sp, color: AppColors.textSecondary),
          SizedBox(width: 8.w),
          Text(
            "Platform Fee : 20%",
            style: AppTextStyles.caption.copyWith(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
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
      child: BlocBuilder<LiveCounsellingBloc, LiveCounsellingState>(
        builder: (context, state) {
          return CommonButton(
            text: "Confirm",
            isLoading: state.status == LiveCounsellingStatus.loading,
            onPressed: () {
              context.read<LiveCounsellingBloc>().add(SubmitLiveCounselling());
            },
            borderRadius: 12.r,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            textColor: AppColors.primary,
          );
        },
      ),
    );
  }
}
