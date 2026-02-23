import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import '../../../../common/utils/common_flushbar.dart';
import './widgets/login_toggle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryLiteFE,
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              if (_isLogin) {
                CommonFlushbar.success(context, "Login Successful");
                context.push('/notification-permission');
              } else {
                CommonFlushbar.success(context, "Signup Successful");
                context.push('/finish-signup');
              }
            } else if (state is AuthError) {
              CommonFlushbar.error(context, state.message);
            }
          },
          child: SingleChildScrollView(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    // SizedBox(height: 70.h),
                    // Top Illustration
                    CommonImage(
                      path: _isLogin
                          ? 'assets/image/login.png'
                          : 'assets/image/signup.png',
                      height: _isLogin ? 280 : 250.h,
                      fit: BoxFit.cover,
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          Text(
                            'Welcome Back',
                            style: AppTextStyles.h1.copyWith(
                              fontSize: 20.sp,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Welcome back. Please enter your details',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.grey[500],
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // Login/Signup Toggle
                          LoginToggle(
                            isLogin: _isLogin,
                            onToggle: (value) {
                              setState(() {
                                _isLogin = value;
                              });
                            },
                          ),
                          SizedBox(height: 10.h),

                          // Email Input
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              controller: _emailController,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                hintText: 'ronakpatel@gmail.com',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[400],
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                  size: 20.sp,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                ),
                              ),
                            ),
                          ),
                          if (!_isLogin) ...[
                            SizedBox(height: 10.h),
                            // Password Input (Only for Signup)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: Colors.grey[200]!),
                              ),
                              child: TextField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: AppTextStyles.bodyMedium,
                                decoration: InputDecoration(
                                  hintText: 'Admin@1234',
                                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                                    color: Colors.grey[400],
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.black,
                                    size: 20.sp,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: Colors.black,
                                      size: 20.sp,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16.h,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          SizedBox(height: 10.h),

                          // Continue Button
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              return SizedBox(
                                height: 46.h,
                                child: CommonButton(
                                  text: 'Continue',
                                  isLoading: state is AuthLoading,
                                  backgroundColor: AppColors.primary,
                                  borderRadius: 12.r,
                                  textStyle: AppTextStyles.bodyLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  onPressed: () {
                                    if (_emailController.text.isEmpty) {
                                      CommonFlushbar.error(
                                        context,
                                        "Please enter email",
                                      );
                                      return;
                                    }
                                    if (!_isLogin &&
                                        _passwordController.text.isEmpty) {
                                      CommonFlushbar.error(
                                        context,
                                        "Please enter password",
                                      );
                                      return;
                                    }

                                    if (_isLogin) {
                                      context.read<AuthBloc>().add(
                                        EmailLoginRequested(
                                          _emailController.text,
                                        ),
                                      );
                                    } else {
                                      context.read<AuthBloc>().add(
                                        EmailSignupRequested(
                                          _emailController.text,
                                          _passwordController.text,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10.h),

                          // Divider
                          Row(
                            children: [
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Text(
                                  'Or Continue With',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Divider(color: AppColors.divider),
                              ),
                            ],
                          ),
                          SizedBox(height: 10.h),

                          // Social Buttons
                          _buildSocialButton(
                            'Continue with Google',
                            'assets/images/google.png',
                            backgroundColor: Colors.white,
                            textColor: Colors.black,
                            hasBorder: true,
                            onTap: () => context.read<AuthBloc>().add(
                              GoogleLoginRequested(),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          _buildSocialButton(
                            'Continue with Apple',
                            'assets/images/apple.png',
                            backgroundColor: Colors.black,
                            textColor: Colors.white,
                            onTap: () => context.read<AuthBloc>().add(
                              AppleLoginRequested(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(
    String text,
    String iconPath, {
    required Color backgroundColor,
    required Color textColor,
    bool hasBorder = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 46.h,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.r),
          border: hasBorder ? Border.all(color: Colors.grey[200]!) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconPath,
              width: 18.w,
              height: 18.h,
              color: text.contains('Apple') ? AppColors.white : null,
              errorBuilder: (context, error, stackTrace) => Icon(
                text.contains('Apple') ? Icons.apple : Icons.g_mobiledata,
                color: textColor,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              text,
              style: AppTextStyles.bodyLarge.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
