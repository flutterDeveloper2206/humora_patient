import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../constants/api_endpoints.dart';
import '../network/signalr_connection_helper.dart';
import '../network/signalr_logging.dart';
import 'notification_badge_controller.dart';
import 'notification_screen.dart';
import '../../features/group_session/data/models/group_session_hub_models.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

class SessionReminderPayload {
  final String bookingId;
  final String? scheduledTime;
  final int minutesBefore;
  final String message;
  final String screen;

  const SessionReminderPayload({
    required this.bookingId,
    this.scheduledTime,
    required this.minutesBefore,
    required this.message,
    required this.screen,
  });

  factory SessionReminderPayload.fromJson(Map<String, dynamic> json) {
    return SessionReminderPayload(
      bookingId: json['bookingId']?.toString() ?? '',
      scheduledTime: json['scheduledTime']?.toString(),
      minutesBefore: (json['minutesBefore'] as num?)?.toInt() ?? 0,
      message: json['message']?.toString() ?? 'Your session is coming up soon',
      screen: NotificationScreen.normalize(json['screen']?.toString()),
    );
  }
}

/// SignalR hub `/hubs/session` — badge count + session reminders.
class SessionHubService {
  SessionHubService._();
  static final SessionHubService instance = SessionHubService._();

  static const _hubName = 'session';

  HubConnection? _connection;
  Future<void>? _connectInFlight;

  final _sessionReminder =
      StreamController<SessionReminderPayload>.broadcast();
  final _groupSessionStarted =
      StreamController<GroupSessionStartedPayload>.broadcast();
  final _groupSessionEnded =
      StreamController<GroupSessionEndedPayload>.broadcast();
  final _groupSessionAutoDisconnected =
      StreamController<GroupSessionAutoDisconnectedPayload>.broadcast();
  final _connectionState = StreamController<HubConnectionState>.broadcast();

  Stream<SessionReminderPayload> get sessionReminder => _sessionReminder.stream;
  Stream<GroupSessionStartedPayload> get groupSessionStarted =>
      _groupSessionStarted.stream;
  Stream<GroupSessionEndedPayload> get groupSessionEnded =>
      _groupSessionEnded.stream;
  Stream<GroupSessionAutoDisconnectedPayload> get groupSessionAutoDisconnected =>
      _groupSessionAutoDisconnected.stream;
  Stream<HubConnectionState> get connectionState => _connectionState.stream;

  HubConnectionState get state =>
      _connection?.state ?? HubConnectionState.Disconnected;

  bool get isConnected => state == HubConnectionState.Connected;

  Future<void> connect() async {
    if (_connection?.state == HubConnectionState.Connected) return;
    if (_connectInFlight != null) return _connectInFlight!;

    final op = _connectInternal();
    _connectInFlight = op;
    try {
      await op;
    } finally {
      if (identical(_connectInFlight, op)) {
        _connectInFlight = null;
      }
    }
  }

  Future<void> _connectInternal() async {
    final existing = _connection;
    if (existing != null && existing.state != HubConnectionState.Disconnected) {
      try {
        await existing.stop();
      } catch (_) {}
    }
    _connection = null;

    final hub = await SignalRConnectionHelper.connectWithFallback(
      hubUrl: ApiEndpoints.sessionHubUrl,
      hubName: _hubName,
      registerHandlers: _registerHandlers,
    );
    _connection = hub;
    _connectionState.add(HubConnectionState.Connected);
    developer.log('Session hub connected', name: 'SessionHubService');
  }

  void _registerHandlers(HubConnection connection) {
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'NotificationCount',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        final map = _asMap(args[0]);
        final count = (map['count'] as num?)?.toInt() ?? 0;
        NotificationBadgeController.instance.setCount(count);
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'SessionReminder',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _sessionReminder.add(SessionReminderPayload.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'GroupSessionStarted',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _groupSessionStarted.add(
          GroupSessionStartedPayload.fromJson(_asMap(args[0])),
        );
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'GroupSessionEnded',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _groupSessionEnded.add(
          GroupSessionEndedPayload.fromJson(_asMap(args[0])),
        );
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'AutoDisconnected',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _groupSessionAutoDisconnected.add(
          GroupSessionAutoDisconnectedPayload.fromJson(_asMap(args[0])),
        );
      },
    );
  }

  Future<void> disconnect() async {
    final connection = _connection;
    _connection = null;
    if (connection != null) {
      try {
        await connection.stop();
      } catch (_) {}
    }
    _connectionState.add(HubConnectionState.Disconnected);
  }
}
