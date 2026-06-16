import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import '../utils/session_manager.dart';
import '../../features/chat/data/datasource/chat_hub_service.dart';
import '../../features/live_consultation/data/datasource/live_hub_service.dart';

/// Keeps SignalR hubs connected while the app is in the foreground and
/// suspends them when the app moves to the background.
class AppHubLifecycle extends StatefulWidget {
  final Widget child;

  const AppHubLifecycle({super.key, required this.child});

  @override
  State<AppHubLifecycle> createState() => _AppHubLifecycleState();
}

class _AppHubLifecycleState extends State<AppHubLifecycle>
    with WidgetsBindingObserver {
  bool _backgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _connectHubs(rejoinSessions: false);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (_backgrounded) {
          _backgrounded = false;
          _connectHubs(rejoinSessions: true);
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
        if (!_backgrounded) {
          _backgrounded = true;
          _suspendHubs();
        }
        break;
      case AppLifecycleState.inactive:
        // Transitional (dialogs, control center) — keep sockets alive.
        break;
    }
  }

  Future<void> _connectHubs({required bool rejoinSessions}) async {
    final token = await SessionManager.getToken();
    if (token == null || token.trim().isEmpty) return;

    try {
      await LiveHubService.instance.connect();
      if (rejoinSessions) {
        await LiveHubService.instance.rejoinActiveSessionIfNeeded();
      }
      developer.log(
        'AppHubLifecycle → live hub '
        '${LiveHubService.connectionLabel(LiveHubService.instance.state)}',
        name: 'AppHubLifecycle',
      );
    } catch (e) {
      developer.log(
        'AppHubLifecycle → live hub connect failed: $e',
        name: 'AppHubLifecycle',
      );
    }

    if (rejoinSessions) {
      try {
        await ChatHubService.instance.rejoinActiveChatIfNeeded();
      } catch (e) {
        developer.log(
          'AppHubLifecycle → chat hub rejoin failed: $e',
          name: 'AppHubLifecycle',
        );
      }
    }
  }

  Future<void> _suspendHubs() async {
    developer.log('AppHubLifecycle → suspending hubs', name: 'AppHubLifecycle');
    await Future.wait([
      LiveHubService.instance.suspend(),
      ChatHubService.instance.suspend(),
    ]);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
