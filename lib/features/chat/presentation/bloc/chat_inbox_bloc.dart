import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/chat_api_service.dart';
import 'chat_inbox_event.dart';
import 'chat_inbox_state.dart';

class ChatInboxBloc extends Bloc<ChatInboxEvent, ChatInboxState> {
  final ChatApiService _api;
  int _fetchGeneration = 0;

  ChatInboxBloc({ChatApiService? api})
      : _api = api ?? ChatApiService(),
        super(ChatInboxInitial()) {
    on<LoadChatInbox>(_onLoad);
    on<RefreshChatInbox>(_onRefresh);
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

  String _cleanError(Object e) {
    if (e is ChatApiException) return e.message;
    return e.toString().replaceAll('Exception: ', '');
  }
}
