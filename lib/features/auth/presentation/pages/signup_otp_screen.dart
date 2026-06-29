import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../common/utils/common_flushbar.dart';
import '../../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../utils/onboarding_navigator.dart';
import '../widgets/auth_otp_pinput.dart';

class SignupOtpScreen extends StatefulWidget {
  final String mobile;
  final String countryCode;

  const SignupOtpScreen({
    super.key,
    required this.mobile,
    required this.countryCode,
  });

  @override
  State<SignupOtpScreen> createState() => _SignupOtpScreenState();
}

class _SignupOtpScreenState extends State<SignupOtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  void _onVerifyPressed() {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      CommonFlushbar.error(context, "Please enter 6-digit OTP code");
      return;
    }

    context.read<AuthBloc>().add(
      VerifyOtpRequested(
        mobile: widget.mobile,
        countryCode: widget.countryCode,
        code: code,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 30,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text("Confirm account", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerificationSuccess) {
            CommonFlushbar.success(context, "OTP verified successfully!");
            OnboardingNavigator.go(context, state.onboardingStep);
          } else if (state is OtpSentSuccess) {
            CommonFlushbar.success(context, state.message);
          } else if (state is AuthError) {
            CommonFlushbar.error(context, state.message);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 32.h),
                  Text(
                    "Enter your verification code",
                    style: AppTextStyles.h2.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "We sent it to +${widget.countryCode} ${widget.mobile}",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  AuthOtpPinput(
                    controller: _otpController,
                    focusNode: _otpFocusNode,
                     showOuterBorder: true
                    ,
                    onCompleted: (_) => _onVerifyPressed(),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Text(
                        "Didn't get a code? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<AuthBloc>().add(
                            SendOtpRequested(
                              mobile: widget.mobile,
                              countryCode: widget.countryCode,
                            ),
                          );
                        },
                        child: Text(
                          "Send again",
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12.sp,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            const Divider(),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return CommonButton(
                    text: "Confirm",
                    isLoading: state is AuthLoading,
                    borderRadius: 12.r,
                    onPressed: _onVerifyPressed,
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
