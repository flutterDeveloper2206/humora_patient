import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/notifications/notification_badge_controller.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/usecases/verify_token_usecase.dart';
import '../../../auth/presentation/utils/onboarding_navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);

    _controller.forward();

    _checkLoginState();
  }

  Future<void> _checkLoginState() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final hasToken = await SessionManager.hasToken();
    if (!mounted) return;
    if (!hasToken) {
      context.go('/welcome');
      return;
    }

    try {
      final token = await SessionManager.getToken();
      if (token == null || token.isEmpty) {
        await SessionManager.clearSession();
        if (!mounted) return;
        context.go('/welcome');
        return;
      }

      final verifyResult =
          await VerifyTokenUseCase(AuthRepositoryImpl())(token);
      await OnboardingNavigator.persistUserData(verifyResult.userData);
      await NotificationBadgeController.instance.refreshUnreadCount();

      if (!mounted) return;
      OnboardingNavigator.go(context, verifyResult.userData.onboardingStep);
    } catch (_) {
      await SessionManager.clearSession();
      if (!mounted) return;
      context.go('/welcome');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: SizedBox.expand(
              child: CommonImage(
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                path: 'assets/image/splash.png',
              ),
            ),
          ),
          Positioned(
            bottom: 15.h,
            right: 0,
            left: 0,
            child: Padding(
              padding: EdgeInsets.only(bottom: 32.h),
              child: Center(
                child: Text(
                  "Version 1.0.0",
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.grey9E,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
