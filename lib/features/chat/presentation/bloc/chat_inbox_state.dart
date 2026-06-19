import 'package:equatable/equatable.dart';

import '../../data/models/chat_models.dart';

abstract class ChatInboxState extends Equatable {
  const ChatInboxState();

  @override
  List<Object?> get props => [];
}

class ChatInboxInitial extends ChatInboxState {}

class ChatInboxLoading extends ChatInboxState {}

class ChatInboxLoaded extends ChatInboxState {
  final List<ChatInboxEntryDto> conversations;
  final bool isRefreshing;

  const ChatInboxLoaded({
    required this.conversations,
    this.isRefreshing = false,
  });

  bool get isEmpty => conversations.isEmpty;

  ChatInboxLoaded copyWith({
    List<ChatInboxEntryDto>? conversations,
    bool? isRefreshing,
  }) {
    return ChatInboxLoaded(
      conversations: conversations ?? this.conversations,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [conversations, isRefreshing];
}

class ChatInboxError extends ChatInboxState {
  final String message;

  const ChatInboxError(this.message);

  @override
  List<Object?> get props => [message];
}
