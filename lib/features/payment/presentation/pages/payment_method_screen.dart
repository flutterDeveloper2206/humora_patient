import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../common/widgets/swipeable_button.dart';
import '../../bloc/payment_bloc.dart';
import '../../bloc/payment_event.dart';
import '../../bloc/payment_state.dart';
import '../widgets/payment_method_tile.dart';
import '../widgets/wallet_widget.dart';

class PaymentMethodScreen extends StatelessWidget {
  const PaymentMethodScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PaymentMethodBloc(),
      child: const PaymentMethodView(),
    );
  }
}

class PaymentMethodView extends StatelessWidget {
  const PaymentMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: 24.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Payment Method',
          style: AppTextStyles.titleMedium
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<PaymentMethodBloc, PaymentMethodState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        'Credit Cards',
                        style: AppTextStyles.h2.copyWith(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      WalletWidget(balance: state.walletBalance),
                      SizedBox(height: 20.h),
                      // Add Credit Card Button with Dashed Border
                      GestureDetector(
                        onTap: () {},
                        child: CustomPaint(
                          painter: DashedBorderPainter(
                            color: const Color(0xFFC0C0C0),
                            borderRadius: 30.r,
                          ),
                          child: Container(
                            width: double.infinity,
                            height: 54.h,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: Colors.black,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Credit Card',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 18.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10.h),
                      // Divider
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: const Color(0xFFCECECE)),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: Text(
                              'Or Continue With',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF717171),
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: const Color(0xFFCECECE)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      // Payment Methods
                      PaymentMethodTile(
                        title: 'Google Pay',
                        icon: Image.asset(
                          'assets/images/google.png',
                          width: 24.w,
                        ),
                        isSelected: state.selectedType == PaymentType.googlePay,
                        onTap: () => context.read<PaymentMethodBloc>().add(
                          const SelectPaymentMethod(PaymentType.googlePay),
                        ),
                      ),
                      PaymentMethodTile(
                        title: 'Apple Pay',
                        icon: Image.asset(
                          'assets/images/apple.png',
                          width: 24.w,
                        ),
                        isSelected: state.selectedType == PaymentType.applePay,
                        onTap: () => context.read<PaymentMethodBloc>().add(
                          const SelectPaymentMethod(PaymentType.applePay),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Bottom Section
              _buildBottomSection(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomSection(BuildContext context, PaymentMethodState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Discount Code Row
          Row(
            children: [
              CommonImage(
                path: 'assets/image/ticket-discount.png',
                height: 14.w,
                width: 18.w,
              ),
              SizedBox(width: 8.w),
              Text(
                'Discount Code',
                style: AppTextStyles.bodyMedium
              ),
              const Spacer(),
              _buildDiscountChip(state.discountCode),
            ],
          ),
          SizedBox(height: 16.h),
          // Amount Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Amount',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Discount applied',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Color(0xFF6E6E6E),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${state.totalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.h1.copyWith(
                      fontSize: 16.sp,
                      color: const Color(0xFF098A4A),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${state.originalAmount.toStringAsFixed(2)}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xFF6E6E6E),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Continue Button with Swipe
          SizedBox(
            width: double.infinity,
            child: SwipeableButton(
              animationWidth: 275.0.w,
              buttonText: 'Continue',
              backgroundColor: AppColors.primary,
              onSwipeComplete: () => context.push('/receipt'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscountChip(String code) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      // decoration: BoxDecoration(
      //   color: const Color(0xFFFBFBFB),
      //   borderRadius: BorderRadius.circular(20.r),
      //   border: Border.all(color: const Color(0xFFF0F0F0)),
      // ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF00B14F), size: 15.sp),
          SizedBox(width: 6.w),
          Text(
            code,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
              color: const Color(0xFF040226),
            ),
          ),
          SizedBox(width: 3.w),
          Icon(
            Icons.chevron_right,
            color: const Color(0xFF040226),
            size: 18.sp,
          ),
        ],
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double dash;
  final double borderRadius;

  DashedBorderPainter({
    this.color = Colors.black,
    this.strokeWidth = 1.2,
    this.gap = 6,
    this.dash = 8,
    this.borderRadius = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(borderRadius),
        ),
      );

    final dashPath = Path();
    double distance = 0;
    for (final metric in path.computeMetrics()) {
      while (distance < metric.length) {
        dashPath.addPath(
          metric.extractPath(distance, distance + dash),
          Offset.zero,
        );
        distance += dash + gap;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
