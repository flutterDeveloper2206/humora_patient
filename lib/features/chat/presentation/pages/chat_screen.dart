import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/chat_inbox_bloc.dart';
import '../bloc/chat_inbox_event.dart';
import 'chat_inbox_page.dart';

/// Standalone `/chat` route and legacy export for home tab embedding.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ChatInboxBloc()..add(const LoadChatInbox()),
      child: const ChatInboxPage(embedded: false),
    );
  }
}

/// Embedded chat inbox for the home tab [IndexedStack].
typedef ChatView = ChatInboxPage;
