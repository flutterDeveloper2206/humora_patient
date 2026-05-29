import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(const ChatState()) {
    on<LoadChatHistory>(_onLoadChatHistory);
    on<SendMessage>(_onSendMessage);
    on<SendImageMessage>(_onSendImageMessage);
    on<ReceiveMessage>(_onReceiveMessage);
    on<ToggleTypingIndicator>(_onToggleTypingIndicator);
  }

  void _onLoadChatHistory(LoadChatHistory event, Emitter<ChatState> emit) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final messages = [
      ChatMessage(
        id: '1',
        text: 'Hi Dr. Liam',
        timestamp: today.add(const Duration(hours: 10, minutes: 10)),
        isMe: false, // Left
      ),
      ChatMessage(
        id: '2',
        text: 'Hi Abanop',
        timestamp: today.add(const Duration(hours: 10, minutes: 6)),
        isMe: true, // Right
      ),
      ChatMessage(
        id: '3',
        text: 'How i can help you today?',
        timestamp: today.add(const Duration(hours: 10, minutes: 6)),
        isMe: true, // Right
      ),
      ChatMessage(
        id: '4',
        text:
            'I\'ve been experiencing headache. Could you please advise me on what to do?',
        timestamp: today.add(const Duration(hours: 10, minutes: 10)),
        isMe: false, // Left
      ),
      ChatMessage(
        id: '5',
        text: 'Hi Abanop',
        timestamp: today.add(const Duration(hours: 10, minutes: 6)),
        isMe: true, // Right
      ),
      ChatMessage(
        id: '6',
        text: 'How i can help you today?',
        timestamp: today.add(const Duration(hours: 10, minutes: 6)),
        isMe: true, // Right
      ),
    ];

    emit(
      state.copyWith(
        messages: messages,
        isTyping: true, // As per DESIGN "Dr. Liam is Typing ...."
      ),
    );
  }

  void _onSendMessage(SendMessage event, Emitter<ChatState> emit) {
    if (event.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.text,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sent,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(newMessage);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onSendImageMessage(SendImageMessage event, Emitter<ChatState> emit) {
    if (event.imagePath.isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imageUrl: event.imagePath,
      timestamp: DateTime.now(),
      isMe: true,
      status: MessageStatus.sent,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(newMessage);
    emit(state.copyWith(messages: updatedMessages));
  }

  void _onReceiveMessage(ReceiveMessage event, Emitter<ChatState> emit) {
    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: event.text,
      timestamp: DateTime.now(),
      isMe: false,
    );

    final updatedMessages = List<ChatMessage>.from(state.messages)
      ..add(newMessage);
    emit(state.copyWith(messages: updatedMessages, isTyping: false));
  }

  void _onToggleTypingIndicator(
    ToggleTypingIndicator event,
    Emitter<ChatState> emit,
  ) {
    emit(state.copyWith(isTyping: event.isTyping));
  }
}
