import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<String> _previousValues = List.generate(6, (_) => "");

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String get _otpCode {
    return _controllers.map((c) => c.text).join();
  }

  void _onVerifyPressed() {
    final code = _otpCode;
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
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is OtpVerificationSuccess) {
              CommonFlushbar.success(context, "OTP verified successfully!");

              // dynamic navigation based on onboardingStep
              if (state.onboardingStep == 1) {
                context.push('/notification-permission', extra: {'fromSignup': true});
              } else if (state.onboardingStep == 2) {
                context.push('/healing-focus');
              } else if (state.onboardingStep == 3) {
                context.push('/home');
              } else {
                context.push('/home'); // Fallback to Dashboard
              }
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
                    Container(
                      height: 54.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40.w,
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (event) {
                                if (event.isKeyPressed(
                                  LogicalKeyboardKey.backspace,
                                )) {
                                  if (_controllers[index].text.isEmpty &&
                                      index > 0) {
                                    _controllers[index - 1].clear();
                                    _focusNodes[index - 1].requestFocus();
                                    _previousValues[index - 1] = "";
                                  }
                                }
                              },
                              child: TextField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                style: AppTextStyles.h2.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  counterText: "",
                                  border: InputBorder.none,
                                  hintText: "—",
                                  hintStyle: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                onChanged: (value) {
                                  if (value.isNotEmpty && index < 5) {
                                    _focusNodes[index + 1].requestFocus();
                                  }
                                  _previousValues[index] = value;
                                },
                              ),
                            ),
                          );
                        }),
                      ),
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
      ),
    );
  }
}
