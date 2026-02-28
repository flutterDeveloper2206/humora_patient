import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../common/widgets/common_image.dart';
import '../../common/widgets/common_button.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import 'bloc/notification_permission_bloc.dart';
import 'bloc/notification_permission_event.dart';
import 'bloc/notification_permission_state.dart';

class NotificationPermissionScreen extends StatelessWidget {
  const NotificationPermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationPermissionBloc(),
      child:
          BlocListener<NotificationPermissionBloc, NotificationPermissionState>(
            listener: (context, state) {
              if (state.status == NotificationPermissionStatus.granted ||
                  state.status == NotificationPermissionStatus.denied ||
                  state.status == NotificationPermissionStatus.skipped) {
                // context.go('/dashboard');
                context.push(
                  '/finish-signup',

                );
              }
            },
            child: const NotificationPermissionView(),
          ),
    );
  }
}

class NotificationPermissionView extends StatelessWidget {
  const NotificationPermissionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 34.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              CommonImage(path: "assets/image/notification.png", width: 60.w),
              SizedBox(height: 30.h),
              Text(
                "Turn on\nnotifications?",
                style: AppTextStyles.h1.copyWith(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,

                ),
              ),
              SizedBox(height: 16.h),
              Text(
                "Don’t miss important messages like check-in details and account activity",
                style: AppTextStyles.bodyMedium.copyWith(
                  fontSize: 16.sp,

                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 44.h),
              CommonButton(
                text: "Yes, notify me",
                textStyle: AppTextStyles.button.copyWith(color: AppColors.white,fontWeight: FontWeight.w600),
                onPressed: () {
                  context.read<NotificationPermissionBloc>().add(
                    RequestNotificationPermission(),
                  );
                },
                backgroundColor: AppColors.darkButton,
                width: 160.w,
              ),
              SizedBox(height: 16.h),
              CommonButton(
                text: "Skip",
                onPressed: () {
                  context.read<NotificationPermissionBloc>().add(
                    SkipNotificationPermission(),
                  );
                },
                backgroundColor: AppColors.white,
                textColor: AppColors.black,
                side: const BorderSide(color: AppColors.black, width: 1.5),
                borderRadius: 12.r,
                width: 100.w,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
