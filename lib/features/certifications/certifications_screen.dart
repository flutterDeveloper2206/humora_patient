import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../common/widgets/common_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'bloc/certifications_bloc.dart';
import 'bloc/certifications_event.dart';
import 'bloc/certifications_state.dart';

class CertificationsScreen extends StatelessWidget {
  const CertificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CertificationsBloc(),
      child: const CertificationsView(),
    );
  }
}

class CertificationsView extends StatelessWidget {
  const CertificationsView({super.key});

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
            size: 25,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text("Documentation", style: AppTextStyles.titleMedium),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      body: BlocConsumer<CertificationsBloc, CertificationsState>(
        listener: (context, state) {
          if (state.status == CertificationsStatus.success) {


            context.push(
                '/success',
                extra: {
                  'imagePath': 'assets/images/cert.png',
                  'icon': 'assets/images/right.png',
                  'title': "Certificates added!",
                  'subtitle': "your request has been send to our team\nfor review. you will be notified\nonce its approved",
                  'onButtonPressed': () =>
                      context.go('/live-counselling'),
                },);
          } else if (state.status == CertificationsStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? "An error occurred"),
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Certifications offered",
                        style: AppTextStyles.bodyLarge
                      ),
                      SizedBox(height: 10.h),
                      _buildMainCard(context, state),
                      SizedBox(height: 32.h),
                      _buildFooterText(),
                    ],
                  ),
                ),
              ),
              _buildBottomButton(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMainCard(BuildContext context, CertificationsState state) {
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
      padding: EdgeInsets.symmetric(vertical:  10.h,horizontal: 10.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Certificates"),
          SizedBox(height: 12.h),
          _buildUploadBox(
            () => context.read<CertificationsBloc>().add(PickCertFile()),
          ),
          SizedBox(height: 24.h),
          _buildSectionHeader("Sample Prediction"),
          SizedBox(height: 12.h),
          if (state.isFileUploaded)
            _buildFileItem(context, state.fileName!, state.fileSize!)
          else
            Text(
              "No document uploaded yet.",
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 24.h),
          const Divider(height: 1, color: AppColors.divider),
          SizedBox(height: 24.h),
          _buildScanDocumentSection(),
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
        painter: DashedRectPainter(color: AppColors.border, radius: 12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 10.h),
          width: double.infinity,
          child: Column(
            children: [
              CommonImage(
                path: "assets/images/upload.png",
                width: 20.w,
                color: AppColors.black,
              ),
              SizedBox(height: 8.h),
              Text(
                "Click to upload",
                style: AppTextStyles.bodyLarge
              ),
              Text(
                "PDF,PNG,JPG(max.5MB)",
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFileItem(BuildContext context, String name, String size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surface1.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CommonImage(path: "assets/images/pdf.png", width: 32.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      "0 KB of $size  •  ",
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
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<CertificationsBloc>().add(RemoveCertFile()),
            icon: CommonImage(path: "assets/images/delete.png", width: 20.w),
          ),
        ],
      ),
    );
  }

  Widget _buildScanDocumentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Scan your document",
          style: AppTextStyles.bodyLarge,
        ),
        SizedBox(height: 4.h),
        Text(
          "Upload a readable and valid official certificates.",
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterText() {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.black,
          fontSize: 11.sp,
        ),
        children: [
          const TextSpan(
            text: "By selecting Confirm, I agree to Pranaa Heal’s ",
          ),
          _linkSpan("Terms of Service", () {}),
          const TextSpan(text: ", "),
          _linkSpan("Payment Terms of Service", () {}),
          const TextSpan(text: " and "),
          _linkSpan("Notification Policy", () {}),
          const TextSpan(text: " and acknowledge the "),
          _linkSpan("Privacy Policy", () {}),
          const TextSpan(text: "."),
        ],
      ),
    );
  }

  TextSpan _linkSpan(String text, VoidCallback onTap) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.blue,
        decoration: TextDecoration.underline,
        fontWeight: FontWeight.w500,
      ),
      recognizer: TapGestureRecognizer()..onTap = onTap,
    );
  }

  Widget _buildBottomButton(BuildContext context, CertificationsState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.divider.withOpacity(0.5)),
        ),
      ),
      child: CommonButton(
        text: "Confirm",
        isLoading: state.status == CertificationsStatus.loading,
        isDisabled: !state.isFileUploaded,
        onPressed: () {
          context.read<CertificationsBloc>().add(SubmitCertifications());
        },
        borderRadius: 12.r,
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  DashedRectPainter({required this.color, this.radius = 0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.addRRect(
      RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(radius)),
    );

    final dashPath = Path();
    double distance = 0.0;
    const double dashWidth = 5.0;
    const double dashSpace = 5.0;

    for (final pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
      distance = 0.0;
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
