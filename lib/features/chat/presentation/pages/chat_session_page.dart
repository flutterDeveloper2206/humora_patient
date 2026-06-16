import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../booking/presentation/widgets/insufficient_wallet_dialog.dart';
import '../../../live_consultation/presentation/utils/live_end_navigator.dart';
import '../../../live_consultation/presentation/bloc/live_request_bloc.dart';
import '../../../live_consultation/presentation/bloc/live_request_event.dart';
import '../../../live_consultation/presentation/bloc/live_request_state.dart';
import '../../../live_consultation/presentation/bloc/live_session_cubit.dart';
import '../../data/models/chat_models.dart';
import '../bloc/chat_session_bloc.dart';
import '../bloc/chat_session_event.dart';
import '../bloc/chat_session_state.dart';
import '../models/chat_session_args.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_waiting_room.dart';
import '../widgets/session_message_bubble.dart';
import '../widgets/system_message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatSessionPage extends StatelessWidget {
  final String bookingId;
  final ChatSessionArgs? args;

  const ChatSessionPage({
    super.key,
    required this.bookingId,
    this.args,
  });

  ChatSessionArgs get _resolvedArgs =>
      args ?? ChatSessionArgs(bookingId: bookingId);

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedArgs.copyWith(bookingId: bookingId);
    final pending = resolved.pendingLiveRequest;

    if (pending != null) {
      return BlocProvider(
        create: (_) => LiveRequestBloc()
          ..add(
            StartRequest(
              healerId: pending.healerId,
              consultationType: 0,
            ),
          ),
        child: ChatSessionView(
          bookingId: bookingId,
          healerName: resolved.healerName,
          isLiveSession: true,
          pendingLiveRequest: pending,
        ),
      );
    }

    final chatTree = BlocProvider(
      create: (_) => ChatSessionBloc(args: resolved)
        ..add(const StartChatSession()),
      child: ChatSessionView(
        bookingId: bookingId,
        healerName: resolved.healerName,
        isLiveSession: resolved.isLiveSession,
      ),
    );

    if (!resolved.isLiveSession) return chatTree;

    return BlocProvider(
      create: (_) => LiveSessionCubit()..startMonitoring(bookingId),
      child: chatTree,
    );
  }
}

class ChatSessionView extends StatefulWidget {
  final String bookingId;
  final String? healerName;
  final bool isLiveSession;
  final PendingLiveChatRequest? pendingLiveRequest;

  const ChatSessionView({
    super.key,
    required this.bookingId,
    this.healerName,
    this.isLiveSession = false,
    this.pendingLiveRequest,
  });

  @override
  State<ChatSessionView> createState() => _ChatSessionViewState();
}

class _ChatSessionViewState extends State<ChatSessionView>
    with WidgetsBindingObserver {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _composerFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _patientId;
  String? _editingMessageId;
  Timer? _liveRequestCountdownTimer;
  int _liveRequestSecondsLeft = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _loadPatientId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.pendingLiveRequest != null) return;
    context.read<ChatSessionBloc>().add(ChatAppLifecycleChanged(state));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 48) {
      context.read<ChatSessionBloc>().add(const LoadOlderChatMessages());
    }
  }

  Future<void> _loadPatientId() async {
    _patientId = await SessionManager.getPatientId();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveRequestCountdownTimer?.cancel();
    _controller.dispose();
    _composerFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  bool _isMe(ChatMessageDto message) {
    if (_patientId != null &&
        _patientId!.isNotEmpty &&
        message.senderId == _patientId) {
      return true;
    }
    return message.senderRole.toLowerCase() == 'patient';
  }

  bool _canInteractWithMessage(
    ChatMessageDto message,
    ChatSessionActive? activeState,
  ) {
    if (activeState?.canCompose != true) return false;
    if (message.isSystem || message.isDeleted || message.isPending) {
      return false;
    }
    if (message.messageId.isEmpty || message.messageId.startsWith('pending-')) {
      return false;
    }
    return true;
  }

  void _startEditingMessage(ChatMessageDto message) {
    setState(() {
      _editingMessageId = message.messageId;
      _controller.text = message.content;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _composerFocusNode.requestFocus();
  }

  void _cancelEditingMessage() {
    if (_editingMessageId == null) return;
    setState(() {
      _editingMessageId = null;
      _controller.clear();
    });
  }

  void _submitComposer(ChatSessionActive? activeState) {
    final text = _controller.text.trim();
    if (text.isEmpty || activeState?.canCompose != true) return;

    if (_editingMessageId != null) {
      context.read<ChatSessionBloc>().add(
            EditChatMessage(
              messageId: _editingMessageId!,
              content: text,
            ),
          );
      _cancelEditingMessage();
      return;
    }

    context.read<ChatSessionBloc>().add(SendChatMessage(text));
    _controller.clear();
  }

  Future<void> _endLiveSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End session?'),
        content: const Text(
          'This will end your live consultation and stop billing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'End',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    context.read<ChatSessionBloc>().add(const EndChatSession());
    await endLiveSessionAndNavigate(
      context: context,
      bookingId: widget.bookingId,
    );
  }

  Widget _liveBanner() {
    return BlocBuilder<LiveSessionCubit, LiveSessionState>(
      builder: (context, liveState) {
        final billing = liveState.lastBillingCycle;
        final message = billing != null
            ? 'Live session · Balance ₹${billing.balanceAfter.toStringAsFixed(0)}'
            : 'Live session in progress';
        return _StatusBanner(
          icon: Icons.circle,
          message: message,
          color: AppColors.primary,
          iconSize: 10,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pendingLiveRequest != null) {
      return _buildPendingLiveRequest(context);
    }

    final chatBody = BlocConsumer<ChatSessionBloc, ChatSessionState>(
      listenWhen: (prev, curr) {
        if (curr is ChatSessionActive &&
            curr.sendError != null &&
            (prev is! ChatSessionActive ||
                prev.sendError != curr.sendError)) {
          return true;
        }
        if (curr is ChatSessionError &&
            (curr.message.contains('cannot access') ||
                curr.message.contains('not found'))) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is ChatSessionActive && state.sendError != null) {
          CommonFlushbar.error(context, state.sendError!);
        }
        if (state is ChatSessionError &&
            (state.message.toLowerCase().contains('cannot') ||
                state.message.toLowerCase().contains('not found'))) {
          CommonFlushbar.error(context, state.message);
          safePop(context);
        }
      },
      builder: (context, state) {
        if (state is ChatSessionAccessLoading) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ChatSessionError) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<ChatSessionBloc>().add(const RetryChatSession()),
            ),
          );
        }

        if (state is ChatSessionWaitingRoom) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: Column(
              children: [
                if (state.messages.isNotEmpty)
                  Expanded(child: _buildMessageList(state.messages)),
                Expanded(
                  child: ChatWaitingRoom(
                    access: state.access,
                    countdown: state.countdown,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ChatSessionCancelled) {
          return _buildSessionScaffold(
            state: state,
            banner: _StatusBanner(
              icon: Icons.cancel_outlined,
              message: state.access.message.isNotEmpty
                  ? state.access.message
                  : 'This booking was cancelled.',
              color: AppColors.error,
            ),
            canCompose: false,
          );
        }

        if (state is ChatSessionHistoryOnly) {
          return _buildSessionScaffold(
            state: state,
            banner: state.showBookAgain
                ? _StatusBanner(
                    icon: Icons.lock_outline,
                    message: state.access.message.isNotEmpty
                        ? state.access.message
                        : 'This chat session has ended.',
                    color: AppColors.textSecondary,
                    actionLabel: 'Book Again',
                    onAction: () => context.go('/home'),
                  )
                : null,
            canCompose: false,
          );
        }

        if (state is ChatSessionActive) {
          return _buildSessionScaffold(
            state: state,
            banner: state.isLiveSession ? _liveBanner() : null,
            canCompose: state.canCompose,
            showEndSession: state.isLiveSession && state.canCompose,
            activeState: state,
          );
        }

        return _buildScaffold(
          title: widget.healerName ?? 'Chat',
          showEndSession: widget.isLiveSession,
          body: const SizedBox.shrink(),
        );
      },
    );

    if (!widget.isLiveSession) return chatBody;

    return MultiBlocListener(
      listeners: [
        BlocListener<LiveSessionCubit, LiveSessionState>(
          listenWhen: (prev, curr) =>
              curr.sessionEnded != null &&
              prev.sessionEnded != curr.sessionEnded,
          listener: (context, state) async {
            final summary = state.sessionEnded;
            if (summary == null || !context.mounted) return;
            await finishLiveSessionFromSummary(
              context: context,
              bookingId: widget.bookingId,
              summary: summary,
            );
            if (!context.mounted) return;
            context.read<ChatSessionBloc>().add(const RefreshChatAccess());
          },
        ),
        BlocListener<LiveSessionCubit, LiveSessionState>(
          listenWhen: (prev, curr) =>
              curr.lowBalanceWarning != null &&
              prev.lowBalanceWarning != curr.lowBalanceWarning,
          listener: (context, state) {
            final warning = state.lowBalanceWarning;
            if (warning == null || !context.mounted) return;
            CommonFlushbar.error(
              context,
              'Low wallet balance. About ${warning.estimatedMinutesLeft} minutes left.',
            );
          },
        ),
      ],
      child: chatBody,
    );
  }

  void _startLiveRequestCountdown(DateTime? expiresAt) {
    _liveRequestCountdownTimer?.cancel();
    if (expiresAt != null) {
      _liveRequestSecondsLeft =
          expiresAt.difference(DateTime.now()).inSeconds.clamp(0, 60);
    } else {
      _liveRequestSecondsLeft = 60;
    }

    _liveRequestCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_liveRequestSecondsLeft > 0) {
          _liveRequestSecondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  ChatMessageDto _liveRequestSystemMessage(String content) {
    return ChatMessageDto(
      messageId: content.hashCode.toString(),
      bookingId: '',
      senderId: 'system',
      senderName: 'System',
      senderRole: 'System',
      content: content,
      messageType: 'System',
      createdAt: DateTime.now(),
    );
  }

  List<ChatMessageDto> _liveRequestMessagesForState(LiveRequestState state) {
    final healerName = widget.healerName ?? 'healer';

    if (state is LiveRequestLoading) {
      return [
        _liveRequestSystemMessage(
          'Sending your live chat request to $healerName…',
        ),
      ];
    }

    if (state is LiveRequestWaiting) {
      final messages = <ChatMessageDto>[
        _liveRequestSystemMessage(
          'Live chat request sent. Waiting for $healerName to accept.',
        ),
      ];
      if (!state.hubConnected) {
        messages.add(
          _liveRequestSystemMessage(
            'Live connection is reconnecting — we will still notify you when the healer responds.',
          ),
        );
      }
      messages.add(
        _liveRequestSystemMessage(
          'Request expires in $_liveRequestSecondsLeft seconds.',
        ),
      );
      return messages;
    }

    if (state is LiveRequestRejected) {
      return [
        _liveRequestSystemMessage(
          state.message.isNotEmpty
              ? state.message
              : '$healerName declined your live chat request.',
        ),
      ];
    }

    if (state is LiveRequestExpired) {
      return [
        _liveRequestSystemMessage(
          'The healer did not respond in time. Please try again.',
        ),
      ];
    }

    if (state is LiveRequestError) {
      return [_liveRequestSystemMessage(state.message)];
    }

    if (state is LiveRequestWalletError) {
      return [
        _liveRequestSystemMessage(
          'Insufficient wallet balance. Add funds and try again.',
        ),
      ];
    }

    return [_liveRequestSystemMessage('Preparing your live chat request…')];
  }

  String _liveRequestComposerHint(LiveRequestState state) {
    if (state is LiveRequestWaiting || state is LiveRequestLoading) {
      return 'Messages unlock when the healer accepts';
    }
    return 'Chat is unavailable';
  }

  bool _liveRequestShowRetry(LiveRequestState state) =>
      state is LiveRequestError ||
      state is LiveRequestExpired ||
      state is LiveRequestRejected;

  Widget _buildPendingLiveRequest(BuildContext context) {
    final pending = widget.pendingLiveRequest!;

    return BlocConsumer<LiveRequestBloc, LiveRequestState>(
      listenWhen: (prev, curr) => curr is! LiveRequestLoading,
      listener: (context, state) {
        if (state is LiveRequestWaiting) {
          _startLiveRequestCountdown(state.expiresAt);
        } else if (state is LiveRequestAccepted) {
          final bookingId = state.payload.bookingId;
          context.pushReplacement(
            '/chat/$bookingId',
            extra: ChatSessionArgs(
              bookingId: bookingId,
              isLiveSession: true,
              healerName: widget.healerName,
            ),
          );
        } else if (state is LiveRequestWalletError) {
          final wallet = state.walletError;
          InsufficientWalletDialog.show(
            context: context,
            message: wallet.message,
            requiredAmount: wallet.requiredBalance,
            availableAmount: wallet.currentBalance,
          );
        } else if (state is LiveRequestExpired && _liveRequestSecondsLeft > 0) {
          setState(() => _liveRequestSecondsLeft = 0);
        }
      },
      builder: (context, state) {
        final messages = _liveRequestMessagesForState(state);
        final isWaiting =
            state is LiveRequestLoading || state is LiveRequestWaiting;
        final hubBanner = state is LiveRequestWaiting && !state.hubConnected;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (isWaiting) {
              context.read<LiveRequestBloc>().add(const CancelRequest());
            }
            safePop(context);
          },
          child: _buildScaffold(
            title: widget.healerName ?? 'Chat',
            isOtherPartyOnline: isWaiting,
            onBack: () {
              if (isWaiting) {
                context.read<LiveRequestBloc>().add(const CancelRequest());
              }
              safePop(context);
            },
            body: Column(
              children: [
                if (hubBanner)
                  _StatusBanner(
                    icon: Icons.wifi_off_outlined,
                    message:
                        'Live socket unavailable — checking status every few seconds.',
                    color: AppColors.textSecondary,
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackground(),
                      ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        itemCount: messages.length + (isWaiting ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isWaiting && index == messages.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 24.h),
                              child: Column(
                                children: [
                                  if (pending.healerImage != null &&
                                      pending.healerImage!.isNotEmpty)
                                    CommonImage(
                                      path: pending.healerImage!,
                                      width: 72.w,
                                      height: 72.w,
                                      fit: BoxFit.cover,
                                      borderRadius: 36.r,
                                    ),
                                  SizedBox(height: 12.h),
                                  SizedBox(
                                    width: 48.w,
                                    height: 48.w,
                                    child: const CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SystemMessageBubble(message: messages[index]);
                        },
                      ),
                    ],
                  ),
                ),
                if (_liveRequestShowRetry(state))
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: CommonButton(
                      text: 'Try again',
                      borderRadius: 12.r,
                      height: 48.h,
                      onPressed: () => context
                          .read<LiveRequestBloc>()
                          .add(const RetryRequest()),
                    ),
                  )
                else if (state is LiveRequestWalletError)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: CommonButton(
                      text: 'Go to Wallet',
                      backgroundColor: AppColors.darkButton,
                      borderRadius: 12.r,
                      height: 48.h,
                      onPressed: () => context.push('/wallet'),
                    ),
                  ),
                ChatComposer(
                  controller: _controller,
                  enabled: false,
                  hintText: _liveRequestComposerHint(state),
                  onSend: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionScaffold({
    required ChatSessionState state,
    required bool canCompose,
    Widget? banner,
    bool showEndSession = false,
    ChatSessionActive? activeState,
  }) {
    final messages = switch (state) {
      ChatSessionActive s => s.messages,
      ChatSessionHistoryOnly s => s.messages,
      ChatSessionCancelled s => s.messages,
      _ => const <ChatMessageDto>[],
    };

    final healerName = switch (state) {
      ChatSessionActive s => s.healerName,
      ChatSessionHistoryOnly s => s.healerName,
      ChatSessionCancelled s => s.healerName,
      _ => widget.healerName,
    };

    return _buildScaffold(
      title: healerName ?? widget.healerName ?? 'Chat',
      showEndSession: showEndSession,
      isOtherPartyOnline: activeState?.isOtherPartyOnline ?? false,
      showSearch: activeState != null || state is ChatSessionHistoryOnly,
      body: Column(
        children: [
          if (banner != null) banner,
          if (activeState?.isLoadingOlder == true)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                _buildBackground(),
                Positioned.fill(
                  child: BlocListener<ChatSessionBloc, ChatSessionState>(
                    listenWhen: (_, curr) =>
                        curr is ChatSessionActive ||
                        curr is ChatSessionHistoryOnly,
                    listener: (_, __) => _scrollToBottom(),
                    child: _buildMessageList(
                      messages,
                      activeState: activeState,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (activeState?.typingUserName != null)
            TypingIndicator(userName: activeState!.typingUserName!),
          ChatComposer(
            controller: _controller,
            focusNode: _composerFocusNode,
            enabled: canCompose,
            isEditing: _editingMessageId != null,
            onCancelEdit: _cancelEditingMessage,
            onChanged: canCompose
                ? (_) =>
                    context.read<ChatSessionBloc>().add(const ChatUserTyping())
                : null,
            onSend: () => _submitComposer(activeState),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    List<ChatMessageDto> messages, {
    ChatSessionActive? activeState,
  }) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final highlights = activeState?.searchHighlightIds ?? const {};

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        _maybeMarkRead(message);
        if (message.isSystem) {
          return SystemMessageBubble(message: message);
        }
        final isMe = _isMe(message);
        final canInteract = _canInteractWithMessage(message, activeState);
        final canEdit = canInteract && isMe;
        return SessionMessageBubble(
          message: message,
          isMe: isMe,
          currentUserId: _patientId,
          highlighted: highlights.contains(message.messageId) ||
              message.messageId == _editingMessageId,
          canEdit: canEdit,
          canReact: canInteract,
          onEdit: canEdit ? () => _startEditingMessage(message) : null,
          onDelete: canEdit
              ? () => context.read<ChatSessionBloc>().add(
                    DeleteChatMessage(message.messageId),
                  )
              : null,
          onToggleReaction: canInteract
              ? (emoji) => context.read<ChatSessionBloc>().add(
                    ToggleChatReaction(
                      messageId: message.messageId,
                      emoji: emoji,
                    ),
                  )
              : null,
        );
      },
    );
  }

  void _maybeMarkRead(ChatMessageDto message) {
    if (_isMe(message) || message.isSystem) return;
    context
        .read<ChatSessionBloc>()
        .add(MarkVisibleMessageRead(message.messageId));
  }

  Widget _buildBackground() {
    return CommonImage(
      path: 'assets/image/chatbg.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search messages'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search…'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
    if (query == null || !mounted) return;
    if (query.trim().isEmpty) {
      context.read<ChatSessionBloc>().add(const ClearChatSearch());
    } else {
      context.read<ChatSessionBloc>().add(SearchChatMessages(query));
    }
  }

  Widget _buildScaffold({
    required String title,
    required Widget body,
    bool showEndSession = false,
    bool isOtherPartyOnline = false,
    bool showSearch = false,
    VoidCallback? onBack,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary, size: 28.sp),
          onPressed: onBack ?? () => safePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOtherPartyOnline)
              Text(
                'Online',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF16B783),
                  fontSize: 11.sp,
                ),
              ),
          ],
        ),
        actions: [
          if (showSearch)
            IconButton(
              icon: Icon(Icons.search, color: AppColors.textPrimary, size: 22.sp),
              onPressed: _showSearchDialog,
            ),
          if (showEndSession)
            TextButton(
              onPressed: _endLiveSession,
              child: Text(
                'End',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: body,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final double? iconSize;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.color,
    this.iconSize,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: iconSize ?? 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
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
            SizedBox(height: 24.h),
            CommonButton(
              text: 'Retry',
              onPressed: onRetry,
              borderRadius: 12.r,
            ),
          ],
        ),
      ),
    );
  }
}
