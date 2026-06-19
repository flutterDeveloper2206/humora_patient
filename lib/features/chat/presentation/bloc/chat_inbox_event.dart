import 'package:equatable/equatable.dart';

import '../../data/models/chat_models.dart';

abstract class ChatInboxEvent extends Equatable {
  const ChatInboxEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatInbox extends ChatInboxEvent {
  const LoadChatInbox();
}

class RefreshChatInbox extends ChatInboxEvent {
  const RefreshChatInbox();
}

class ConversationUpdatedReceived extends ChatInboxEvent {
  final ConversationUpdatedEvent event;

  const ConversationUpdatedReceived(this.event);

  @override
  List<Object?> get props => [event];
}

class SilentRefreshChatInbox extends ChatInboxEvent {
  const SilentRefreshChatInbox();
}
