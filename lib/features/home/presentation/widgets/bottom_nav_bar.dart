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
            top: 0,
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
            bottom: 10.h,
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
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 8, true);

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
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    final double notchRadius = guest.width / 2.0;

    const double s1 = 8.0;
    const double s2 = 1.0;

    final double r = notchRadius;
    final double a = -1.0 * r - s2;
    final double b = host.top - guest.center.dy;

    final double n2 = math.sqrt(b * b * r * r * (a * a + b * b - r * r));
    final double p2xA = ((a * r * r) - n2) / (a * a + b * b);
    final double p2xB = ((a * r * r) + n2) / (a * a + b * b);
    final double p2yA = math.sqrt(r * r - p2xA * p2xA);
    final double p2yB = math.sqrt(r * r - p2xB * p2xB);

    final List<Offset> p = List<Offset>.filled(6, Offset.zero);

    // p0, p1, and p2 are the control points for segment A.
    p[0] = Offset(a - s1, b);
    p[1] = Offset(a, b);
    final double cmp = b < 0 ? -1.0 : 1.0;
    p[2] = cmp * p2yA > cmp * p2yB ? Offset(p2xA, -p2yA) : Offset(p2xB, p2yB);

    // p3, p4, and p5 are the control points for segment B, which is a mirror
    // of segment A around the y axis.
    p[3] = Offset(-1.0 * p[2].dx, p[2].dy);
    p[4] = Offset(-1.0 * p[2].dx, p[1].dy);
    p[5] = Offset(-1.0 * p[0].dx, p[0].dy);

    // translate all points back to the absolute coordinate system.
    for (int i = 0; i < p.length; i += 1) {
      p[i] += guest.center;
    }

    return Path()
      ..moveTo(host.left, host.top)
      ..lineTo(p[1].dx, p[1].dy)
      ..arcToPoint(p[4], radius: Radius.circular(notchRadius), clockwise: true)
      ..lineTo(host.right, host.top)
      ..lineTo(host.right, host.bottom)
      ..lineTo(host.left, host.bottom)
      ..close();
  }
}
