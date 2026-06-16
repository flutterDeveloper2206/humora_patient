import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/utils/session_manager.dart';
import '../../data/datasource/chat_api_service.dart';
import '../../data/datasource/chat_hub_service.dart';
import '../../data/models/chat_models.dart';
import '../../data/models/chat_reaction_model.dart';
import '../models/chat_session_args.dart';
import 'chat_session_event.dart';
import 'chat_session_state.dart';

class ChatSessionBloc extends Bloc<ChatSessionEvent, ChatSessionState> {
  final ChatSessionArgs _args;
  final ChatApiService _api;
  final ChatHubService _hub;
  final Uuid _uuid;

  Timer? _accessPollTimer;
  Timer? _countdownTimer;
  Timer? _closeTimer;
  Timer? _typingStopTimer;
  Duration _clockDrift = Duration.zero;
  ChatAccessResponse? _lastAccess;
  List<ChatMessageDto> _messages = const [];
  String? _patientId;
  int _historyPage = 1;
  bool _hasMoreHistory = false;
  bool _isTyping = false;
  final Set<String> _markedReadIds = {};

  final List<StreamSubscription<dynamic>> _hubSubs = [];

  ChatSessionBloc({
    required ChatSessionArgs args,
    ChatApiService? api,
    ChatHubService? hub,
    Uuid? uuid,
  }) : _args = args,
       _api = api ?? ChatApiService(),
       _hub = hub ?? ChatHubService.instance,
       _uuid = uuid ?? const Uuid(),
       super(ChatSessionAccessLoading(healerName: args.healerName)) {
    on<StartChatSession>(_onStart);
    on<RefreshChatAccess>(_onRefreshAccess);
    on<RetryChatSession>(_onRetry);
    on<SendChatMessage>(_onSend);
    on<ChatUserTyping>(_onUserTyping);
    on<ChatUserStoppedTyping>(_onUserStoppedTyping);
    on<HubMessageReceived>(_onHubMessage);
    on<HubMessageEdited>(_onHubEdited);
    on<HubMessageDeleted>(_onHubDeleted);
    on<HubMessageDelivered>(_onHubDelivered);
    on<HubMessageRead>(_onHubMessageRead);
    on<HubConversationRead>(_onHubConversationRead);
    on<HubReactionAdded>(_onHubReactionAdded);
    on<HubReactionRemoved>(_onHubReactionRemoved);
    on<HubTypingStarted>(_onHubTypingStarted);
    on<HubTypingStopped>(_onHubTypingStopped);
    on<HubUserOnline>(_onHubUserOnline);
    on<HubUserOffline>(_onHubUserOffline);
    on<HubChatWindow>(_onHubChatWindow);
    on<HubAccessDenied>(_onHubAccessDenied);
    on<HubErrorReceived>(_onHubError);
    on<ChatWindowTick>(_onTick);
    on<ChatComposerLocked>(_onComposerLocked);
    on<LoadOlderChatMessages>(_onLoadOlder);
    on<MarkVisibleMessageRead>(_onMarkVisibleRead);
    on<ChatAppLifecycleChanged>(_onLifecycleChanged);
    on<EditChatMessage>(_onEditMessage);
    on<DeleteChatMessage>(_onDeleteMessage);
    on<AddChatReaction>(_onAddReaction);
    on<RemoveChatReaction>(_onRemoveReaction);
    on<ToggleChatReaction>(_onToggleReaction);
    on<LoadConversationDetail>(_onLoadConversation);
    on<SearchChatMessages>(_onSearch);
    on<ClearChatSearch>(_onClearSearch);
    on<EndChatSession>(_onEnd);

    _subscribeHub();
  }

  void _subscribeHub() {
    _hubSubs.add(
      _hub.messageSent.listen((m) {
        if (m.bookingId == _args.bookingId) add(HubMessageReceived(m));
      }),
    );
    _hubSubs.add(
      _hub.messageEdited.listen((m) {
        if (m.bookingId == _args.bookingId) add(HubMessageEdited(m));
      }),
    );
    _hubSubs.add(
      _hub.messageDeleted.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final messageId = payload['messageId']?.toString();
        if (messageId != null) add(HubMessageDeleted(messageId));
      }),
    );
    _hubSubs.add(
      _hub.messageDelivered.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final messageId = payload['messageId']?.toString();
        if (messageId != null) add(HubMessageDelivered(messageId));
      }),
    );
    _hubSubs.add(
      _hub.messageRead.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final messageId = payload['messageId']?.toString();
        if (messageId != null) add(HubMessageRead(messageId));
      }),
    );
    _hubSubs.add(
      _hub.conversationRead.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        add(const HubConversationRead());
      }),
    );
    _hubSubs.add(
      _hub.reactionAdded.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        add(
          HubReactionAdded(
            messageId: payload['messageId']?.toString() ?? '',
            emoji: payload['emoji']?.toString() ?? '',
            userId: payload['userId']?.toString() ?? '',
          ),
        );
      }),
    );
    _hubSubs.add(
      _hub.reactionRemoved.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        add(
          HubReactionRemoved(
            messageId: payload['messageId']?.toString() ?? '',
            emoji: payload['emoji']?.toString() ?? '',
            userId: payload['userId']?.toString() ?? '',
          ),
        );
      }),
    );
    _hubSubs.add(
      _hub.typingStarted.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final userId = payload['userId']?.toString();
        if (userId != null && userId == _patientId) return;
        add(HubTypingStarted(payload['userName']?.toString() ?? 'Healer'));
      }),
    );
    _hubSubs.add(
      _hub.typingStopped.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        add(const HubTypingStopped());
      }),
    );
    _hubSubs.add(
      _hub.userOnline.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final userId = payload['userId']?.toString();
        if (userId != null && userId == _patientId) return;
        add(const HubUserOnline());
      }),
    );
    _hubSubs.add(
      _hub.userOffline.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        final userId = payload['userId']?.toString();
        if (userId != null && userId == _patientId) return;
        add(const HubUserOffline());
      }),
    );
    _hubSubs.add(
      _hub.chatWindow.listen((payload) {
        if (payload['bookingId']?.toString() != _args.bookingId) return;
        add(
          HubChatWindow(
            ChatAccessResponse(
              canRead: true,
              canWrite: true,
              code: 'OK',
              chatOpensAt: _parseDate(payload['chatOpensAt']),
              chatClosesAt: _parseDate(payload['chatClosesAt']),
              scheduledStartAt: _parseDate(payload['scheduledStartAt']),
              scheduledEndAt: _parseDate(payload['scheduledEndAt']),
            ),
          ),
        );
      }),
    );
    _hubSubs.add(
      _hub.chatAccessDenied.listen((payload) {
        final bookingId = payload['bookingId']?.toString();
        if (bookingId != null && bookingId != _args.bookingId) return;
        add(
          HubAccessDenied(
            code: payload['code']?.toString() ?? 'SESSION_ENDED',
            message: payload['message']?.toString() ?? '',
          ),
        );
      }),
    );
    _hubSubs.add(
      _hub.hubError.listen((error) {
        add(HubErrorReceived(error.message, code: error.code));
      }),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  Future<void> _onStart(
    StartChatSession event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionAccessLoading(healerName: _args.healerName));
    await _loadSession(emit);
  }

  Future<void> _onRetry(
    RetryChatSession event,
    Emitter<ChatSessionState> emit,
  ) async {
    emit(ChatSessionAccessLoading(healerName: _args.healerName));
    await _loadSession(emit);
  }

  Future<void> _onRefreshAccess(
    RefreshChatAccess event,
    Emitter<ChatSessionState> emit,
  ) async {
    try {
      final access = await _api.getAccess(_args.bookingId);
      _lastAccess = access;
      _clockDrift = access.clockDrift;
      await _emitForAccess(access, emit, preserveMessages: true);
    } catch (e) {
      // Silent on poll failure — keep current UI.
    }
  }

  Future<void> _loadSession(Emitter<ChatSessionState> emit) async {
    _cancelTimers();
    try {
      _patientId ??= await _requirePatientId();
      final access = await _api.getAccess(_args.bookingId);
      _lastAccess = access;
      _clockDrift = access.clockDrift;

      if (access.canRead) {
        final history = await _api.getHistory(_args.bookingId);
        _messages = history.messages;
        _historyPage = history.page;
        _hasMoreHistory = history.hasMore;
      } else {
        _messages = const [];
        _historyPage = 1;
        _hasMoreHistory = false;
      }

      await _emitForAccess(access, emit);
      _startAccessPoll();
      _startCountdownTimer();
      _scheduleCloseTimer(access);
      add(const LoadConversationDetail());
    } catch (e) {
      emit(
        ChatSessionError(message: _cleanError(e), healerName: _args.healerName),
      );
    }
  }

  Future<void> _emitForAccess(
    ChatAccessResponse access,
    Emitter<ChatSessionState> emit, {
    bool preserveMessages = false,
  }) async {
    if (!preserveMessages) {
      // _messages already loaded on full session load.
    }

    final code = access.code.toUpperCase();
    final healerName = _args.healerName;
    final isLive = _args.isLiveSession;

    if (code == 'BOOKING_CANCELLED') {
      emit(
        ChatSessionCancelled(
          access: access,
          messages: _messages,
          healerName: healerName,
        ),
      );
      await _leaveHub();
      return;
    }

    if (code == 'NOT_PARTICIPANT' || code == 'BOOKING_NOT_FOUND') {
      emit(
        ChatSessionError(
          message: access.message.isNotEmpty
              ? access.message
              : 'You cannot access this chat.',
          healerName: healerName,
        ),
      );
      await _leaveHub();
      return;
    }

    // Scheduled booking: waiting room — do not open SignalR (ChatFlow Step 1).
    if (!isLive &&
        (code == 'SESSION_NOT_STARTED' ||
            (!access.canWrite && _isBeforeOpen(access)))) {
      emit(
        ChatSessionWaitingRoom(
          access: access,
          messages: _messages,
          healerName: healerName,
          countdown: _countdownToOpen(access),
        ),
      );
      await _leaveHub();
      return;
    }

    // Session ended / read-only history — no SignalR (ChatFlow 4:00 PM).
    if (!isLive &&
        (code == 'SESSION_ENDED' || (!access.canWrite && access.canRead))) {
      emit(
        ChatSessionHistoryOnly(
          access: access,
          messages: _messages,
          healerName: healerName,
          showBookAgain: code == 'SESSION_ENDED' || !access.canWrite,
        ),
      );
      await _leaveHub();
      return;
    }

    if (isLive && code == 'SESSION_ENDED') {
      emit(
        ChatSessionHistoryOnly(
          access: access,
          messages: _messages,
          healerName: healerName,
          showBookAgain: true,
        ),
      );
      await _leaveHub();
      return;
    }

    // Writable window — connect hub + JoinChat (ChatFlow Steps 4–5).
    if (access.canWrite || (isLive && access.canRead && code == 'OK')) {
      final joined = await _joinHub();
      emit(
        ChatSessionActive(
          access: access,
          messages: _messages,
          healerName: healerName,
          isLiveSession: isLive,
          canCompose: access.canWrite && !_isPastClose(access),
          hasMoreHistory: _hasMoreHistory,
        ),
      );
      _scheduleCloseTimer(access);
      if (!joined) {
        developer.log(
          'ChatSessionBloc → hub join failed; REST send fallback available',
          name: 'ChatSessionBloc',
        );
      }
      return;
    }

    if (access.canRead) {
      emit(
        ChatSessionHistoryOnly(
          access: access,
          messages: _messages,
          healerName: healerName,
          showBookAgain: isLive,
        ),
      );
      await _leaveHub();
      return;
    }

    emit(
      ChatSessionError(
        message: access.message.isNotEmpty
            ? access.message
            : 'Chat is unavailable.',
        healerName: healerName,
      ),
    );
  }

  Future<void> _onSend(
    SendChatMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    final content = event.content.trim();
    if (content.isEmpty) return;

    final current = state;
    if (current is! ChatSessionActive || !current.canCompose) return;

    _patientId ??= await _requirePatientId();

    final idempotencyKey = _uuid.v4();
    final pending = ChatMessageDto(
      messageId: 'pending-$idempotencyKey',
      bookingId: _args.bookingId,
      senderId: _patientId ?? '',
      senderName: 'You',
      senderRole: 'Patient',
      content: content,
      createdAt: DateTime.now().toUtc(),
      idempotencyKey: idempotencyKey,
      isPending: true,
    );

    _messages = [..._messages, pending];
    emit(
      current.copyWith(messages: List.from(_messages), clearSendError: true),
    );

    try {
      if (_hub.isConnected) {
        await _hub.sendMessage(
          bookingId: _args.bookingId,
          content: content,
          idempotencyKey: idempotencyKey,
        );
      } else {
        final confirmed = await _api.sendMessageRest(
          bookingId: _args.bookingId,
          content: content,
          idempotencyKey: idempotencyKey,
        );
        add(HubMessageReceived(confirmed));
      }
      add(const ChatUserStoppedTyping());
    } catch (e) {
      _messages = _messages
          .where((m) => m.idempotencyKey != idempotencyKey)
          .toList();
      final errorMessage = _cleanError(e);
      final isRateLimit =
          e is ChatApiException &&
          (e.code?.toUpperCase() == 'RATE_LIMIT' ||
              errorMessage.toLowerCase().contains('slow down'));
      if (state is ChatSessionActive) {
        emit(
          (state as ChatSessionActive).copyWith(
            messages: List.from(_messages),
            sendError: isRateLimit
                ? 'Slow down… You are sending messages too quickly.'
                : errorMessage,
          ),
        );
      }
    }
  }

  Future<void> _onUserTyping(
    ChatUserTyping event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive ||
        !(state as ChatSessionActive).canCompose) {
      return;
    }
    if (!_isTyping) {
      _isTyping = true;
      try {
        await _hub.startTyping(_args.bookingId);
      } catch (_) {}
    }
    _typingStopTimer?.cancel();
    _typingStopTimer = Timer(const Duration(seconds: 3), () {
      if (!isClosed) add(const ChatUserStoppedTyping());
    });
  }

  Future<void> _onUserStoppedTyping(
    ChatUserStoppedTyping event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (!_isTyping) return;
    _isTyping = false;
    _typingStopTimer?.cancel();
    try {
      await _hub.stopTyping(_args.bookingId);
    } catch (_) {}
  }

  void _onHubMessage(HubMessageReceived event, Emitter<ChatSessionState> emit) {
    final incoming = event.message;

    if (incoming.messageId.isNotEmpty) {
      final confirmedIdx = _messages.indexWhere(
        (m) => !m.isPending && m.messageId == incoming.messageId,
      );
      if (confirmedIdx >= 0) {
        final existing = _messages[confirmedIdx];
        final updated = List<ChatMessageDto>.from(_messages);
        updated[confirmedIdx] = existing.copyWith(
          isDelivered: incoming.isDelivered || existing.isDelivered,
          isReadByOther: incoming.isReadByOther || existing.isReadByOther,
        );
        _messages = updated;
        _emitMessagesUpdate(emit);
        return;
      }
    }

    final pendingIdx = _findPendingIndexForIncoming(incoming);

    if (pendingIdx >= 0) {
      final pending = _messages[pendingIdx];
      final updated = List<ChatMessageDto>.from(_messages);
      updated[pendingIdx] = incoming.copyWith(
        isPending: false,
        isDelivered: true,
        idempotencyKey: incoming.idempotencyKey ?? pending.idempotencyKey,
      );
      _messages = updated;
      _emitMessagesUpdate(emit);
      return;
    }

    _messages = _removeMatchingPending(incoming);

    final normalizedContent = incoming.content.trim();
    if (normalizedContent.isNotEmpty) {
      final ownDuplicateIdx = _messages.lastIndexWhere(
        (m) =>
            !m.isPending &&
            m.content.trim() == normalizedContent &&
            (m.senderRole.toLowerCase() == 'patient' ||
                (_patientId != null &&
                    _patientId!.isNotEmpty &&
                    m.senderId == _patientId)),
      );
      if (ownDuplicateIdx >= 0) {
        final updated = List<ChatMessageDto>.from(_messages);
        updated[ownDuplicateIdx] = incoming.copyWith(
          isPending: false,
          isDelivered: true,
          idempotencyKey:
              incoming.idempotencyKey ?? updated[ownDuplicateIdx].idempotencyKey,
        );
        _messages = updated;
        _emitMessagesUpdate(emit);
        return;
      }
    }

    if (incoming.messageId.isNotEmpty || incoming.content.trim().isNotEmpty) {
      _messages = [
        ..._messages,
        incoming.copyWith(isPending: false, isDelivered: incoming.isDelivered),
      ];
    }

    _emitMessagesUpdate(emit);
  }

  /// Pending rows are always local optimistic sends — match by key or content.
  int _findPendingIndexForIncoming(ChatMessageDto incoming) {
    final incomingKey = incoming.idempotencyKey;
    if (incomingKey != null && incomingKey.isNotEmpty) {
      final byKey = _messages.indexWhere(
        (m) => m.isPending && m.idempotencyKey == incomingKey,
      );
      if (byKey >= 0) return byKey;

      final byPendingId = _messages.indexWhere(
        (m) => m.isPending && m.messageId == 'pending-$incomingKey',
      );
      if (byPendingId >= 0) return byPendingId;
    }

    final normalizedContent = incoming.content.trim();
    if (normalizedContent.isEmpty) return -1;

    for (var i = _messages.length - 1; i >= 0; i--) {
      final m = _messages[i];
      if (m.isPending && m.content.trim() == normalizedContent) {
        return i;
      }
    }

    return -1;
  }

  List<ChatMessageDto> _removeMatchingPending(ChatMessageDto incoming) {
    final normalizedContent = incoming.content.trim();
    final incomingKey = incoming.idempotencyKey;

    return _messages.where((m) {
      if (!m.isPending) return true;
      if (incomingKey != null &&
          incomingKey.isNotEmpty &&
          (m.idempotencyKey == incomingKey ||
              m.messageId == 'pending-$incomingKey')) {
        return false;
      }
      if (normalizedContent.isNotEmpty &&
          m.content.trim() == normalizedContent) {
        return false;
      }
      return true;
    }).toList();
  }

  void _onHubEdited(HubMessageEdited event, Emitter<ChatSessionState> emit) {
    _messages = _messages.map((m) {
      if (m.messageId == event.message.messageId) return event.message;
      return m;
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubDeleted(HubMessageDeleted event, Emitter<ChatSessionState> emit) {
    _messages = _messages.map((m) {
      if (m.messageId == event.messageId) {
        return m.copyWith(isDeleted: true, content: '[Message deleted]');
      }
      return m;
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubDelivered(
    HubMessageDelivered event,
    Emitter<ChatSessionState> emit,
  ) {
    _messages = _messages.map((m) {
      if (m.messageId == event.messageId) {
        return m.copyWith(isDelivered: true);
      }
      return m;
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubMessageRead(HubMessageRead event, Emitter<ChatSessionState> emit) {
    _messages = _messages.map((m) {
      if (m.messageId != event.messageId) return m;
      if (m.senderId == _patientId || m.senderRole.toLowerCase() == 'patient') {
        return m.copyWith(isReadByOther: true, isDelivered: true);
      }
      return m.copyWith(isReadByMe: true);
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubConversationRead(
    HubConversationRead event,
    Emitter<ChatSessionState> emit,
  ) {
    _messages = _messages.map((m) {
      if (m.senderId == _patientId || m.senderRole.toLowerCase() == 'patient') {
        return m.copyWith(isReadByOther: true, isDelivered: true);
      }
      return m;
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubReactionAdded(
    HubReactionAdded event,
    Emitter<ChatSessionState> emit,
  ) {
    _messages = _messages.map((m) {
      if (m.messageId != event.messageId) return m;
      final reactions = List<ChatReactionDto>.from(m.reactions);
      final idx = reactions.indexWhere((r) => r.emoji == event.emoji);
      if (idx >= 0) {
        final users = List<String>.from(reactions[idx].userIds);
        if (!users.contains(event.userId)) users.add(event.userId);
        reactions[idx] = reactions[idx].copyWith(userIds: users);
      } else {
        reactions.add(
          ChatReactionDto(emoji: event.emoji, userIds: [event.userId]),
        );
      }
      return m.copyWith(reactions: reactions);
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubReactionRemoved(
    HubReactionRemoved event,
    Emitter<ChatSessionState> emit,
  ) {
    _messages = _messages.map((m) {
      if (m.messageId != event.messageId) return m;
      final reactions = m.reactions
          .map((r) {
            if (r.emoji != event.emoji) return r;
            final users = r.userIds.where((id) => id != event.userId).toList();
            return r.copyWith(userIds: users);
          })
          .where((r) => r.userIds.isNotEmpty)
          .toList();
      return m.copyWith(reactions: reactions);
    }).toList();
    _emitMessagesUpdate(emit);
  }

  void _onHubTypingStarted(
    HubTypingStarted event,
    Emitter<ChatSessionState> emit,
  ) {
    final current = state;
    if (current is ChatSessionActive) {
      emit(current.copyWith(typingUserName: event.userName));
    }
  }

  void _onHubTypingStopped(
    HubTypingStopped event,
    Emitter<ChatSessionState> emit,
  ) {
    final current = state;
    if (current is ChatSessionActive) {
      emit(current.copyWith(clearTyping: true));
    }
  }

  void _onHubUserOnline(HubUserOnline event, Emitter<ChatSessionState> emit) {
    final current = state;
    if (current is ChatSessionActive) {
      emit(current.copyWith(isOtherPartyOnline: true));
    }
  }

  void _onHubUserOffline(HubUserOffline event, Emitter<ChatSessionState> emit) {
    final current = state;
    if (current is ChatSessionActive) {
      emit(current.copyWith(isOtherPartyOnline: false));
    }
  }

  void _onHubChatWindow(HubChatWindow event, Emitter<ChatSessionState> emit) {
    _lastAccess = event.access;
    _scheduleCloseTimer(event.access);
    final current = state;
    if (current is ChatSessionActive) {
      emit(
        current.copyWith(
          access: event.access,
          canCompose: !_isPastClose(event.access),
        ),
      );
    }
  }

  void _onHubError(HubErrorReceived event, Emitter<ChatSessionState> emit) {
    if (event.code?.toUpperCase() == 'RATE_LIMIT' &&
        state is ChatSessionActive) {
      emit(
        (state as ChatSessionActive).copyWith(
          sendError: event.message.isNotEmpty
              ? event.message
              : 'Slow down… You are sending messages too quickly.',
        ),
      );
    }
  }

  Future<void> _onLoadOlder(
    LoadOlderChatMessages event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (!_hasMoreHistory || state is! ChatSessionActive) return;
    final current = state as ChatSessionActive;
    if (current.isLoadingOlder) return;

    emit(current.copyWith(isLoadingOlder: true));
    try {
      final nextPage = _historyPage + 1;
      final history = await _api.getHistory(_args.bookingId, page: nextPage);
      _historyPage = history.page;
      _hasMoreHistory = history.hasMore;
      _messages = [...history.messages, ..._messages];
      emit(
        current.copyWith(
          messages: List.from(_messages),
          hasMoreHistory: _hasMoreHistory,
          isLoadingOlder: false,
        ),
      );
    } catch (_) {
      emit(current.copyWith(isLoadingOlder: false));
    }
  }

  Future<void> _onMarkVisibleRead(
    MarkVisibleMessageRead event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (_markedReadIds.contains(event.messageId)) return;
    _markedReadIds.add(event.messageId);
    try {
      await _hub.markRead(_args.bookingId, event.messageId);
    } catch (_) {}
  }

  Future<void> _onLifecycleChanged(
    ChatAppLifecycleChanged event,
    Emitter<ChatSessionState> emit,
  ) async {
    // AppHubLifecycle suspends hubs on background; only re-sync chat on resume.
    if (event.state == AppLifecycleState.resumed) {
      add(const RefreshChatAccess());
    }
  }

  Future<void> _onEditMessage(
    EditChatMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive ||
        !(state as ChatSessionActive).canCompose) {
      return;
    }
    if (!_isPersistedMessageId(event.messageId)) return;

    final previous = _messages;
    _messages = _messages.map((m) {
      if (m.messageId != event.messageId) return m;
      return m.copyWith(content: event.content, isEdited: true);
    }).toList();
    _emitMessagesUpdate(emit);

    try {
      if (_hub.isConnected) {
        await _hub.editMessage(
          bookingId: _args.bookingId,
          messageId: event.messageId,
          newContent: event.content,
        );
      } else {
        final updated = await _api.editMessageRest(
          messageId: event.messageId,
          content: event.content,
        );
        add(HubMessageEdited(updated));
      }
    } catch (e) {
      _messages = previous;
      _emitMessagesUpdate(emit);
      if (state is ChatSessionActive) {
        emit((state as ChatSessionActive).copyWith(sendError: _cleanError(e)));
      }
    }
  }

  Future<void> _onDeleteMessage(
    DeleteChatMessage event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;
    if (!_isPersistedMessageId(event.messageId)) return;

    final previous = _messages;
    _messages = _messages.map((m) {
      if (m.messageId != event.messageId) return m;
      return m.copyWith(isDeleted: true, content: '[Message deleted]');
    }).toList();
    _emitMessagesUpdate(emit);

    try {
      if (_hub.isConnected) {
        await _hub.deleteMessage(
          bookingId: _args.bookingId,
          messageId: event.messageId,
        );
      } else {
        await _api.deleteMessageRest(event.messageId);
        add(HubMessageDeleted(event.messageId));
      }
    } catch (e) {
      _messages = previous;
      _emitMessagesUpdate(emit);
      if (state is ChatSessionActive) {
        emit((state as ChatSessionActive).copyWith(sendError: _cleanError(e)));
      }
    }
  }

  Future<void> _onToggleReaction(
    ToggleChatReaction event,
    Emitter<ChatSessionState> emit,
  ) async {
    _patientId ??= await _requirePatientId();
    final patientId = _patientId ?? '';
    if (patientId.isEmpty) return;

    final message = _messages.cast<ChatMessageDto?>().firstWhere(
          (m) => m?.messageId == event.messageId,
          orElse: () => null,
        );
    if (message == null || !_isPersistedMessageId(event.messageId)) return;

    final alreadyReacted = message.reactions.any(
      (r) => r.emoji == event.emoji && r.hasUser(patientId),
    );
    if (alreadyReacted) {
      add(RemoveChatReaction(messageId: event.messageId, emoji: event.emoji));
    } else {
      add(AddChatReaction(messageId: event.messageId, emoji: event.emoji));
    }
  }

  Future<void> _onAddReaction(
    AddChatReaction event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;
    if (!_isPersistedMessageId(event.messageId)) return;

    _patientId ??= await _requirePatientId();
    final patientId = _patientId ?? '';
    if (patientId.isEmpty) return;

    final previous = _messages;
    _applyLocalReaction(
      messageId: event.messageId,
      emoji: event.emoji,
      userId: patientId,
      add: true,
    );
    _emitMessagesUpdate(emit);

    try {
      if (_hub.isConnected) {
        await _hub.addReaction(
          bookingId: _args.bookingId,
          messageId: event.messageId,
          emoji: event.emoji,
        );
      }
    } catch (_) {
      _messages = previous;
      _emitMessagesUpdate(emit);
    }
  }

  Future<void> _onRemoveReaction(
    RemoveChatReaction event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;
    if (!_isPersistedMessageId(event.messageId)) return;

    _patientId ??= await _requirePatientId();
    final patientId = _patientId ?? '';
    if (patientId.isEmpty) return;

    final previous = _messages;
    _applyLocalReaction(
      messageId: event.messageId,
      emoji: event.emoji,
      userId: patientId,
      add: false,
    );
    _emitMessagesUpdate(emit);

    try {
      if (_hub.isConnected) {
        await _hub.removeReaction(
          bookingId: _args.bookingId,
          messageId: event.messageId,
          emoji: event.emoji,
        );
      }
    } catch (_) {
      _messages = previous;
      _emitMessagesUpdate(emit);
    }
  }

  bool _isPersistedMessageId(String messageId) =>
      messageId.isNotEmpty && !messageId.startsWith('pending-');

  void _applyLocalReaction({
    required String messageId,
    required String emoji,
    required String userId,
    required bool add,
  }) {
    _messages = _messages.map((m) {
      if (m.messageId != messageId) return m;
      final reactions = List<ChatReactionDto>.from(m.reactions);
      final idx = reactions.indexWhere((r) => r.emoji == emoji);
      if (add) {
        if (idx >= 0) {
          final users = List<String>.from(reactions[idx].userIds);
          if (!users.contains(userId)) users.add(userId);
          reactions[idx] = reactions[idx].copyWith(userIds: users);
        } else {
          reactions.add(ChatReactionDto(emoji: emoji, userIds: [userId]));
        }
      } else if (idx >= 0) {
        final users =
            reactions[idx].userIds.where((id) => id != userId).toList();
        if (users.isEmpty) {
          reactions.removeAt(idx);
        } else {
          reactions[idx] = reactions[idx].copyWith(userIds: users);
        }
      }
      return m.copyWith(reactions: reactions);
    }).toList();
  }

  Future<void> _onLoadConversation(
    LoadConversationDetail event,
    Emitter<ChatSessionState> emit,
  ) async {
    try {
      final detail = await _api.getConversation(_args.bookingId);
      final current = state;
      if (current is ChatSessionActive) {
        emit(
          current.copyWith(
            isOtherPartyOnline: detail.isOtherPartyOnline,
            healerName: detail.otherPartyName ?? current.healerName,
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _onSearch(
    SearchChatMessages event,
    Emitter<ChatSessionState> emit,
  ) async {
    if (state is! ChatSessionActive) return;
    final query = event.query.trim();
    if (query.isEmpty) {
      add(const ClearChatSearch());
      return;
    }
    try {
      final results = await _api.searchMessages(_args.bookingId, query);
      final ids = results.map((m) => m.messageId).toSet();
      emit((state as ChatSessionActive).copyWith(searchHighlightIds: ids));
    } catch (_) {}
  }

  void _onClearSearch(ClearChatSearch event, Emitter<ChatSessionState> emit) {
    if (state is ChatSessionActive) {
      emit((state as ChatSessionActive).copyWith(clearSearchHighlight: true));
    }
  }

  void _onHubAccessDenied(
    HubAccessDenied event,
    Emitter<ChatSessionState> emit,
  ) {
    final access = _lastAccess;
    if (access == null) return;

    final code = event.code.toUpperCase();
    if (code == 'BOOKING_CANCELLED') {
      emit(
        ChatSessionCancelled(
          access: access,
          messages: _messages,
          healerName: _args.healerName,
        ),
      );
    } else {
      emit(
        ChatSessionHistoryOnly(
          access: access.copyWithAccess(canWrite: false, code: code),
          messages: _messages,
          healerName: _args.healerName,
          showBookAgain: code == 'SESSION_ENDED',
        ),
      );
    }
    _leaveHub();
  }

  void _onTick(ChatWindowTick event, Emitter<ChatSessionState> emit) {
    final access = _lastAccess;
    if (access == null) return;

    final current = state;
    if (current is ChatSessionWaitingRoom) {
      final countdown = _countdownToOpen(access);
      if (countdown <= Duration.zero) {
        add(const RefreshChatAccess());
        return;
      }
      emit(current.copyWith(countdown: countdown));
      return;
    }

    if (current is ChatSessionActive && current.canCompose) {
      if (_isPastClose(access)) {
        add(const ChatComposerLocked());
      }
    }
  }

  void _onComposerLocked(
    ChatComposerLocked event,
    Emitter<ChatSessionState> emit,
  ) {
    final current = state;
    if (current is ChatSessionActive && current.canCompose) {
      emit(current.copyWith(canCompose: false));
    }
  }

  Future<void> _onEnd(
    EndChatSession event,
    Emitter<ChatSessionState> emit,
  ) async {
    await _leaveHub();
    _cancelTimers();
    for (final sub in _hubSubs) {
      await sub.cancel();
    }
    _hubSubs.clear();
  }

  void _emitMessagesUpdate(Emitter<ChatSessionState> emit) {
    final current = state;
    if (current is ChatSessionActive) {
      emit(current.copyWith(messages: List.from(_messages)));
    } else if (current is ChatSessionWaitingRoom) {
      emit(current.copyWith(messages: List.from(_messages)));
    } else if (current is ChatSessionHistoryOnly) {
      emit(
        ChatSessionHistoryOnly(
          access: current.access,
          messages: List.from(_messages),
          healerName: current.healerName,
          showBookAgain: current.showBookAgain,
        ),
      );
    }
  }

  DateTime _adjustedNow() => DateTime.now().toUtc().subtract(_clockDrift);

  bool _isBeforeOpen(ChatAccessResponse access) {
    final opensAt = access.chatOpensAt;
    if (opensAt == null) return false;
    return _adjustedNow().isBefore(opensAt.toUtc());
  }

  bool _isPastClose(ChatAccessResponse access) {
    final closesAt = access.chatClosesAt;
    if (closesAt == null) return false;
    return !_adjustedNow().isBefore(closesAt.toUtc());
  }

  Duration _countdownToOpen(ChatAccessResponse access) {
    final opensAt = access.chatOpensAt;
    if (opensAt == null) return Duration.zero;
    final diff = opensAt.toUtc().difference(_adjustedNow());
    return diff.isNegative ? Duration.zero : diff;
  }

  void _startAccessPoll() {
    _accessPollTimer?.cancel();
    _accessPollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const RefreshChatAccess()),
    );
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => add(const ChatWindowTick()),
    );
  }

  void _scheduleCloseTimer(ChatAccessResponse access) {
    _closeTimer?.cancel();
    final closesAt = access.chatClosesAt;
    if (closesAt == null) return;

    final delay = closesAt.toUtc().difference(_adjustedNow());
    if (delay.isNegative) return;

    _closeTimer = Timer(delay, () => add(const ChatComposerLocked()));
  }

  Future<bool> _joinHub() async {
    final maxAttempts = _args.isLiveSession ? 4 : 1;
    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        if (attempt > 0) {
          await Future.delayed(Duration(milliseconds: 400 * attempt));
        }
        await _hub.joinChat(_args.bookingId);
        await _hub.markConversationRead(_args.bookingId);
        return true;
      } catch (e) {
        developer.log(
          'ChatSessionBloc → joinChat attempt ${attempt + 1} failed: $e',
          name: 'ChatSessionBloc',
        );
      }
    }
    return false;
  }

  Future<void> _leaveHub() async {
    _typingStopTimer?.cancel();
    _isTyping = false;
    try {
      await _hub.leaveChat(_args.bookingId);
    } catch (_) {}
  }

  void _cancelTimers() {
    _accessPollTimer?.cancel();
    _countdownTimer?.cancel();
    _closeTimer?.cancel();
    _typingStopTimer?.cancel();
  }

  Future<String> _requirePatientId() async {
    return await SessionManager.getPatientId() ?? '';
  }

  String _cleanError(Object e) {
    if (e is ChatApiException) return e.message;
    return e.toString().replaceAll('Exception: ', '');
  }

  @override
  Future<void> close() {
    _cancelTimers();
    for (final sub in _hubSubs) {
      sub.cancel();
    }
    _leaveHub();
    return super.close();
  }
}

extension on ChatAccessResponse {
  ChatAccessResponse copyWithAccess({bool? canWrite, String? code}) {
    return ChatAccessResponse(
      canRead: canRead,
      canWrite: canWrite ?? this.canWrite,
      code: code ?? this.code,
      message: message,
      chatOpensAt: chatOpensAt,
      chatClosesAt: chatClosesAt,
      scheduledStartAt: scheduledStartAt,
      scheduledEndAt: scheduledEndAt,
      serverTimeUtc: serverTimeUtc,
    );
  }
}
