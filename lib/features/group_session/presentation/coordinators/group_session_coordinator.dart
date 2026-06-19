import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/notifications/session_hub_service.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../my_sessions/data/datasource/my_sessions_api_service.dart';
import '../../data/group_session_remote_end_bus.dart';
import '../../data/models/group_session_hub_models.dart';
import '../../../../routes/app_router.dart';

/// Patient group session hub listener — auto-join on start, end on server events.
class GroupSessionCoordinator extends StatefulWidget {
  final Widget child;

  const GroupSessionCoordinator({super.key, required this.child});

  @override
  State<GroupSessionCoordinator> createState() =>
      _GroupSessionCoordinatorState();
}

class _GroupSessionCoordinatorState extends State<GroupSessionCoordinator> {
  StreamSubscription<GroupSessionStartedPayload>? _startedSub;
  StreamSubscription<GroupSessionEndedPayload>? _endedSub;
  StreamSubscription<GroupSessionAutoDisconnectedPayload>? _autoDisconnectSub;
  String? _activeGroupBookingId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindHub());
  }

  void _bindHub() {
    final hub = SessionHubService.instance;
    _startedSub = hub.groupSessionStarted.listen(_onGroupSessionStarted);
    _endedSub = hub.groupSessionEnded.listen(_onGroupSessionEnded);
    _autoDisconnectSub =
        hub.groupSessionAutoDisconnected.listen(_onAutoDisconnected);
  }

  Future<void> _onGroupSessionStarted(GroupSessionStartedPayload payload) async {
    if (payload.bookingId.isEmpty) return;

    developer.log(
      'GroupSessionStarted → bookingId=${payload.bookingId} '
      'channel=${payload.channelName}',
      name: 'GroupSessionCoordinator',
    );

    final nav = AppRouter.rootNavigatorKey.currentState;
    if (nav == null) return;

    final currentRoute = ModalRoute.of(nav.context)?.settings.name;
    if (currentRoute == '/group-session' &&
        _activeGroupBookingId == payload.bookingId) {
      return;
    }

    String healerName = 'Healer';
    try {
      final booking = await MySessionsApiService()
          .fetchBookingDetail(payload.bookingId);
      if (booking.healerName.trim().isNotEmpty) {
        healerName = booking.healerName.trim();
      }
    } catch (e) {
      developer.log(
        'GroupSessionStarted → booking detail fallback: $e',
        name: 'GroupSessionCoordinator',
      );
    }

    if (!nav.mounted) return;

    _activeGroupBookingId = payload.bookingId;
    nav.context.push(
      '/group-session',
      extra: CallRouteArgs(
        bookingId: payload.bookingId,
        healerName: healerName,
        mode: CallMode.group,
      ),
    );
  }

  void _onGroupSessionEnded(GroupSessionEndedPayload payload) {
    _dispatchRemoteEnd(
      bookingId: payload.bookingId,
      summary: payload,
      reason: 'ended',
    );
  }

  void _onAutoDisconnected(GroupSessionAutoDisconnectedPayload payload) {
    _dispatchRemoteEnd(
      bookingId: payload.bookingId,
      summary: null,
      reason: 'auto_disconnected',
    );
  }

  void _dispatchRemoteEnd({
    required String bookingId,
    GroupSessionEndedPayload? summary,
    required String reason,
  }) {
    if (bookingId.isEmpty) return;
    developer.log(
      'Group session remote end ($reason) → bookingId=$bookingId',
      name: 'GroupSessionCoordinator',
    );

    GroupSessionRemoteEndBus.instance.notify(
      GroupSessionRemoteEnd(
        bookingId: bookingId,
        summary: summary,
        isAutoDisconnected: reason == 'auto_disconnected',
      ),
    );

    if (_activeGroupBookingId != null &&
        _activeGroupBookingId!.trim().toLowerCase() ==
            bookingId.trim().toLowerCase()) {
      _activeGroupBookingId = null;
    }
  }

  @override
  void dispose() {
    _startedSub?.cancel();
    _endedSub?.cancel();
    _autoDisconnectSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
