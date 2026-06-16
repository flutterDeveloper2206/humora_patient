import 'package:equatable/equatable.dart';

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
