import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const HomeBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Background Custom Paint
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            top: 20.h,
            child: CustomPaint(painter: _BottomNavPainter()),
          ),

          // Navigation Row
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildNavItem(0, "Home", imagePath: 'assets/image/home-2.png'),
                _buildNavItem(
                  1,
                  "My Sessions",
                  imagePath: 'assets/image/stash_data-date-light.png',
                ),
                SizedBox(width: 60.w), // Space for centered button
                _buildNavItem(
                  3,
                  "Message",
                  imagePath: 'assets/image/icon-park-outline_message.png',
                ),
                _buildNavItem(
                  4,
                  "Profile",
                  imagePath: 'assets/image/user.png',
                ),
              ],
            ),
          ),

          // Floating Centered Button
          Positioned(
            top: -10,
            child: GestureDetector(
              onTap: () => onTap(2),
              child: Container(
                width: 62.w,
                height: 62.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFF52D56),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF52D56).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: CommonImage(
                    path: 'assets/image/commonwallet.png',
                    color: Colors.white,
                    height: 26.h,
                    width: 26.h,
                  ),
                ),
              ),
            ),
          ),
          // Wallet label manually placed
          Positioned(
            bottom: 25.h,
            child: Text(
              "Wallet",
              style: AppTextStyles.bodySmall.copyWith(
                color: currentIndex == 2
                    ? const Color(0xFFF52D56)
                    : const Color(0xFF7A7A7A),
                fontSize: 10.sp,
                fontWeight: currentIndex == 2
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    String label, {
    IconData? icon,
    String? imagePath,
  }) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSelected)
            Container(
              width: 14.w,
              height: 2.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF52D56),
                borderRadius: BorderRadius.circular(2.r),
              ),
            )
          else
            SizedBox(height: 10.h),
          if (imagePath != null)
            CommonImage(
              path: imagePath,
              color: isSelected
                  ? const Color(0xFFF52D56)
                  : const Color(0xFFB0B0B0),
              height: 24.sp,
              width: 24.sp,
            )
          else if (icon != null)
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFFF52D56)
                  : const Color(0xFFB0B0B0),
              size: 24.sp,
            ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: isSelected
                  ? const Color(0xFFF52D56)
                  : const Color(0xFF7A7A7A),
              fontSize: 10.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final host = Rect.fromLTWH(0, 0, size.width, size.height);
    // Guest rect corresponds to the floating button + some margin for the notch
    // Button is 62.w in size and located at top:0 in the stack.
    // This custom paint is at top:20.h. So its relative top is -20.h.
    final double buttonSize = 74.w; // 62.w + 12.w margin
    final Rect guest = Rect.fromLTWH(
      size.width / 2 - (buttonSize / 2),
      -buttonSize / 2 - 4.h, // Adjusted to push the notch up accurately
      buttonSize,
      buttonSize,
    );

    final path = MyShape().getOuterPath(host, guest);

    // Draw normal shadow
    canvas.drawShadow(path, Colors.black, 8, true);

    // Draw background
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    // Draw top border
    final borderPaint = Paint()
      ..color = const Color(0xFFE8E8E8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
class MyShape extends CircularNotchedRectangle {
  @override
  Path getOuterPath(Rect host, Rect? guest) {
    final path = Path();

    final double centerX = host.width / 2;

    // 🔥 Apple style tuning
    const double curveWidth = 180;  // wider = smoother
    const double curveHeight = 45;  // height of upward bump

    path.moveTo(host.left, host.top);

    // Left flat part
    path.lineTo(centerX - curveWidth / 2, host.top);

    // Smooth upward curve (convex)
    path.cubicTo(
      centerX - curveWidth * 0.20,
      host.top,
      centerX - curveWidth * 0.25,
      host.top - curveHeight,
      centerX,
      host.top - curveHeight,
    );

    path.cubicTo(
      centerX + curveWidth * 0.25,
      host.top - curveHeight,
      centerX + curveWidth * 0.18,
      host.top,
      centerX + curveWidth / 2,
      host.top,
    );

    // Right flat part
    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();

    return path;
  }
}