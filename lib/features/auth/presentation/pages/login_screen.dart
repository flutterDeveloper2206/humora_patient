import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import '../../../../../common/utils/common_flushbar.dart';
import '../widgets/login_toggle.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = TextEditingController();
  String _selectedCountryCode = '91';
  bool _isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool get _isInputEmail {
    if (!_isLogin) return false;
    final text = _inputController.text.trim();
    if (text.isEmpty) return true;
    return text.contains('@') || RegExp(r'[a-zA-Z]').hasMatch(text);
  }

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_onInputChanged);
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

  void _onInputChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _inputController.removeListener(_onInputChanged);
    _inputController.dispose();
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
            } else if (state is OtpSentSuccess) {
              CommonFlushbar.success(context, state.message);
              context.push(
                '/signup-otp',
                extra: {
                  'mobile': _inputController.text.trim(),
                  'countryCode': _selectedCountryCode,
                },
              );
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
                            'Please enter your details',
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
                          SizedBox(height: 15.h),

                          // Input Label
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 4.w),
                              child: Text(
                                _isLogin
                                    ? 'Email or Mobile number'
                                    : 'Mobile number',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xff4C4C4C),
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 8.h),

                          // Unified Input (Email or Mobile number with auto identity)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: TextField(
                              controller: _inputController,
                              maxLength: !_isInputEmail ? 10 : 1000,
                              keyboardType: _isInputEmail
                                  ? TextInputType.emailAddress
                                  : TextInputType.phone,
                              style: AppTextStyles.bodyMedium,
                              decoration: InputDecoration(
                                counterText: "",
                                hintText: _isInputEmail
                                    ? 'Enter email address or phone'
                                    : 'Enter mobile number',
                                hintStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.grey[400],
                                ),
                                prefixIcon: _isInputEmail
                                    ? Icon(
                                        Icons.person,
                                        color: Colors.black,
                                        size: 20.sp,
                                      )
                                    : Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(width: 12.w),
                                          DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _selectedCountryCode,
                                              icon: const Icon(
                                                Icons.arrow_drop_down,
                                                color: Colors.black,
                                              ),
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.black,
                                                  ),
                                              onChanged: (String? newValue) {
                                                if (newValue != null) {
                                                  setState(() {
                                                    _selectedCountryCode =
                                                        newValue;
                                                  });
                                                }
                                              },
                                              items: const [
                                                DropdownMenuItem(
                                                  value: '91',
                                                  child: Text('🇮🇳 +91'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1',
                                                  child: Text('🇺🇸 +1'),
                                                ),
                                                DropdownMenuItem(
                                                  value: '44',
                                                  child: Text('🇬🇧 +44'),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Container(
                                            width: 1,
                                            height: 24.h,
                                            color: Colors.grey[300],
                                          ),
                                          SizedBox(width: 8.w),
                                        ],
                                      ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.h,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.h),

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
                                    final text = _inputController.text.trim();
                                    if (text.isEmpty) {
                                      CommonFlushbar.error(
                                        context,
                                        "Please enter email or mobile number",
                                      );
                                      return;
                                    }
                                    if (_isInputEmail) {
                                      context.read<AuthBloc>().add(
                                        EmailLoginRequested(text),
                                      );
                                    } else {
                                      context.read<AuthBloc>().add(
                                        SendOtpRequested(
                                          mobile: text,
                                          countryCode: _selectedCountryCode,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 10.h),

                          // // Divider
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Divider(color: AppColors.divider),
                          //     ),
                          //     Padding(
                          //       padding: EdgeInsets.symmetric(horizontal: 16.w),
                          //       child: Text(
                          //         'Or Continue With',
                          //         style: AppTextStyles.bodySmall.copyWith(
                          //           color: Colors.grey,
                          //         ),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       child: Divider(color: AppColors.divider),
                          //     ),
                          //   ],
                          // ),
                          // SizedBox(height: 10.h),
                          //
                          // // Social Buttons
                          // _buildSocialButton(
                          //   'Continue with Google',
                          //   'assets/images/google.png',
                          //   backgroundColor: Colors.white,
                          //   textColor: Colors.black,
                          //   hasBorder: true,
                          //   onTap: () => context.read<AuthBloc>().add(
                          //     GoogleLoginRequested(),
                          //   ),
                          // ),
                          // SizedBox(height: 12.h),
                          // _buildSocialButton(
                          //   'Continue with Apple',
                          //   'assets/images/apple.png',
                          //   backgroundColor: Colors.black,
                          //   textColor: Colors.white,
                          //   onTap: () => context.read<AuthBloc>().add(
                          //     AppleLoginRequested(),
                          //   ),
                          // ),
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
