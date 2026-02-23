import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';

class OtpScreen extends StatefulWidget {
  final String destination;
  const OtpScreen({super.key, required this.destination});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

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
                    "We sent it to ${widget.destination}",
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
                              } else if (value.isEmpty && index > 0) {
                                _focusNodes[index - 1].requestFocus();
                              }
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      Text(
                        "Didn't get an email? ",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 12.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {},
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

            Divider(),
            SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: CommonButton(
                text: "Confirm",
                borderRadius: 12.r,
                onPressed: () {
                  context.push(
                    '/success',
                    extra: {
                      'imagePath': 'assets/image/onboarding_complete.png',
                      'icon': 'assets/images/right.png',
                      'title': "You’re successfully signed in!",
                      'subtitle': "Fill up personal details",
                      'onButtonPressed': () => context.go('/permissions'),
                    },
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
