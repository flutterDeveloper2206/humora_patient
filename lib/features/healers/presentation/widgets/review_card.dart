import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../../common/widgets/common_image.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';

class ReviewCard extends StatefulWidget {
  final HealerReview review;

  const ReviewCard({super.key, required this.review});

  @override
  State<ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<ReviewCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final commentStyle = AppTextStyles.bodyMedium.copyWith(
      color: AppColors.textPrimary,
      fontWeight: FontWeight.w400,
    );

    return Container(
      width: 270.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final textSpan = TextSpan(
            text: widget.review.comment,
            style: commentStyle,
          );
          final textPainter = TextPainter(
            text: textSpan,
            maxLines: 4,
            textDirection: ui.TextDirection.ltr,
          );
          textPainter.layout(maxWidth: constraints.maxWidth);

          final hasMore = textPainter.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.review.comment,
                maxLines: _isExpanded ? null : 4,
                overflow: _isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                style: commentStyle,
              ),
              if (hasMore) ...[
                SizedBox(height: 12.h),
                GestureDetector(
                  onTap: () => setState(() => _isExpanded = !_isExpanded),
                  child: Row(
                    children: [
                      Text(
                        _isExpanded ? 'Show less' : 'Show more',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.chevron_right,
                        size: 16.sp,
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: CommonImage(
                      path: widget.review.userImageUrl,
                      width: 36.w,
                      height: 36.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.review.userName,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          widget.review.date,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
