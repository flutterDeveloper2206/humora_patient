import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import '../../bloc/welcome_bloc.dart';
import '../../bloc/welcome_event.dart';
import '../../bloc/welcome_state.dart';
import '../../../../common/widgets/common_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WelcomeBloc(),
      child: const WelcomeView(),
    );
  }
}

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<WelcomeBloc, WelcomeState>(
        listener: (context, state) {
          if (state is WelcomeNavigateToLogin) {
            context.push('/login');
          } else if (state is WelcomeNavigateToSignup) {
            context.push(
              '/login',
            ); // Signup not yet implemented, routing to login for now
          }
        },
        child: Stack(
          children: [
            // Background with ripples
            CommonImage(path: 'assets/image/welcombg.png', fit: BoxFit.cover),
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  // Top Header: Welcome to Humora
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: RichText(
                        text: TextSpan(
                          text: 'Welcome to ',
                          style: AppTextStyles.h1.copyWith(
                            fontSize: 28.sp,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                          children: [
                            TextSpan(
                              text: 'Humora',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 28.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Healing Journey\nBegin Your',
                              style: AppTextStyles.h1.copyWith(
                                fontSize: 38.sp,
                                height: 0.9,
                                letterSpacing: -1,
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Connect with trusted healers for personalized sessions. Find balance, clarity, and peace anytime.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            SizedBox(height: 20.h),
                            SizedBox(
                              height: 46.h,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CommonButton(
                                      text: 'Get Started',
                                      backgroundColor: AppColors.white,
                                      textColor: AppColors.textPrimary,
                                      textStyle: AppTextStyles.bodyLarge
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                          ),
                                      onPressed: () {
                                        context.read<WelcomeBloc>().add(
                                          WelcomeGetStartedTapped(),
                                        );
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: CommonButton(
                                      text: 'Sign In',
                                      backgroundColor: Colors.transparent,
                                      textStyle: AppTextStyles.bodyLarge
                                          .copyWith(
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.white,
                                          ),
                                      side: const BorderSide(
                                        color: AppColors.white,
                                        width: 1,
                                      ),
                                      onPressed: () {
                                        context.read<WelcomeBloc>().add(
                                          WelcomeSignInTapped(),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
