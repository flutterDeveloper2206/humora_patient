import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import '../../data/models/chat_models.dart';

abstract class ChatSessionEvent extends Equatable {
  const ChatSessionEvent();

  @override
  List<Object?> get props => [];
}

class StartChatSession extends ChatSessionEvent {
  const StartChatSession();
}

class RefreshChatAccess extends ChatSessionEvent {
  const RefreshChatAccess();
}

class RetryChatSession extends ChatSessionEvent {
  const RetryChatSession();
}

class SendChatMessage extends ChatSessionEvent {
  final String content;

  const SendChatMessage(this.content);

  @override
  List<Object?> get props => [content];
}

class ChatUserTyping extends ChatSessionEvent {
  const ChatUserTyping();
}

class ChatUserStoppedTyping extends ChatSessionEvent {
  const ChatUserStoppedTyping();
}

class HubMessageReceived extends ChatSessionEvent {
  final ChatMessageDto message;

  const HubMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class HubMessageEdited extends ChatSessionEvent {
  final ChatMessageDto message;

  const HubMessageEdited(this.message);

  @override
  List<Object?> get props => [message];
}

class HubMessageRead extends ChatSessionEvent {
  final String messageId;

  const HubMessageRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class HubTypingStarted extends ChatSessionEvent {
  final String userName;

  const HubTypingStarted(this.userName);

  @override
  List<Object?> get props => [userName];
}

class HubTypingStopped extends ChatSessionEvent {
  const HubTypingStopped();
}

class HubUserOnline extends ChatSessionEvent {
  const HubUserOnline();
}

class HubUserOffline extends ChatSessionEvent {
  const HubUserOffline();
}

class HubChatWindow extends ChatSessionEvent {
  final ChatAccessResponse access;

  const HubChatWindow(this.access);

  @override
  List<Object?> get props => [access];
}

class HubAccessDenied extends ChatSessionEvent {
  final String code;
  final String message;

  const HubAccessDenied({required this.code, this.message = ''});

  @override
  List<Object?> get props => [code, message];
}

class HubErrorReceived extends ChatSessionEvent {
  final String message;
  final String? code;

  const HubErrorReceived(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class ChatWindowTick extends ChatSessionEvent {
  const ChatWindowTick();
}

class ChatComposerLocked extends ChatSessionEvent {
  const ChatComposerLocked();
}

class LoadOlderChatMessages extends ChatSessionEvent {
  const LoadOlderChatMessages();
}

class MarkVisibleMessageRead extends ChatSessionEvent {
  final String messageId;

  const MarkVisibleMessageRead(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ChatAppLifecycleChanged extends ChatSessionEvent {
  final AppLifecycleState state;

  const ChatAppLifecycleChanged(this.state);

  @override
  List<Object?> get props => [state];
}

class EndChatSession extends ChatSessionEvent {
  const EndChatSession();
}

class HubMessageDeleted extends ChatSessionEvent {
  final String messageId;

  const HubMessageDeleted(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class HubMessageDelivered extends ChatSessionEvent {
  final String messageId;

  const HubMessageDelivered(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class HubConversationRead extends ChatSessionEvent {
  const HubConversationRead();
}

class HubReactionAdded extends ChatSessionEvent {
  final String messageId;
  final String emoji;
  final String userId;

  const HubReactionAdded({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });

  @override
  List<Object?> get props => [messageId, emoji, userId];
}

class HubReactionRemoved extends ChatSessionEvent {
  final String messageId;
  final String emoji;
  final String userId;

  const HubReactionRemoved({
    required this.messageId,
    required this.emoji,
    required this.userId,
  });

  @override
  List<Object?> get props => [messageId, emoji, userId];
}

class EditChatMessage extends ChatSessionEvent {
  final String messageId;
  final String content;

  const EditChatMessage({required this.messageId, required this.content});

  @override
  List<Object?> get props => [messageId, content];
}

class DeleteChatMessage extends ChatSessionEvent {
  final String messageId;

  const DeleteChatMessage(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class AddChatReaction extends ChatSessionEvent {
  final String messageId;
  final String emoji;

  const AddChatReaction({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class RemoveChatReaction extends ChatSessionEvent {
  final String messageId;
  final String emoji;

  const RemoveChatReaction({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class ToggleChatReaction extends ChatSessionEvent {
  final String messageId;
  final String emoji;

  const ToggleChatReaction({required this.messageId, required this.emoji});

  @override
  List<Object?> get props => [messageId, emoji];
}

class LoadConversationDetail extends ChatSessionEvent {
  const LoadConversationDetail();
}

class SearchChatMessages extends ChatSessionEvent {
  final String query;

  const SearchChatMessages(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearChatSearch extends ChatSessionEvent {
  const ClearChatSearch();
}
