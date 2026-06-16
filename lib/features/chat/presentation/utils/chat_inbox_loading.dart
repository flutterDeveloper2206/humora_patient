import '../bloc/chat_inbox_state.dart';

extension ChatInboxStateLoading on ChatInboxState {
  bool get isBusy =>
      this is ChatInboxInitial ||
      this is ChatInboxLoading ||
      (this is ChatInboxLoaded && (this as ChatInboxLoaded).isRefreshing);
}
