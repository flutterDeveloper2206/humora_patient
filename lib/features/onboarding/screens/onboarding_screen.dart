import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../models/onboarding_model.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  static const List<OnboardingModel> _pages = [
    OnboardingModel(
      title: "Start your\nhealer journey",
      description:
          "Create your profile and explore\nthe app. See what other hosts\nare doing and get ideas.",
      image: "assets/images/onboarding1.png",
    ),
    OnboardingModel(
      title: "Make your profile\nstand out",
      description:
          "Showcase your specialties, add\nphotos of your space, and create\na compelling description.",
      image: "assets/images/onboarding2.png",
    ),
    OnboardingModel(
      title: "Connect with\nclients",
      description:
          "Respond to messages\nschedule appointments\nand manage bookings\nwithin the app.",
      image: "assets/images/onboarding3.png",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLite,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentIndex = index),
                itemBuilder: (context, index) =>
                    _OnboardingContent(data: _pages[index]),
              ),
            ),
            _buildIndicators(),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicators() {
    return Row(
      children: List.generate(
        _pages.length,
        (index) => Expanded(
          child: Container(
            height: 6.h,
            margin: EdgeInsets.only(
              right: index == _pages.length - 1 ? 0 : 8.w,
            ),
            decoration: BoxDecoration(
              color: _currentIndex + 1 > index
                  ? AppColors.black
                  : AppColors.indicatorInactive,
              // borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentIndex == 0
              ? SizedBox(width: 60.w) // Placeholder for spacing
              : TextButton(
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Text(
                    "Back",
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.black,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
          CommonButton(
            text: "Next",
            width: 150.w,
            height: 56.h,
            backgroundColor: AppColors.darkButton,
            textColor: AppColors.white,
            borderRadius: 16.r,
            onPressed: () {
              if (_currentIndex < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                context.push('/login');
              }
            },
          ),
        ],
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final OnboardingModel data;
  const _OnboardingContent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: CommonImage(
            path: data.image,
            width: double.infinity,
            fit: BoxFit.contain,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.title,
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                data.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 16.sp,
                  height: 1.3,wordSpacing: 2
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ],
    );
  }
}
