import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../common/widgets/common_button.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import 'bloc/certificates_bloc.dart';
import 'bloc/certificates_event.dart';
import 'bloc/certificates_state.dart';
import 'models/certificate_model.dart';

class CertificateSelectionScreen extends StatelessWidget {
  const CertificateSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CertificatesBloc()..add(LoadCertificates()),
      child: const CertificateSelectionView(),
    );
  }
}

class CertificateSelectionView extends StatelessWidget {
  const CertificateSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchHeader(context),
            Expanded(
              child: BlocBuilder<CertificatesBloc, CertificatesState>(
                builder: (context, state) {
                  if (state is CertificatesLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is CertificatesLoaded) {
                    return _buildContent(context, state);
                  } else if (state is CertificatesError) {
                    return Center(child: Text(state.message));
                  }
                  return const SizedBox();
                },
              ),
            ),
            _buildBottomBar(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Container(
        height: 56.h,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            ),
            Expanded(
              child: TextField(
                onChanged: (value) {
                  context.read<CertificatesBloc>().add(
                    SearchCertificates(value),
                  );
                },
                decoration: InputDecoration(
                  hintText: "Search Certificates",
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textHint,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, CertificatesLoaded state) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        if (state.selectedCertificates.isNotEmpty) ...[
          _buildSectionTitle("Selected Certificates"),
          ...state.selectedCertificates.map(
            (cert) => _CertificateListItem(
              certificate: cert,
              isSelected: true,
              onAction: () => context.read<CertificatesBloc>().add(
                ToggleCertificateSelection(cert),
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
        _buildSectionTitle(
          state.searchQuery.isEmpty ? "Popular Certificates" : "Search Results",
        ),
        ...state.filteredCertificates.map(
          (cert) => _CertificateListItem(
            certificate: cert,
            isSelected: false,
            onAction: () => context.read<CertificatesBloc>().add(
              ToggleCertificateSelection(cert),
            ),
          ),
        ),
        SizedBox(height: 24.h),
        _buildUploadSection(context, state),
        SizedBox(height: 100.h), // Spacing for fab/bottom bar
      ],
    );
  }

  Widget _buildUploadSection(BuildContext context, CertificatesLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle("Others"),
        if (state.pickedFileName != null)
          _buildPickedFileItem(
            context,
            state.pickedFileName!,
            state.pickedFileSize!,
          )
        else
          GestureDetector(
            onTap: () =>
                context.read<CertificatesBloc>().add(PickCertificateFile()),
            child: CustomPaint(
              painter: _DashedRectPainter(
                color: AppColors.border,
                radius: 12.r,
              ),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                width: double.infinity,
                child: Column(
                  children: [
                    const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Upload your own certificate",
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      "PDF, PNG, JPG (max. 5MB)",
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPickedFileItem(BuildContext context, String name, String size) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.indicatorInactive.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, color: AppColors.black),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  size,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () =>
                context.read<CertificatesBloc>().add(RemovePickedFile()),
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: CommonButton(
        text: "Confirm",
        onPressed: () {
          context.push('/documentation');
        },
        borderRadius: 12.r,
      ),
    );
  }
}

class _CertificateListItem extends StatelessWidget {
  final CertificateModel certificate;
  final bool isSelected;
  final VoidCallback onAction;

  const _CertificateListItem({
    required this.certificate,
    required this.isSelected,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.indicatorInactive.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.black,
              size: 20,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  certificate.title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  certificate.provider,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onAction,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(
                isSelected ? Icons.remove : Icons.add,
                size: 18.sp,
                color: AppColors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedRectPainter({required this.color, this.radius = 0});

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
