import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class LoginToggle extends StatelessWidget {
  final bool isLogin;
  final ValueChanged<bool> onToggle;
  final String text1;
  final String text2;

  const LoginToggle({
    super.key, 
    required this.isLogin, 
    required this.onToggle,
    this.text1 = 'Login',
    this.text2 = 'Signup',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFF2),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Inner Shadow Simulation
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6.2.r,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
              ),
            ),
            // Background to cover the shadow except for the inner edge
            Positioned.fill(
              child: Container(
                margin: EdgeInsets.all(
                  1.w,
                ), // Slight margin to let shadow show through
                decoration: BoxDecoration(
                  color: const Color(0xFFF0EFF2),
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
            ),
            // Content
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isLogin ? Colors.white : Color(0xFFF0EFF2),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: isLogin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          text1,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: isLogin
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => onToggle(false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: !isLogin ? Colors.white : Color(0xFFF0EFF2),
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: !isLogin
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          text2,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: !isLogin
                                ? FontWeight.w500
                                : FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
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
