import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class ChatComposer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool enabled;
  final bool isEditing;
  final String hintText;
  final VoidCallback onSend;
  final VoidCallback? onCancelEdit;
  final ValueChanged<String>? onChanged;

  const ChatComposer({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSend,
    this.focusNode,
    this.isEditing = false,
    this.onCancelEdit,
    this.onChanged,
    this.hintText = 'Write a message',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isEditing) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              color: AppColors.primaryLite,
              child: Row(
                children: [
                  Icon(Icons.edit_outlined, size: 16.sp, color: AppColors.primary),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Editing message',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: onCancelEdit,
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    focusNode: focusNode,
                    enabled: enabled,
                    onChanged: enabled ? onChanged : null,
                    decoration: InputDecoration(
                      hintText: enabled
                          ? (isEditing ? 'Edit your message…' : hintText)
                          : 'Chat is read-only',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textHint,
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: enabled ? (_) => onSend() : null,
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: enabled ? onSend : null,
                  child: Opacity(
                    opacity: enabled ? 1 : 0.4,
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(13.r),
                      ),
                      child: CommonImage(
                        path: 'assets/image/solar_map-arrow-right-bold.png',
                        height: 25.w,
                        width: 25.w,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
