import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ReceiptCard extends StatelessWidget {
  final String healerName;
  final String healerRole;
  final String healerImage;
  final String startTime;
  final String endTime;
  final String duration;
  final String date;
  final String mode;
  final String healingType;
  final String sessionType;
  final double totalAmount;
  final String receiptId;

  const ReceiptCard({
    super.key,
    required this.healerName,
    required this.healerRole,
    required this.healerImage,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.date,
    required this.mode,
    required this.healingType,
    required this.sessionType,
    required this.totalAmount,
    required this.receiptId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHealerInfo(),
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          _buildSessionDetails(),
          _buildTicketDashedDivider(),
          _buildTotalAndQR(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildHealerInfo() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w,vertical: 10.h),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: CommonImage(
              path: healerImage,
              width: 42.w,
              height: 42.w,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(width: 14.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                healerName,
                style: AppTextStyles.bodyLarge
              ),
              Text(
                healerRole,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w,vertical: 5.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTimeColumn('Start time', startTime),
              _buildProgressLine(),
              _buildTimeColumn(
                'End Time',
                endTime,
                crossAxisAlignment: CrossAxisAlignment.end,
              ),
            ],
          ),
          Divider(color: Color(0XFFF0F0F0),)     ,
          _buildDetailRow('Date', date),
Divider(color: Color(0XFFF0F0F0),)     ,     _buildTwoDetailRows('Mode', mode, 'Total Duration', duration),
          SizedBox(height: 16.h),
          _buildTwoDetailRows(
            'Healing type',
            healingType,
            'Session type',
            sessionType,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    String time, {
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xff6E6E6E),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          time,
          style: AppTextStyles.h2.copyWith(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            // color: const Color(0xff0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          children: [
            Row(
              children: [
                _buildDot(),
                Expanded(
                  child: Container(
                    height: 1,
                    color: const Color(0xFFF0F0F0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            (constraints.constrainWidth() / 5).floor(),
                            (index) => SizedBox(
                              width: 3.w,
                              height: 1,
                              child: const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xff9E9E9E),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                _buildDot(),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              duration,
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 10.w,
      height: 10.w,
      padding: 
      EdgeInsets.all(0.5),
      decoration: BoxDecoration(
        color:  Colors.black,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.black, width: 2),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: const Color(0xff9040225),
            fontSize: 14.sp,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xff484848),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTwoDetailRows(String l1, String v1, String l2, String v2) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l1,
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xff6E6E6E),
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              v1,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xff040226),
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l2,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xff6E6E6E),
                fontSize: 12.sp,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              v2,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xff040226),
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketDashedDivider() {
    return SizedBox(
      height: 16.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Row(
            children: List.generate(
              30,
              (index) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  child: Container(
                    height: 1,
                    color: index % 2 == 0
                        ? const Color(0xFFD4D4D4)
                        : Colors.transparent,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: -10.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB), // Background color to match Scaffold
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: -10.w,
            child: Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: Color(0xFFF5F7FB), // Background color to match Scaffold
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAndQR() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 5.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontSize: 18.sp,
                  color: Color(0xff040226)
                ),
              ),
              Text(
                '₹$totalAmount',
                style: AppTextStyles.h3.copyWith(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xff098A4A),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            'E-Receipt',
            style: AppTextStyles.bodyMedium
          ),
          Text(
            'Scan to Downlaod', // Keep the typo "Downlaod" from design if user wants "same to same"
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xff828282),
            ),
          ),
          SizedBox(height: 4.h),
          // QR Code Placeholder
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFF0F0F0)),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: CommonImage(path: 'assets/image/image 436.png',height: 160.h,width: 169.w,fit: BoxFit.cover,),
          ),
          SizedBox(height: 10.h),
          Text(
            receiptId,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xff8F8F8F),
            ),
          ),
        ],
      ),
    );
  }
}
