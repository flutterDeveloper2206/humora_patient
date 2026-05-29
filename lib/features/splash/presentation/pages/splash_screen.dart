import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';

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
    // Delay to show splash screen animation
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final hasToken = await SessionManager.hasToken();
    if (hasToken) {
      context.go('/home');
    } else {
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
            child: Center(
              child: CommonImage(
                height: double.maxFinite,
                fit: BoxFit.cover,
              path:   'assets/image/splash.png',

              ),
            ),
          ),
          Positioned(
            bottom: 15.h,
            right: 0,left: 0,
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
