import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import '../utils/session_manager.dart';
import '../notifications/notification_badge_controller.dart';
import '../notifications/session_hub_service.dart';
import '../../features/chat/data/datasource/chat_hub_service.dart';
import '../../features/group_session/presentation/coordinators/group_session_coordinator.dart';
import '../../features/live_consultation/data/datasource/live_hub_service.dart';
import '../../features/live_consultation/presentation/coordinators/live_waitlist_turn_coordinator.dart';

/// Keeps SignalR hubs connected from app start until app close.
class AppHubLifecycle extends StatefulWidget {
  final Widget child;

  const AppHubLifecycle({super.key, required this.child});

  @override
  State<AppHubLifecycle> createState() => _AppHubLifecycleState();
}

class _AppHubLifecycleState extends State<AppHubLifecycle>
    with WidgetsBindingObserver {
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
        _connectHubs(rejoinSessions: true);
        NotificationBadgeController.instance.refreshUnreadCount();
        break;
      case AppLifecycleState.detached:
        _disconnectHubs();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.inactive:
        break;
    }
  }

  Future<void> _connectHubs({required bool rejoinSessions}) async {
    final token = await SessionManager.getToken();
    if (token == null || token.trim().isEmpty) return;

    await NotificationBadgeController.instance.refreshUnreadCount();

    try {
      await SessionHubService.instance.connect();
      developer.log(
        'AppHubLifecycle → session hub connected',
        name: 'AppHubLifecycle',
      );
    } catch (e) {
      developer.log(
        'AppHubLifecycle → session hub connect failed: $e',
        name: 'AppHubLifecycle',
      );
    }

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

    try {
      await ChatHubService.instance.connect();
      developer.log(
        'AppHubLifecycle → chat hub '
        '${ChatHubService.instance.state.name}',
        name: 'AppHubLifecycle',
      );
    } catch (e) {
      developer.log(
        'AppHubLifecycle → chat hub connect failed: $e',
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

  Future<void> _disconnectHubs() async {
    developer.log(
      'AppHubLifecycle → disconnecting hubs',
      name: 'AppHubLifecycle',
    );
    await Future.wait([
      SessionHubService.instance.disconnect(),
      LiveHubService.instance.disconnect(),
      ChatHubService.instance.disconnect(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return GroupSessionCoordinator(
      child: LiveWaitlistTurnCoordinator(child: widget.child),
    );
  }
}
