import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';

class WalletWidget extends StatelessWidget {
  final double balance;

  const WalletWidget({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 270.h,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Card 1 (HDFC Bank) - Back
          // Positioned(
          //   top: 0.h,
          //   child: _buildCard('assets/image/card1.png', 0.88),
          // ),
          // // Card 2 (ICICI Bank) - Middle
          // Positioned(
          //   top: 25.h,
          //   child: _buildCard('assets/image/card2.png', 0.94),
          // ),
          // // Card 3 (AXIS Bank) - Front
          // Positioned(
          //   top: 50.h,
          //   child: _buildCard('assets/image/card3.png', 1.0),
          // ),
          // Wallet Image
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CommonImage(
              path: 'assets/image/ddfsfasdfds 1.png',
              fit: BoxFit.contain,
              height: 280.h,
              width: double.infinity,
            ),
          ),
          // Wallet Balance Text on the Wallet
          // Positioned(
          //   bottom: 45.h,
          //   left: 50.w,
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     mainAxisSize: MainAxisSize.min,
          //     children: [
          //       Text(
          //         'Wallet Balance',
          //         style: AppTextStyles.bodySmall.copyWith(
          //           color: Colors.white.withOpacity(0.5),
          //           fontSize: 12.sp,
          //         ),
          //       ),
          //       SizedBox(height: 4.h),
          //       RichText(
          //         text: TextSpan(
          //           style: AppTextStyles.h2.copyWith(
          //             color: Colors.white,
          //             fontSize: 28.sp,
          //             fontWeight: FontWeight.w600,
          //           ),
          //           children: [
          //             TextSpan(
          //               text: '₹${balance.toStringAsFixed(2).split('.')[0]}',
          //             ),
          //             TextSpan(
          //               text: '.${balance.toStringAsFixed(2).split('.')[1]}',
          //               style: TextStyle(color: Colors.white.withOpacity(0.5)),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildCard(String path, double scale) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 300.w,
        height: 140.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: CommonImage(path: path, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
