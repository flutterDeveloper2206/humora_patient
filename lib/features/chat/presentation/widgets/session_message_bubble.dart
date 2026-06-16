import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';
import '../../data/models/chat_reaction_model.dart';

class SessionMessageBubble extends StatelessWidget {
  final ChatMessageDto message;
  final bool isMe;
  final String? avatarUrl;
  final String? currentUserId;
  final bool highlighted;
  final bool canEdit;
  final bool canReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onToggleReaction;

  const SessionMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.avatarUrl,
    this.currentUserId,
    this.highlighted = false,
    this.canEdit = false,
    this.canReact = false,
    this.onEdit,
    this.onDelete,
    this.onToggleReaction,
  });

  static const _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  bool get _canShowMenu =>
      (canEdit || canReact) && !message.isPending && !message.isDeleted;

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Center(
          child: Text(
            '[Message deleted]',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final avatar = avatarUrl ?? 'assets/image/doctorprofile.png';
    final timeLabel = message.createdAt != null
        ? DateFormat('h:mm a').format(message.createdAt!.toLocal()).toLowerCase()
        : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onLongPress: _canShowMenu ? () => _showActionsSheet(context) : null,
        child: Row(
          mainAxisAlignment:
              isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) _Avatar(path: avatar),
            if (!isMe) SizedBox(width: 8.w),
            if (isMe && _canShowMenu) _buildMenuButton(context),
            if (isMe && _canShowMenu) SizedBox(width: 4.w),
            Flexible(child: _buildBubble(timeLabel)),
            if (!isMe && _canShowMenu) SizedBox(width: 4.w),
            if (!isMe && _canShowMenu) _buildMenuButton(context),
            if (isMe) ...[
              SizedBox(width: 8.w),
              _Avatar(path: 'assets/image/shortphoto.png'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String timeLabel) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLiteChip : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: isMe ? Radius.circular(20.r) : Radius.zero,
          bottomRight: isMe ? Radius.zero : Radius.circular(20.r),
        ),
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
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
          Text(
            message.content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: const Color(0xff181818),
              fontWeight: FontWeight.w400,
              fontSize: 13.sp,
            ),
          ),
          if (message.isEdited)
            Text(
              'edited',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontSize: 9.sp,
              ),
            ),
          if (message.reactions.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: message.reactions.map(_reactionChip).toList(),
            ),
          ],
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timeLabel.isNotEmpty)
                Text(
                  timeLabel,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10.sp,
                    color: const Color(0xff9E9E9E),
                  ),
                ),
              if (message.isPending) ...[
                SizedBox(width: 6.w),
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ] else if (isMe) ...[
                SizedBox(width: 4.w),
                Icon(
                  message.isReadByOther
                      ? Icons.done_all
                      : (message.isDelivered ? Icons.done_all : Icons.done),
                  size: 14.sp,
                  color: message.isReadByOther
                      ? const Color(0xFF4CAF50)
                      : const Color(0xff9E9E9E),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showActionsSheet(context),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(
            Icons.more_horiz,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _reactionChip(ChatReactionDto reaction) {
    final userId = currentUserId ?? '';
    final mine = reaction.hasUser(userId);
    final count = reaction.userIds.length;

    return GestureDetector(
      onTap: onToggleReaction != null
          ? () => onToggleReaction!(reaction.emoji)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryLiteChip : AppColors.primaryLite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: mine ? AppColors.primary : AppColors.primaryLiteChip,
            width: mine ? 1.2 : 1,
          ),
        ),
        child: Text(
          count > 1 ? '${reaction.emoji} $count' : reaction.emoji,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12.sp,
            fontWeight: mine ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                if (canReact) ...[
                  Text(
                    'Add reaction',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: _quickEmojis
                        .map(
                          (emoji) => GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              onToggleReaction?.call(emoji);
                            },
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLite,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: 24.sp),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (canEdit && onEdit != null) ...[
                  SizedBox(height: 12.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.edit_outlined, color: AppColors.textPrimary),
                    title: const Text('Edit message'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit!();
                    },
                  ),
                ],
                if (canEdit && onDelete != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      'Delete message',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete?.call();
  }
}

class _Avatar extends StatelessWidget {
  final String path;

  const _Avatar({required this.path});

  @override
  Widget build(BuildContext context) {
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
        child: CommonImage(path: path, fit: BoxFit.cover),
      ),
    );
  }
}
