import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/receipt_bloc.dart';
import '../bloc/receipt_event.dart';
import '../bloc/receipt_state.dart';
import '../widgets/receipt_card.dart';

class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReceiptBloc()..add(LoadReceipt()),
      child: const ReceiptView(),
    );
  }
}

class ReceiptView extends StatelessWidget {
  const ReceiptView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: 25.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'E-Receipt',
          style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
        ),
        centerTitle: false,
      ),
      body: BlocBuilder<ReceiptBloc, ReceiptState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 10.h,
                  ),
                  child: ReceiptCard(
                    healerName: state.healerName,
                    healerRole: state.healerRole,
                    healerImage: state.healerImage,
                    startTime: state.startTime,
                    endTime: state.endTime,
                    duration: state.duration,
                    date: state.date,
                    mode: state.mode,
                    healingType: state.healingType,
                    sessionType: state.sessionType,
                    totalAmount: state.totalAmount,
                    receiptId: state.receiptId,
                  ),
                ),
              ),
              _buildBottomButtons(context),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download_outlined,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Download',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () => context.push(
    '/success',
    extra: {
    'imagePath': 'assets/image/paid.png',
    'icon': 'assets/images/right.png',
    'title': "Thank You!",
      'buttonText': "Got it!",

      'subtitle': "Your session payment has been\ncompleted successfully. We look\nforward to serving you.",
    'onButtonPressed': () => context.push('/appointment-reminder')
                ,
    },),
              child: Container(
                height: 54.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Center(
                  child: Text(
                    'Continue',
                    style: AppTextStyles.button.copyWith(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
