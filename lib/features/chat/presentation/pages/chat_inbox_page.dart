import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';
import '../bloc/chat_inbox_bloc.dart';
import '../bloc/chat_inbox_event.dart';
import '../bloc/chat_inbox_state.dart';
import '../models/chat_session_args.dart';
import '../utils/chat_inbox_loading.dart';

class ChatInboxScreen extends StatelessWidget {
  const ChatInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatInboxBloc()..add(const LoadChatInbox()),
      child: const ChatInboxPage(embedded: false),
    );
  }
}

class ChatInboxPage extends StatelessWidget {
  final bool embedded;

  const ChatInboxPage({super.key, this.embedded = true});

  double get _bottomPadding => embedded ? 120 : 32;

  @override
  Widget build(BuildContext context) {
    final content = BlocConsumer<ChatInboxBloc, ChatInboxState>(
      listenWhen: (prev, curr) {
        if (curr is! ChatInboxError) return false;
        if (prev is ChatInboxLoaded && prev.isRefreshing) return false;
        return true;
      },
      listener: (context, state) {
        if (state is ChatInboxError) {
          CommonFlushbar.error(context, state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state.isBusy;

        if (state is ChatInboxError && !isLoading) {
          return _InboxErrorBody(
            message: state.message,
            bottomPadding: _bottomPadding,
            onRetry: () =>
                context.read<ChatInboxBloc>().add(const LoadChatInbox()),
          );
        }

        final conversations = state is ChatInboxLoaded
            ? state.conversations
            : _placeholderConversations();

        final showEmpty =
            state is ChatInboxLoaded && state.isEmpty && !isLoading;

        return AutoSkeleton(
          enabled: isLoading,
          child: showEmpty
              ? const _ChatInboxEmptyState()
              : _InboxList(
                  conversations: conversations,
                  bottomPadding: _bottomPadding,
                  interactionsEnabled: !isLoading,
                ),
        );
      },
    );

    if (!embedded) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: _buildAppBar(showBack: true),
        body: content,
      );
    }

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildAppBar(showBack: false),
          Expanded(child: content),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar({required bool showBack}) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? Builder(
              builder: (context) => IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  color: AppColors.textPrimary,
                  size: 28.sp,
                ),
                onPressed: () => safePop(context),
              ),
            )
          : null,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chat',
            style: AppTextStyles.h3.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Your conversations',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 11.sp,
            ),
          ),
        ],
      ),
    );
  }

  List<ChatInboxEntryDto> _placeholderConversations() {
    return List.generate(
      4,
      (i) => ChatInboxEntryDto(
        otherPartyUserId: 'placeholder-$i',
        otherPartyName: 'Healer name',
        lastMessage: 'Last message preview…',
        bookingCount: i == 0 ? 3 : 1,
      ),
    );
  }
}

class _InboxList extends StatelessWidget {
  final List<ChatInboxEntryDto> conversations;
  final double bottomPadding;
  final bool interactionsEnabled;

  const _InboxList({
    required this.conversations,
    required this.bottomPadding,
    required this.interactionsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: interactionsEnabled
          ? () async {
              final bloc = context.read<ChatInboxBloc>();
              bloc.add(const RefreshChatInbox());
              await bloc.stream.firstWhere(
                (s) =>
                    (s is ChatInboxLoaded && !s.isRefreshing) ||
                    s is ChatInboxError,
              );
            }
          : () async {},
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomPadding.h),
        itemCount: conversations.length,
        separatorBuilder: (_, __) => SizedBox(height: 10.h),
        itemBuilder: (context, index) {
          final item = conversations[index];
          return _ConversationTile(
            item: item,
            onTap: interactionsEnabled
                ? () {
                    context.push(
                      '/chat/with/${item.otherPartyUserId}',
                      extra: ChatSessionArgs(
                        otherPartyUserId: item.otherPartyUserId,
                        healerName: item.otherPartyName,
                        otherUserProfile: item.otherPartyPhoto,
                        bookingCount: item.bookingCount,
                      ),
                    );
                  }
                : null,
          );
        },
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatInboxEntryDto item;
  final VoidCallback? onTap;

  const _ConversationTile({required this.item, this.onTap});

  String get _timeLabel {
    final at = item.lastMessageAt;
    if (at == null) return '';
    final local = at.toLocal();
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return DateFormat('h:mm a').format(local).toLowerCase();
    }
    return DateFormat('d MMM').format(local);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: CommonImage(
                  path:
                      item.otherPartyPhoto ?? 'assets/image/doctorprofile.png',
                  width: 48.w,
                  height: 48.w,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.otherPartyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                            ),
                          ),
                        ),
                        if (_timeLabel.isNotEmpty)
                          Text(
                            _timeLabel,
                            style: AppTextStyles.label.copyWith(
                              color: AppColors.textHint,
                              fontSize: 11.sp,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    if (item.bookingCount > 1) ...[
                      Text(
                        '${item.bookingCount} sessions',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4.h),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.lastMessage ?? 'No messages yet',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                        ),
                        if (item.totalUnreadCount > 0) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 7.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              '${item.totalUnreadCount}',
                              style: AppTextStyles.label.copyWith(
                                color: Colors.white,
                                fontSize: 10.sp,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatInboxEmptyState extends StatelessWidget {
  const _ChatInboxEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, 120.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 72.sp,
              color: AppColors.textHint,
            ),
            SizedBox(height: 20.h),
            Text(
              'No conversations yet',
              style: AppTextStyles.h3.copyWith(
                fontSize: 18.sp,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Book a session with a healer to start chatting.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InboxErrorBody extends StatelessWidget {
  final String message;
  final double bottomPadding;
  final VoidCallback onRetry;

  const _InboxErrorBody({
    required this.message,
    required this.bottomPadding,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.fromLTRB(32.w, 0, 32.w, bottomPadding.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: AppTextStyles.button.copyWith(color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
