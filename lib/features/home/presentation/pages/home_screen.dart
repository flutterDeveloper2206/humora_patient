import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import 'package:humora_patient/core/constants/app_text_styles.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/healers/presentation/widgets/healer_card.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_bloc.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_event.dart';
import 'package:humora_patient/features/home/presentation/bloc/home_state.dart';
import 'package:humora_patient/features/home/presentation/widgets/bottom_nav_bar.dart';
import 'package:humora_patient/features/home/presentation/widgets/healer_carousel_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(FetchHomeData()),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          clipBehavior: Clip.none,
          alignment: AlignmentGeometry.bottomCenter,
          children: [
            SafeArea(
              bottom: false,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeError) {
                    return Center(child: Text(state.message));
                  }

                  final isLoading = state is HomeLoading || state is HomeInitial;
                  final continueHealing = (state is HomeLoaded)
                      ? state.continueHealingHealers
                      : List.generate(3, (_) => HealerModel.dummy());
                  final available = (state is HomeLoaded)
                      ? state.availableHealers
                      : List.generate(4, (_) => HealerModel.dummy());

                  return SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 20.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar
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
                                    "SAT, 25 FEB 2026",
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

                        // User Greeting
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 0),
                          child: AutoSkeleton(
                            enabled: isLoading,
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
                                    child: CommonImage(
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
                                      "Hello, Meet!",
                                      style: AppTextStyles.h1.copyWith(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF1E1E1E),
                                      ),
                                    ),
                                    SizedBox(width: 6.w),
                                    Text(
                                      " 👋🏻",
                                      style: TextStyle(fontSize: 22.sp),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Search field
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
                              onTap: isLoading ? null : () {
                                context.push('/healers-list');
                              },
                              decoration: InputDecoration(
                                hintText: "Search here...",
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

                        // Horizontal Section 1
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Continue Healing",
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              InkWell(
                                onTap: isLoading ? null : () {
                                  context.push('/healers-list');
                                },
                                child: Text(
                                  "All Healers",
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
                            itemCount: continueHealing.length,
                            onPageChanged: (index) {
                              setState(() => _currentPage = index);
                            },
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 20.w),
                                child: HealerCarouselCard(
                                  healer: continueHealing[index],
                                  onTap: isLoading
                                      ? () {}
                                      : () => context.push(
                                            '/healer-detail/${continueHealing[index].id}',
                                          ),
                                ),
                              );
                            },
                          ),
                        ),

                        // Line Indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            continueHealing.length,
                            (index) {
                              return AnimatedContainer(
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
                              );
                            },
                          ),
                        ),

                        // Section 2 Header
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 10.h, 20.w, 16.h),
                          child: Row(
                            children: [
                              Text(
                                "Available Healers ",
                                style: AppTextStyles.h3.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.sp,
                                  color: const Color(0xFF1E1E1E),
                                ),
                              ),
                              Text(
                                "(${available.length})",
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
                          enabled: isLoading,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            itemCount: available.length,
                            separatorBuilder: (context, index) =>
                                SizedBox(height: 12.h),
                            itemBuilder: (context, index) {
                              return HealerCard(
                                healer: available[index],
                                onTap: isLoading
                                    ? () {}
                                    : () => context.push(
                                          '/healer-detail/${available[index].id}',
                                        ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: 120.h,)
                      ],
                    ),
                  );
                },
              ),
            ),
            HomeBottomNavBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() => _currentIndex = index);
                if (index == 1) context.push('/scheduled-sessions');
                if (index == 2) context.push('/wallet');
                if (index == 3) context.push('/chat');
              },
            ),
          ],
        ),
        // bottomNavigationBar: HomeBottomNavBar(
        //   currentIndex: _currentIndex,
        //   onTap: (index) {
        //     setState(() => _currentIndex = index);
        //     if (index == 1) context.push('/scheduled-sessions');
        //     if (index == 2) context.push('/payment-method');
        //     if (index == 3) context.push('/chat');
        //   },
        // ),
      ),
    );
  }
}
