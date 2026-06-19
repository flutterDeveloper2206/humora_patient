import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/chat_api_service.dart';
import '../../data/datasource/chat_hub_service.dart';
import '../../data/models/chat_models.dart';
import 'chat_inbox_event.dart';
import 'chat_inbox_state.dart';

class ChatInboxBloc extends Bloc<ChatInboxEvent, ChatInboxState> {
  final ChatApiService _api;
  final ChatHubService _hub;
  int _fetchGeneration = 0;
  StreamSubscription<ConversationUpdatedEvent>? _conversationUpdatedSub;
  Timer? _silentRefreshTimer;

  ChatInboxBloc({
    ChatApiService? api,
    ChatHubService? hub,
  })  : _api = api ?? ChatApiService(),
        _hub = hub ?? ChatHubService.instance,
        super(ChatInboxInitial()) {
    on<LoadChatInbox>(_onLoad);
    on<RefreshChatInbox>(_onRefresh);
    on<ConversationUpdatedReceived>(_onConversationUpdated);
    on<SilentRefreshChatInbox>(_onSilentRefresh);
    _conversationUpdatedSub = _hub.conversationUpdated.listen((event) {
      add(ConversationUpdatedReceived(event));
    });
  }

  @override
  Future<void> close() {
    _conversationUpdatedSub?.cancel();
    _silentRefreshTimer?.cancel();
    return super.close();
  }

  Future<void> _onLoad(
    LoadChatInbox event,
    Emitter<ChatInboxState> emit,
  ) async {
    if (state is ChatInboxLoaded || state is ChatInboxLoading) return;
    emit(ChatInboxLoading());
    await _fetch(emit, restoreOnError: null);
  }

  Future<void> _onRefresh(
    RefreshChatInbox event,
    Emitter<ChatInboxState> emit,
  ) async {
    final current = state;
    if (current is ChatInboxLoaded) {
      emit(current.copyWith(isRefreshing: true));
    } else if (current is! ChatInboxLoading) {
      emit(ChatInboxLoading());
    }
    await _fetch(
      emit,
      restoreOnError: current is ChatInboxLoaded ? current : null,
    );
  }

  Future<void> _onConversationUpdated(
    ConversationUpdatedReceived event,
    Emitter<ChatInboxState> emit,
  ) async {
    final current = state;
    if (current is! ChatInboxLoaded) {
      _scheduleSilentRefresh();
      return;
    }

    final updated = event.event;
    if (updated.otherPartyUserId.isEmpty) {
      _scheduleSilentRefresh();
      return;
    }

    final index = current.conversations.indexWhere(
      (c) => c.otherPartyUserId == updated.otherPartyUserId,
    );

    if (index < 0) {
      _scheduleSilentRefresh();
      return;
    }

    final existing = current.conversations[index];
    final shouldUpdatePreview = updated.lastMessageAt != null &&
        (existing.lastMessageAt == null ||
            !updated.lastMessageAt!.isBefore(existing.lastMessageAt!));

    if (!shouldUpdatePreview) {
      _scheduleSilentRefresh();
      return;
    }

    final next = existing.copyWith(
      lastMessage: updated.lastMessage ?? existing.lastMessage,
      lastMessageAt: updated.lastMessageAt ?? existing.lastMessageAt,
    );

    final list = List<ChatInboxEntryDto>.from(current.conversations);
    list[index] = next;
    list.sort(_sortByLastMessage);

    emit(current.copyWith(conversations: list));
    _scheduleSilentRefresh();
  }

  void _scheduleSilentRefresh() {
    _silentRefreshTimer?.cancel();
    _silentRefreshTimer = Timer(const Duration(milliseconds: 600), () {
      if (isClosed) return;
      add(const SilentRefreshChatInbox());
    });
  }

  Future<void> _onSilentRefresh(
    SilentRefreshChatInbox event,
    Emitter<ChatInboxState> emit,
  ) async {
    final current = state;
    if (current is! ChatInboxLoaded || current.isRefreshing) return;
    final generation = ++_fetchGeneration;
    try {
      final conversations = await _api.getConversations();
      if (generation != _fetchGeneration) return;
      emit(current.copyWith(conversations: conversations));
    } catch (_) {}
  }

  Future<void> _fetch(
    Emitter<ChatInboxState> emit, {
    ChatInboxLoaded? restoreOnError,
  }) async {
    final generation = ++_fetchGeneration;
    try {
      final conversations = await _api.getConversations();
      if (generation != _fetchGeneration) return;
      emit(ChatInboxLoaded(conversations: conversations, isRefreshing: false));
    } catch (e) {
      if (generation != _fetchGeneration) return;
      if (restoreOnError != null) {
        emit(restoreOnError.copyWith(isRefreshing: false));
        return;
      }
      emit(ChatInboxError(_cleanError(e)));
    }
  }

  int _sortByLastMessage(ChatInboxEntryDto a, ChatInboxEntryDto b) {
    final aAt = a.lastMessageAt;
    final bAt = b.lastMessageAt;
    if (aAt == null && bAt == null) return 0;
    if (aAt == null) return 1;
    if (bAt == null) return -1;
    return bAt.compareTo(aAt);
  }

  String _cleanError(Object e) {
    if (e is ChatApiException) return e.message;
    return e.toString().replaceAll('Exception: ', '');
  }
}
