import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/chat_state.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final String senderAvatar;
  final String receiverAvatar;

  const ChatBubble({
    super.key,
    required this.message,
    required this.senderAvatar,
    required this.receiverAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Row(
        mainAxisAlignment: message.isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!message.isMe) _buildAvatar(isMe: false),
          SizedBox(width: 2.w),
          Flexible(
            child: Container(
              padding: EdgeInsets.fromLTRB(12.w, 10.h, 9.w, 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.r),
                  topRight: Radius.circular(20.r),
                  bottomLeft: message.isMe
                      ? Radius.circular(20.r)
                      : Radius.zero,
                  bottomRight: message.isMe
                      ? Radius.zero
                      : Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.imageUrl != null)
                    Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: CommonImage(
                        path: message.imageUrl!,
                        width: 200.w,
                        borderRadius: 12.r,
                        fit: BoxFit.cover,
                      ),
                    )
                  else
                    Text(
                      message.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: const Color(0xff181818),
                        fontWeight: FontWeight.w400,
                        fontSize: 13.sp,
                      ),
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!message.isMe) ...[
                        _buildStatusIcon(),
                        SizedBox(width: 4.w),
                      ],
                      Text(
                        DateFormat(
                          'h:mm a',
                        ).format(message.timestamp).toLowerCase(),
                        style: AppTextStyles.label.copyWith(
                          fontSize: 10.sp,
                          color: const Color(0xff9E9E9E),
                        ),
                      ),
                      if (message.isMe) ...[
                        SizedBox(width: 4.w),
                        _buildStatusIcon(),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          if (message.isMe) _buildAvatar(isMe: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({required bool isMe}) {
    final avatarPath = isMe ? senderAvatar : receiverAvatar;
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: CommonImage(path: avatarPath, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildStatusIcon() {
    return Icon(Icons.done_all, size: 14.sp, color: const Color(0xff9E9E9E));
  }
}
