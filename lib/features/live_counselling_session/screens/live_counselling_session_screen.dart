import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../common/widgets/common_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/live_counselling_session_bloc.dart';
import '../bloc/live_counselling_session_event.dart';
import '../bloc/live_counselling_session_state.dart';
import '../models/live_counselling_session_model.dart';

class LiveCounsellingSessionScreen extends StatelessWidget {
  const LiveCounsellingSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          LiveCounsellingSessionBloc()
            ..add(LoadLiveCounsellingSessionOptions()),
      child: const LiveCounsellingSessionView(),
    );
  }
}

class LiveCounsellingSessionView extends StatelessWidget {
  const LiveCounsellingSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 20.h,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Live Counselling Session",
          style: AppTextStyles.titleMedium,
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 26.h, 24.w, 24.h),
              child: Text(
                "Choose the areas where you have the most\nexperience and confidence.",
                style: AppTextStyles.bodyLarge.copyWith(
                  color: Color(0xff85898A),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              child:
                  BlocBuilder<
                    LiveCounsellingSessionBloc,
                    LiveCounsellingSessionState
                  >(
                    builder: (context, state) {
                      if (state is LiveCounsellingSessionLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is LiveCounsellingSessionLoaded) {
                        return GridView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 1.4,
                              ),
                          itemCount: state.options.length,
                          itemBuilder: (context, index) {
                            final option = state.options[index];
                            final isSelected = state.selectedId == option.id;

                            return _SessionCard(
                              option: option,
                              isSelected: isSelected,
                              onTap: () {
                                context.read<LiveCounsellingSessionBloc>().add(
                                  SelectLiveCounsellingSession(option.id),
                                );
                              },
                            );
                          },
                        );
                      } else if (state is LiveCounsellingSessionError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox();
                    },
                  ),
            ),
            TextButton(onPressed: () {
              context.push('/group-session');
            }, child: Text('for group video call')),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: BlocBuilder<LiveCounsellingSessionBloc, LiveCounsellingSessionState>(
        builder: (context, state) {
          final isEnabled =
              state is LiveCounsellingSessionLoaded && state.selectedId != null;
          return CommonButton(
            text: "Continue",
            isDisabled: !isEnabled,
            onPressed: () {
              if (state is LiveCounsellingSessionLoaded) {
                final selectedOption = state.options.firstWhere(
                  (o) => o.id == state.selectedId,
                );
                if (selectedOption.value == 'Chat') {
                  context.push('/chat');
                } else if (selectedOption.value == 'Voice Call') {
                  context.push('/voice-call');
                } else if (selectedOption.value == 'Video Call') {
                  context.push(
                    '/success',
                    extra: {
                      'icon': '',
                      'imagePath': 'assets/image/waitforwhile.png',
                      'title': "Please wait for while!",
                      'subtitle':
                          "Your healer is preparing the session.\nPlease sit comfortably in a quiet space.",
                      'buttonText': "Decline Call",
                      'onButtonPressed': () {
                        context.pop();
                      },
                    },
                  );
                }
              }
            },
            borderRadius: 12.r,
          );
        },
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final LiveCounsellingSessionModel option;
  final bool isSelected;
  final VoidCallback onTap;

  const _SessionCard({
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
                  width: 40.w,
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
                fontSize: 12.sp,
              ),
            ),
            Text(
              "₹${option.price} INR",
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
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
