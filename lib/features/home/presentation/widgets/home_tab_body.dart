import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import 'package:humora_patient/core/constants/app_text_styles.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/healers/presentation/widgets/healer_card.dart';
import 'package:humora_patient/features/home/presentation/widgets/healer_carousel_card.dart';

class HomeTabBody extends StatefulWidget {
  final bool isLoading;
  final List<HealerModel> continueHealing;
  final List<HealerModel> available;

  const HomeTabBody({
    super.key,
    required this.isLoading,
    required this.continueHealing,
    required this.available,
  });

  @override
  State<HomeTabBody> createState() => _HomeTabBodyState();
}

class _HomeTabBodyState extends State<HomeTabBody> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 120.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      color: const Color(0xFF727776),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'SAT, 25 FEB 2026',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: const Color(0xFF454847),
                        fontWeight: FontWeight.w400,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.notifications_rounded,
                  color: const Color(0xFF627167),
                  size: 24.sp,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
            child: AutoSkeleton(
              enabled: widget.isLoading,
              child: Row(
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: const Color(0xFFFFFFFF),
                        width: 1.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18.r),
                      child: const CommonImage(
                        path: 'assets/image/doctorprofile.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Hello, Meet!',
                        style: AppTextStyles.h1.copyWith(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E1E1E),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(' 👋🏻', style: TextStyle(fontSize: 22.sp)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
            child: Container(
              height: 50.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: TextField(
                readOnly: true,
                onTap: widget.isLoading
                    ? null
                    : () => context.push('/healers-list'),
                decoration: InputDecoration(
                  hintText: 'Search here...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xFF000200),
                    fontSize: 15.sp,
                  ),
                  suffixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF7A7A7A),
                    size: 24.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Continue Healing',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                InkWell(
                  onTap: widget.isLoading
                      ? null
                      : () => context.push('/healers-list'),
                  child: Text(
                    'All Healers',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF717171),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 322.h,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.continueHealing.length,
              onPageChanged: (index) => setState(() => _currentPage = index),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: HealerCarouselCard(
                    healer: widget.continueHealing[index],
                    onTap: widget.isLoading
                        ? () {}
                        : () => context.push(
                              '/healer-detail/${widget.continueHealing[index].id}',
                            ),
                  ),
                );
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.continueHealing.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                width: _currentPage == index ? 36.w : 10.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? const Color(0xFF1E1E1E)
                      : const Color(0xFFE5E5E5),
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
            child: Row(
              children: [
                Text(
                  'Available Healers ',
                  style: AppTextStyles.h3.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 16.sp,
                    color: const Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  '(${widget.available.length})',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: const Color(0xFF9E9E9E),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          AutoSkeleton(
            enabled: widget.isLoading,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              itemCount: widget.available.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                return HealerCard(
                  healer: widget.available[index],
                  onTap: widget.isLoading
                      ? () {}
                      : () => context.push(
                            '/healer-detail/${widget.available[index].id}',
                          ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
