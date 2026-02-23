import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'healing_sessions_sheet.dart';

class HealingSessionsScreen extends StatefulWidget {
  const HealingSessionsScreen({super.key});

  @override
  State<HealingSessionsScreen> createState() => _HealingSessionsScreenState();
}

class _HealingSessionsScreenState extends State<HealingSessionsScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically show the sheet for demonstration/testing
    WidgetsBinding.instance.addPostFrameCallback((_) {
      HealingSessionsSheet.show(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          // Background Placeholder (Amenities Screen)
          _buildBackgroundPlaceholder(context),

          // Button to trigger sheet manually if closed
          Center(
            child: ElevatedButton(
              onPressed: () => HealingSessionsSheet.show(context),
              child: const Text("Open Healing Sessions"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPlaceholder(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTopBadge("Save & exit"),
              _buildTopBadgeWithAvatar("Questions?"),
            ],
          ),
        ),
        SizedBox(height: 40.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Text(
            "Do you have any standout amenities?",
            style: AppTextStyles.h2.copyWith(fontSize: 18.sp),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              _buildAmenityCard(title: "Pool"),
              SizedBox(width: 16.w),
              _buildAmenityCard(title: "Hot tub", isSelected: true),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              _buildAmenityCard(title: "Patio"),
              SizedBox(width: 16.w),
              _buildAmenityCard(title: "BBQ grill"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBadge(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodySmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildTopBadgeWithAvatar(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 12.r, backgroundColor: Colors.orange.shade100),
          SizedBox(width: 8.w),
          Text(
            text,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityCard({required String title, bool isSelected = false}) {
    return Expanded(
      child: Container(
        height: 120.h,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? AppColors.black : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30.w,
              height: 30.w,
              color: const Color(0xFFF7F7F7),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
