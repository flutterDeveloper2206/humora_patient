import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../../common/widgets/common_image.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import '../../../../../common/widgets/swipeable_button.dart';
import 'package:intl/intl.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import '../bloc/healer_detail_bloc.dart';
import '../bloc/healer_detail_event.dart';
import '../bloc/healer_detail_state.dart';
import '../widgets/healer_info_node.dart';
import '../widgets/certificate_card.dart';
import '../widgets/review_card.dart';

class HealerDetailScreen extends StatelessWidget {
  final String healerId;

  const HealerDetailScreen({super.key, required this.healerId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HealerDetailBloc()..add(LoadHealerDetail(healerId)),
      child: BlocBuilder<HealerDetailBloc, HealerDetailState>(
        builder: (context, state) {
          final isLoading = state is HealerDetailLoading || state is HealerDetailInitial;
          final loadedState = state is HealerDetailLoaded
              ? state
              : HealerDetailLoaded(
                  healer: HealerModel.dummy(),
                  selectedDate: DateTime.now(),
                  focusedDate: DateTime.now(),
                  selectedTimeCategory: 'Morning',
                  selectedTime: '11:00 AM',
                );

          return Scaffold(
            backgroundColor: Colors.white,
            body: _buildBody(context, state, loadedState, isLoading),
            bottomNavigationBar: (state is HealerDetailLoaded || state is HealerDetailLoading)
                ? _buildBottomBar(context, loadedState)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    HealerDetailState state,
    HealerDetailLoaded loadedState,
    bool isLoading,
  ) {
    if (state is HealerDetailError) {
      return Center(child: Text(state.message));
    }

    return AutoSkeleton(
      enabled: isLoading,
      effect: const ShimmerEffect(
        baseColor: Color(0xFFE0E0E0),
        highlightColor: Color(0xFFF5F5F5),
      ),
      child: _buildScreen(context, loadedState),
    );
  }

  Widget _buildScreen(BuildContext context, HealerDetailLoaded state) {
    final healer = state.healer;
    return CustomScrollView(
      slivers: [
        // Upper Section with Large Image
        SliverToBoxAdapter(
          child: ClipRRect(
            borderRadius: BorderRadiusGeometry.circular(24.w),
            child: Stack(
              children: [
                // Background Gradient/Light Color
                // Container(
                //   height: 440.h,
                //   decoration: const BoxDecoration(
                //     gradient: LinearGradient(
                //       begin: Alignment.topCenter,
                //       end: Alignment.bottomCenter,
                //       colors: [Color(0xFFF2F7FA), Colors.white],
                //     ),
                //   ),
                // ),
                CommonImage(path: 'assets/image/detailbg.png', height: 420.h),

                // Large Healer Image
                Positioned(
                  right: -10.w,
                  bottom: 0,
                  child: CommonImage(
                    path: healer.imageUrl,
                    height: 325.h,
                    fit: BoxFit.contain,
                  ),
                ),

                // Header Details
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 14.h),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0.w),
                        child: _buildAppBar(context),
                      ),
                      SizedBox(height: 32.h),

                      // Badges
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 22.0.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(9.w),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFD8ECDB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    color: Colors.green,
                                    size: 14.sp,
                                  ),
                                ),
                                SizedBox(width: 12.w),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBF0),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Text(
                                    healer.specialization,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 32.h),
                            SizedBox(
                              width: 200.w,
                              child: Text(
                                healer.name,
                                textAlign: TextAlign.start,
                                style: AppTextStyles.h1.copyWith(
                                  fontSize: 25.sp,
                                  fontWeight: FontWeight.w500,
                                  height: 1.1,
                                ),
                              ),
                            ),

                            SizedBox(height: 30.h),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '₹${healer.feesPerMin}',
                                    style: AppTextStyles.h2.copyWith(
                                      color: const Color(0xFF1B7B52),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: '/Session',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontSize: 11.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 30.h),
                          ],
                        ),
                      ),

                      // Info Grid
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        child: Row(
                          children: [
                            Expanded(
                              child: HealerInfoNode(
                                label: 'Experience',
                                value: '${healer.experienceYears}',
                                secondText: '/Year',
                                isGlass: true,

                                trailing: Icon(
                                  Icons.check_circle,
                                  color: Color(0xff0EC66E),
                                  size: 18.sp,
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),

                            Expanded(
                              child: HealerInfoNode(
                                label: 'Reviews',
                                value: '${healer.reviewsCount}',
                                trailing: CommonImage(
                                  path: 'assets/image/message.png',
                                  height: 16.h,
                                  width: 16.h,
                                ),
                                isGlass: true,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: HealerInfoNode(
                                label: 'Rating',
                                value: '${healer.rating}',
                                trailing: CommonImage(
                                  path: 'assets/image/star.png',
                                  height: 16.h,
                                  width: 16.h,
                                ),
                                isGlass: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tab Content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22.w),
                child: _buildSegmentedControl(context, state),
              ),
              SizedBox(height: 20.h),
              if (state.activeTabIndex == 0) ...[
                _buildAvailabilityContent(context, healer, state),
              ] else if (state.activeTabIndex == 1) ...[
                _buildEducationContent(healer),
              ] else if (state.activeTabIndex == 2) ...[
                _buildReviewsContent(healer),
              ] else if (state.activeTabIndex == 3) ...[
                _buildAboutContent(context, healer),
              ] else ...[
                // Placeholder for other tabs
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40.h),
                    child: Text(
                      "Coming Soon",
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ],
              SizedBox(height: 100.h), // Spacing for fab/bottom bar
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEducationContent(HealerModel healer) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandableDescription(
            text: healer.description,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 10.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.w,
              childAspectRatio: 1.3,
            ),
            padding: EdgeInsets.zero,
            itemCount: healer.education.length,
            itemBuilder: (context, index) {
              final edu = healer.education[index];
              return CertificateCard(
                title: edu.title,
                imagePath: edu.imagePath,
              );
            },
          ),
          SizedBox(height: 30.h),
          Text(
            'Experience',
            style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 12.h),
          ...healer.experienceDetails.map(
            (detail) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '•',
                    style: TextStyle(fontSize: 18.sp, color: Colors.grey),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      detail,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsContent(HealerModel healer) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 22.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Large Rating Header
          Center(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CommonImage(
                      path: 'assets/image/Layer 2 3.png',
                      width: 32.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      healer.rating.toString(),
                      style: AppTextStyles.h1.copyWith(
                        fontSize: 45.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    CommonImage(
                      path: 'assets/image/Layer 2 2.png',
                      width: 32.w,
                      height: 60.h,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Text(
                  'User favourite',
                  style: AppTextStyles.h2.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 19.sp,
                  ),
                ),
                SizedBox(height: 5.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Text(
                    'This health app is a user favourite based\non ratings, feedback and reliability',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          // Star and Review Count
          Row(
            children: [
              Icon(Icons.star, color: Colors.black, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                '${healer.rating} · ${healer.reviewsCount} reviews',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 18.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          // Horizontal Reviews List
          SizedBox(
            height: 200.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: healer.reviews.length,
              separatorBuilder: (context, index) => SizedBox(width: 16.w),
              itemBuilder: (context, index) {
                return ReviewCard(review: healer.reviews[index]);
              },
            ),
          ),
          SizedBox(height: 20.h),
          // Show All Button
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text(
                'Show all ${healer.reviewsCount} reviews',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionTypeSelector(
    BuildContext context,
    HealerDetailLoaded state,
  ) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(19.r),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<HealerDetailBloc>().add(
                    const ChangeSessionType(SessionType.personal),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  color: state.selectedSessionType == SessionType.personal
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(19.r),
                  boxShadow: state.selectedSessionType == SessionType.personal
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Personal Session',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp,
                    color: state.selectedSessionType == SessionType.personal
                        ? AppColors.textPrimary
                        : const Color(0xff727272),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => context.read<HealerDetailBloc>().add(
                    const ChangeSessionType(SessionType.group),
                  ),
              child: Container(
                decoration: BoxDecoration(
                  color: state.selectedSessionType == SessionType.group
                      ? Colors.white
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(19.r),
                  boxShadow: state.selectedSessionType == SessionType.group
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Group Session',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp,
                    color: state.selectedSessionType == SessionType.group
                        ? AppColors.textPrimary
                        : const Color(0xff727272),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityContent(
    BuildContext context,
    HealerModel healer,
    HealerDetailLoaded state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSessionTypeSelector(context, state),
              SizedBox(height: 16.h),
              _buildDateHeader(context, state),
              SizedBox(height: 5.h),
              Text(
                'Choose Date',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xff4C4C4C),
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 8.h),
            ],
          ),
        ),
        _buildDatePicker(context, healer, state),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              Text(
                'Choose Time',
                style: AppTextStyles.bodySmall.copyWith(
                  color: const Color(0xff4C4C4C),
                  fontSize: 13.sp,
                ),
              ),
              SizedBox(height: 5.h),
              _buildTimeCategoryPicker(context, state),
              SizedBox(height: 10.h),
              _buildTimeSlotPicker(context, healer, state),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateHeader(BuildContext context, HealerDetailLoaded state) {
    final date = state.focusedDate ?? state.selectedDate ?? DateTime.now();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          DateFormat('MMMM, yyyy').format(date),
          style: AppTextStyles.bodyLarge,
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () =>
                  context.read<HealerDetailBloc>().add(const NavigateWeek(-1)),
              child: Icon(Icons.chevron_left, size: 28.sp),
            ),
            SizedBox(width: 16.w),
            GestureDetector(
              onTap: () =>
                  context.read<HealerDetailBloc>().add(const NavigateWeek(1)),
              child: Icon(Icons.chevron_right, size: 28.sp),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    BuildContext context,
    HealerModel healer,
    HealerDetailLoaded state,
  ) {
    List<DateTime> dates = [];
    if (healer.rawSlots.isNotEmpty) {
      final uniqueDates = <String>{};
      for (final slot in healer.rawSlots) {
        if (slot.date.isNotEmpty && slot.sessionType == state.selectedSessionType.value) {
          uniqueDates.add(slot.date);
        }
      }
      for (final dateStr in uniqueDates) {
        try {
          dates.add(DateTime.parse(dateStr));
        } catch (_) {}
      }
      dates.sort((a, b) => a.compareTo(b));
    }

    if (dates.isEmpty) {
      final focusedDate =
          state.focusedDate ?? state.selectedDate ?? DateTime.now();
      // Calculate Monday of the focused week
      final monday = focusedDate.subtract(
        Duration(days: focusedDate.weekday - 1),
      );
      dates = List.generate(
        7,
        (index) => monday.add(Duration(days: index)),
      );
    }

    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 22.w, top: 3.h, bottom: 5.h),
        itemCount: dates.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected =
              state.selectedDate?.day == date.day &&
              state.selectedDate?.month == date.month &&
              state.selectedDate?.year == date.year;

          return GestureDetector(
            onTap: () => context.read<HealerDetailBloc>().add(SelectDate(date)),
            child: Container(
              width: 40.w,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              decoration: BoxDecoration(
                color: isSelected ? null : Colors.white,
                gradient: isSelected
                    ? const LinearGradient(
                        // begin: Alignment.topLeft,
                        // end: Alignment.bottomRight,
                        transform: GradientRotation(6.6),
                        colors: [
                          Color(0xFF1F1F1F), // Base Dark
                          Color(0xFF333333), // Base Dark
                          Color(0xFF525252), // Central Shine
                          Color(0xFF333333), // Base Dark
                          Color(0xFF1F1F1F), // Base Dark
                        ],
                        stops: [0.0, 0.35, 0.55, 0.75, 1.0],
                      )
                    : null,
                borderRadius: BorderRadius.circular(21.r),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xfFFB5B5B26).withOpacity(0.15),
                    blurRadius: 1.5,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E').format(date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff7D7D7D),
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    date.day.toString(),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontSize: 15.sp,
                      // fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeCategoryPicker(
    BuildContext context,
    HealerDetailLoaded state,
  ) {
    final categories = ['Morning', 'Afternoon', 'Evening'];
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => SizedBox(width: 12.w),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = state.selectedTimeCategory == category;
          final isDisabled = category == 'Evening';

          return GestureDetector(
            onTap: () => context.read<HealerDetailBloc>().add(
                    SelectTimeCategory(category),
                  ),
            child: Stack(
              children: [
                Container(
                  width: 100.w,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: isSelected ? null : Colors.white,
                    gradient: isSelected
                        ? const LinearGradient(
                            transform: GradientRotation(7.2),
                            colors: [
                              Color(0xFF1F1F1F), // Base Dark
                              Color(0xFF333333), // Base Dark
                              Color(0xFF525252), // Central Shine
                              Color(0xFF333333), // Base Dark
                              Color(0xFF1F1F1F), // Base Dark
                            ],
                            stops: [0.0, 0.40, 0.55, 0.75, 1.0],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(21.r),
                    border: Border.all(color: const Color(0xFFF0F0F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xfFFB5B5B26).withOpacity(0.15),
                        blurRadius: 1.5,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      category,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 11.sp,
                        color: isSelected ? Colors.white : const Color(0xff2F2F2F),
                      ),
                    ),
                  ),
                ),
                // Diagonal stripes overlay for disabled state
                if (isDisabled)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(21.r),
                    child: CustomPaint(
                      painter: DiagonalStrikesPainter(
                        stripeColor: Color(0XFF5B5B5B26).withOpacity(0.15),
                        stripeWidth: 3.0,
                        spacing: 6.0,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 50.w),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeSlotPicker(
    BuildContext context,
    HealerModel healer,
    HealerDetailLoaded state,
  ) {
    final selectedDateStr = DateFormat('yyyy-MM-dd').format(state.selectedDate ?? DateTime.now());
    final dateSlots = healer.rawSlots
        .where((slot) => slot.date == selectedDateStr && slot.sessionType == state.selectedSessionType.value)
        .toList();
    
    final slots = <String>[];
    for (final slot in dateSlots) {
      int hour = 9;
      try {
        hour = int.parse(slot.startTime.split(':')[0]);
      } catch (_) {}
      
      String formatTime(String timeStr) {
        try {
          final parts = timeStr.split(':');
          final h = int.parse(parts[0]);
          final m = parts[1];
          final ampm = h >= 12 ? 'PM' : 'AM';
          final displayHour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
          return '${displayHour.toString().padLeft(2, '0')}:$m $ampm';
        } catch (_) {
          return timeStr;
        }
      }
      
      final displaySlot = '${formatTime(slot.startTime)} - ${formatTime(slot.endTime)}';
      
      if (state.selectedTimeCategory == 'Morning' && hour < 12) {
        slots.add(displaySlot);
      } else if (state.selectedTimeCategory == 'Afternoon' && hour >= 12 && hour < 16) {
        slots.add(displaySlot);
      } else if (state.selectedTimeCategory == 'Evening' && hour >= 16) {
        slots.add(displaySlot);
      }
    }

    if (slots.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Text(
            'No slots available for this period',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: slots.map((time) {
        final isSelected = state.selectedTime == time;
        return GestureDetector(
          onTap: () => context.read<HealerDetailBloc>().add(SelectTime(time)),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: isSelected ? null : Colors.white,
              gradient: isSelected
                  ? const LinearGradient(
                      transform: GradientRotation(7.2),
                      colors: [
                        Color(0xFF1F1F1F),
                        Color(0xFF333333),
                        Color(0xFF525252),
                        Color(0xFF333333),
                        Color(0xFF1F1F1F),
                      ],
                      stops: [0.0, 0.40, 0.55, 0.75, 1.0],
                    )
                  : null,
              borderRadius: BorderRadius.circular(21.r),
              border: Border.all(color: const Color(0xFFF0F0F0)),
              boxShadow: [
                BoxShadow(
                  color: Color(0xfFFB5B5B26).withOpacity(0.15),
                  blurRadius: 1.5,
                  spreadRadius: 0,
                  offset: const Offset(0, 0),
                ),
              ],
            ),
            child: Text(
              time,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 11.sp,
                color: isSelected ? Colors.white : const Color(0xff2F2F2F),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAboutContent(BuildContext context, HealerModel healer) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpandableDescription(
            text: healer.about,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w400,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 10.h),
          const Divider(),
          SizedBox(height: 5.h),
          // Healing Services Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Healing Services',
                      style: AppTextStyles.h3.copyWith(
                        fontWeight: FontWeight.w400,
                        fontSize: 18.sp,
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      'One-to-one and group healing services available',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  CommonImage(path: 'assets/image/hug.png', width: 40.w),
                  SizedBox(width: 5.2),
                  CommonImage(path: 'assets/image/4employee.png', width: 25.w),
                  SizedBox(width: 5.2),

                  CommonImage(path: 'assets/image/message2.png', width: 20.w),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (healer.services != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildPricingTable(
                    context,
                    healer.services!.oneToOne,
                    false,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildPricingTable(
                    context,
                    healer.services!.group,
                    true,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPricingTable(
    BuildContext context,
    HealingService service,
    bool isGroup,
  ) {
    final sessionType = isGroup ? SessionType.group : SessionType.personal;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Text(
              service.type,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 10.sp,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _buildPriceRow(
            context,
            'assets/image/audiocall.png',
            'Call',
            service.callPrice,
            sessionType,
            ConsultationType.audio,
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _buildPriceRow(
            context,
            'assets/image/videocall.png',
            'Video Call',
            service.videoPrice,
            sessionType,
            ConsultationType.video,
          ),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _buildPriceRow(
            context,
            'assets/image/chat.png',
            'Chat',
            service.chatPrice,
            sessionType,
            ConsultationType.chat,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String iconPath,
    String label,
    int price,
    SessionType sessionType,
    ConsultationType consultationType,
  ) {
    return GestureDetector(
      onTap: () {
        if (sessionType == SessionType.group) {
          context.push('/group-session');
          return;
        }
        if (consultationType == ConsultationType.audio) {
          context.push('/voice-call');
        } else if (consultationType == ConsultationType.video) {
          context.push('/video-call');
        } else if (consultationType == ConsultationType.chat) {
          context.push('/chat');
        }
      },
      child: Container(
        color: Colors.transparent, // For better tap area
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Row(
          children: [
            CommonImage(path: iconPath, width: 16.w, height: 16.w),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 10.5.sp,
                  color: AppColors.black,
                ),
              ),
            ),
            Container(width: 1.w, height: 20.h, color: const Color(0xFFF0F0F0)),
            SizedBox(width: 8.w),
            Text(
              '₹$price',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.black),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 18.h,
            color: AppColors.textPrimary,
          ),
          // padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 16.w),
        Text(
          'Healer Details',
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSegmentedControl(
    BuildContext context,
    HealerDetailLoaded state,
  ) {
    final tabs = ['Availability', 'Education', 'Reviews', 'About'];
    return Container(
      height: 44.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: List.generate(tabs.length, (index) {
          final isSelected = state.activeTabIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () =>
                  context.read<HealerDetailBloc>().add(ChangeTab(index)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  tabs[index],
                  style: AppTextStyles.bodySmall.copyWith(
                    fontSize: 11.sp,
                    color: isSelected
                        ? AppColors.textPrimary
                        : Color(0xff727272),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, HealerDetailLoaded state) {
    if (state.activeTabIndex == 0) {
      return Container(
        padding: EdgeInsets.fromLTRB(22.w, 12.h, 22.w, 32.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentGeometry.bottomCenter,
            end: AlignmentGeometry.topCenter,
            colors: [Color(0xffFAE0EA), Color(0xffFFFFFF)],
          ),
          color: Color(0xffFAE0EA),
        ),
        child: Row(
          children: [
            // Chat Button
            GestureDetector(
              onTap: () => context.push('/chat'),
              child: CommonImage(
                path: 'assets/image/grediantmessage.png',
                height: 45.h,
                width: 45.h,
              ),
            ),
            SizedBox(width: 14.w),
            // Book Now Button with Swipe
            Expanded(
              child: SwipeableButton(
                animationWidth: 210.0.w,
                buttonText: 'Book Now',isShowIcon: true,
                backgroundColor: AppColors.primary,
                iconPath: 'assets/image/gradiantarrow.png',
                onSwipeComplete: () {
                  context.push('/live-counselling-session');
                },
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}

class ExpandableDescription extends StatefulWidget {
  final String text;
  final TextStyle style;

  const ExpandableDescription({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final span = TextSpan(text: widget.text, style: widget.style);
        final tp = TextPainter(
          text: span,
          maxLines: 3,
          textDirection: ui.TextDirection.ltr,
        );
        tp.layout(maxWidth: constraints.maxWidth);

        // if not overflow just render plain text
        if (!tp.didExceedMaxLines) {
          return Text(widget.text, style: widget.style);
        }

        if (_isExpanded) {
          return RichText(
            text: TextSpan(
              style: widget.style,
              children: [
                TextSpan(text: widget.text),
                TextSpan(
                  text: '  Less',
                  style: widget.style.copyWith(
                    color: Color(0XFF3D71E2),
                    fontWeight: FontWeight.w700,
                    fontSize: 14.sp,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => setState(() => _isExpanded = false),
                ),
              ],
            ),
          );
        }

        // collapsed: need to trim to fit ellipsis + More
        final moreText = ' More';
        // find cutoff point
        String display = widget.text;
        int end = display.length;
        while (end > 0) {
          final test = display.substring(0, end) + '...' + moreText;
          final tp2 = TextPainter(
            text: TextSpan(text: test, style: widget.style),
            maxLines: 3,
            textDirection: ui.TextDirection.ltr,
          );
          tp2.layout(maxWidth: constraints.maxWidth);
          if (tp2.didExceedMaxLines) {
            end--;
            continue;
          }
          display = display.substring(0, end);
          break;
        }

        return RichText(
          text: TextSpan(
            style: widget.style,
            children: [
              TextSpan(text: display + '...'),
              TextSpan(
                text: moreText,
                style: widget.style.copyWith(
                  color: Color(0XFF3D71E2),
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () => setState(() => _isExpanded = true),
              ),
            ],
          ),
        );
      },
    );
  }
}

class DiagonalStrikesPainter extends CustomPainter {
  final Color stripeColor;
  final double stripeWidth;
  final double spacing;

  DiagonalStrikesPainter({
    required this.stripeColor,
    required this.stripeWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = stripeColor
      ..strokeWidth = stripeWidth;

    // Draw diagonal stripes from top-right to bottom-left
    final step = spacing + stripeWidth;
    for (double i = -size.height; i < size.width; i += step) {
      canvas.drawLine(
        Offset(size.width - i, 0),
        Offset(size.width - i - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(DiagonalStrikesPainter oldDelegate) {
    return oldDelegate.stripeColor != stripeColor ||
        oldDelegate.stripeWidth != stripeWidth ||
        oldDelegate.spacing != spacing;
  }
}

