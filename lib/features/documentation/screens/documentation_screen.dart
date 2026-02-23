import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../common/widgets/common_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../bloc/documentation_bloc.dart';
import '../bloc/documentation_event.dart';
import '../bloc/documentation_state.dart';

class DocumentationScreen extends StatelessWidget {
  const DocumentationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentationBloc(),
      child: const DocumentationView(),
    );
  }
}

class DocumentationView extends StatelessWidget {
  const DocumentationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          "Documentation",
          style: AppTextStyles.titleMedium
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      body: BlocBuilder<DocumentationBloc, DocumentationState>(
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Specialization offered",
                        style: AppTextStyles.bodyLarge
                      ),
                      SizedBox(height: 18.h),
                      _buildMainCard(context, state),
                      SizedBox(height: 32.h),
                      _buildPolicyText(context),
                    ],
                  ),
                ),
              ),
              _buildBottomBar(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, DocumentationState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal:12.w,vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader("Government ID Proof"),
                SizedBox(height: 12.h),
                state.govIdFileName == null
                    ? _buildUploadBox(
                        () => context.read<DocumentationBloc>().add(
                          const PickFileEvent('govId'),
                        ),
                      )
                    : _buildFileItem(context, state.govIdFileName!, 'govId'),
                SizedBox(height: 24.h),
                _buildSectionHeader("Address Proof"),
                SizedBox(height: 12.h),
                state.addressProofFileName == null
                    ? _buildUploadBox(
                        () => context.read<DocumentationBloc>().add(
                          const PickFileEvent('address'),
                        ),
                      )
                    : _buildFileItem(
                        context,
                        state.addressProofFileName!,
                        'address',
                      ),
              ],
            ),
          ),
          const Divider(height: 1,color: AppColors.divider,),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: _buildCheckboxSection(context, state),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildUploadBox(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: DashedRectPainter(
          color: AppColors.border,
          strokeWidth: 1.1,
          gap: 5,
          radius: 12.r,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          width: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CommonImage(
                path: "assets/images/upload.png",
                width: 24.w,
                color: AppColors.black,
              ),
              SizedBox(height: 4.h),
              Text(
                "Click to upload",
                style: AppTextStyles.bodyLarge
              ),
              Text(
                "PDF,PNG,JPG(max.5MB)",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 8.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, String fileName, String section) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surface1,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          CommonImage(path: "assets/images/pdf.png", width: 36.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,

                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "0 KB of 120 KB  •  ",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Icon(Icons.check_circle, color: Colors.green, size: 10.sp),
                    Text(
                      " Completed",
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<DocumentationBloc>().add(DeleteFileEvent(section)),
            icon: CommonImage(path: "assets/images/delete.png", width: 22.w),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxSection(BuildContext context, DocumentationState state) {
    return InkWell(
      onTap: () =>
          context.read<DocumentationBloc>().add(ToggleSelfDeclaration()),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            decoration: BoxDecoration(
              color: state.selfDeclaration ? AppColors.black : AppColors.white,
              borderRadius: BorderRadius.circular(6.r),
              border: Border.all(
                color: state.selfDeclaration
                    ? AppColors.black
                    : AppColors.border,
                width: 2,
              ),
            ),
            child: state.selfDeclaration
                ? Icon(Icons.check, color: AppColors.white, size: 16.sp)
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Self-declaration",
                  style: AppTextStyles.bodyLarge
                ),
                Text(
                  "I confirm all details are genuine and ethical.",
                  style: AppTextStyles.bodyMedium.copyWith(
fontWeight: FontWeight.w400                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyText(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
         fontWeight: FontWeight.w500
        ),
        children: [
          const TextSpan(
            text: "By selecting Agree and continue, I agree to Pranaa Heal’s ",
          ),
          TextSpan(
            text: "Terms of Service",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: ", "),
          TextSpan(
            text: "Payment Terms of Service",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: " and "),
          TextSpan(
            text: "Notification Policy",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: " and acknowledge the "),
          TextSpan(
            text: "Privacy Policy",
            style: const TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
            recognizer: TapGestureRecognizer()..onTap = () {},
          ),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, DocumentationState state) {
    final isReady =
        state.govIdFileName != null &&
        state.addressProofFileName != null &&
        state.selfDeclaration;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isDisabled: !isReady,
        onPressed: () => context.push('/agreement'),
        borderRadius: 12.r,
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;
  final double radius;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
    this.radius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius)),
    );

    final dashPath = Path();
    double distance = 0.0;
    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(DashedRectPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gap != gap ||
        oldDelegate.radius != radius;
  }
}
