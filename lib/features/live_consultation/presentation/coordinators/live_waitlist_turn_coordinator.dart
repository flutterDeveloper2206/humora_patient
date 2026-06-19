import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';

import '../../../../routes/app_router.dart';
import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';
import '../widgets/waitlist_your_turn_dialog.dart';

/// Shows a global accept/reject popup when [WaitlistYourTurn] fires anywhere in the app.
class LiveWaitlistTurnCoordinator extends StatefulWidget {
  final Widget child;

  const LiveWaitlistTurnCoordinator({super.key, required this.child});

  @override
  State<LiveWaitlistTurnCoordinator> createState() =>
      _LiveWaitlistTurnCoordinatorState();
}

class _LiveWaitlistTurnCoordinatorState
    extends State<LiveWaitlistTurnCoordinator> {
  StreamSubscription<WaitlistYourTurnPayload>? _yourTurnSub;
  StreamSubscription<WaitlistTurnExpiredPayload>? _expiredSub;
  bool _dialogVisible = false;
  String? _activeWaitlistId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bindHub());
  }

  void _bindHub() {
    final hub = LiveHubService.instance;
    _yourTurnSub = hub.waitlistYourTurn.listen(_onYourTurn);
    _expiredSub = hub.waitlistTurnExpired.listen(_onTurnExpired);
  }

  void _onYourTurn(WaitlistYourTurnPayload payload) {
    if (payload.waitlistId.isEmpty) return;
    developer.log(
      'WaitlistYourTurn → waitlistId=${payload.waitlistId} '
      'healerId=${payload.healerId}',
      name: 'LiveWaitlistTurnCoordinator',
    );
    _presentDialog(payload);
  }

  void _onTurnExpired(WaitlistTurnExpiredPayload payload) {
    developer.log(
      'WaitlistTurnExpired → waitlistId=${payload.waitlistId}',
      name: 'LiveWaitlistTurnCoordinator',
    );
    if (_activeWaitlistId == null || _activeWaitlistId != payload.waitlistId) {
      return;
    }
    _dismissDialog();
  }

  void _presentDialog(WaitlistYourTurnPayload payload) {
    if (_dialogVisible && _activeWaitlistId == payload.waitlistId) return;
    if (_dialogVisible) {
      _dismissDialog();
    }

    final nav = AppRouter.rootNavigatorKey.currentState;
    if (nav == null) return;
    final context = nav.context;
    if (!context.mounted) return;

    _dialogVisible = true;
    _activeWaitlistId = payload.waitlistId;

    WaitlistYourTurnDialog.show(
      context: context,
      payload: payload,
      onReject: () {},
      onExpired: () {},
    ).whenComplete(() {
      _dialogVisible = false;
      _activeWaitlistId = null;
    });
  }

  void _dismissDialog() {
    if (!_dialogVisible) return;
    final nav = AppRouter.rootNavigatorKey.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    _dialogVisible = false;
    _activeWaitlistId = null;
  }

  @override
  void dispose() {
    _yourTurnSub?.cancel();
    _expiredSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
