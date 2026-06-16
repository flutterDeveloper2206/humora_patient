import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/signalr_connection_helper.dart';
import '../../../../core/network/signalr_logging.dart';
import '../models/live_models.dart';

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

/// Singleton SignalR client for `/hubs/live` via [signalr_netcore].
class LiveHubService {
  LiveHubService._();
  static final LiveHubService instance = LiveHubService._();

  static const _hubName = 'live';

  HubConnection? _connection;
  String? _activeBookingId;
  Future<void>? _connectInFlight;
  int _connectGeneration = 0;

  final _requestAccepted =
      StreamController<RequestAcceptedPayload>.broadcast();
  final _requestRejected = StreamController<Map<String, dynamic>>.broadcast();
  final _requestExpired = StreamController<Map<String, dynamic>>.broadcast();
  final _billingCycle = StreamController<BillingCyclePayload>.broadcast();
  final _lowBalance = StreamController<LowBalanceWarningPayload>.broadcast();
  final _sessionEnded = StreamController<SessionEndedSummary>.broadcast();
  final _healerStatusChanged =
      StreamController<HealerStatusChangedPayload>.broadcast();
  final _hubError = StreamController<String>.broadcast();
  final _connectionState = StreamController<HubConnectionState>.broadcast();

  Stream<RequestAcceptedPayload> get requestAccepted => _requestAccepted.stream;
  Stream<Map<String, dynamic>> get requestRejected => _requestRejected.stream;
  Stream<Map<String, dynamic>> get requestExpired => _requestExpired.stream;
  Stream<BillingCyclePayload> get billingCycle => _billingCycle.stream;
  Stream<LowBalanceWarningPayload> get lowBalanceWarning => _lowBalance.stream;
  Stream<SessionEndedSummary> get sessionEnded => _sessionEnded.stream;
  Stream<HealerStatusChangedPayload> get healerStatusChanged =>
      _healerStatusChanged.stream;
  Stream<String> get hubError => _hubError.stream;
  Stream<HubConnectionState> get connectionState => _connectionState.stream;

  HubConnectionState get state =>
      _connection?.state ?? HubConnectionState.Disconnected;

  String? get activeBookingId => _activeBookingId;

  bool get isConnected => state == HubConnectionState.Connected;

  static String connectionLabel(HubConnectionState hubState) =>
      SignalRConnectionHelper.connectionLabel(hubState);

  void _log(String message) {
    developer.log(message, name: 'LiveHubService');
  }

  void _logState(String action, {Object? error}) {
    SignalRConnectionHelper.logState(
      hubName: _hubName,
      hubUrl: ApiEndpoints.liveHubUrl,
      state: state,
      action: action,
      error: error,
    );
  }

  Future<void> connect() async {
    if (_connection?.state == HubConnectionState.Connected) {
      _logState('connect() skipped — already connected');
      return;
    }

    final existing = _connection;
    if (existing != null) {
      final existingState = existing.state;
      if (existingState == HubConnectionState.Connecting ||
          existingState == HubConnectionState.Reconnecting) {
        _log(
          'connect() waiting — hub already '
          '${connectionLabel(existingState ?? HubConnectionState.Disconnected)}',
        );
        final settled = await _waitForConnectionSettle(existing);
        if (settled == HubConnectionState.Connected) {
          _logState('connect() satisfied — hub connected while waiting');
          return;
        }
        if (existing.state == HubConnectionState.Reconnecting) {
          _logState('connect() skipped — hub still reconnecting');
          return;
        }
      }
      if (existing.state == HubConnectionState.Connected) {
        _logState('connect() skipped — already connected');
        return;
      }
    }

    if (_connectInFlight != null) {
      _log('connect() waiting — connection already in progress');
      return _connectInFlight!;
    }

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

  Future<HubConnectionState?> _waitForConnectionSettle(
    HubConnection connection, {
    Duration timeout = const Duration(seconds: 45),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      final state = connection.state;
      if (state == HubConnectionState.Connected ||
          state == HubConnectionState.Disconnected) {
        return state;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return connection.state;
  }

  Future<void> _connectInternal() async {
    final generation = ++_connectGeneration;
    _logState('connect() starting (gen=$generation)');

    final existing = _connection;
    if (existing != null &&
        existing.state != HubConnectionState.Disconnected) {
      try {
        await existing.stop();
      } catch (_) {}
      if (generation != _connectGeneration) return;
    }
    _connection = null;

    Object? lastError;
    for (var pass = 0; pass < 2; pass++) {
      if (generation != _connectGeneration) return;
      if (pass > 0) {
        _log('connect() retry pass ${pass + 1} after delay');
        await Future.delayed(const Duration(milliseconds: 900));
        if (generation != _connectGeneration) return;
      }

      try {
        final hub = await SignalRConnectionHelper.connectWithFallback(
          hubUrl: ApiEndpoints.liveHubUrl,
          hubName: _hubName,
          registerHandlers: _registerHandlers,
        );
        if (generation != _connectGeneration) {
          try {
            await hub.stop();
          } catch (_) {}
          return;
        }
        _connection = hub;
        _connectionState.add(HubConnectionState.Connected);
        _logState('connect() success — hub.start() complete');
        return;
      } catch (e) {
        lastError = e;
        _connectionState.add(HubConnectionState.Disconnected);
        _logState('connect() pass ${pass + 1} failed', error: e);
      }
    }

    throw lastError ?? StateError('Live hub connection failed');
  }

  void _registerHandlers(HubConnection connection) {
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'RequestAccepted',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _requestAccepted.add(RequestAcceptedPayload.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'RequestRejected',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _requestRejected.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'RequestExpired',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _requestExpired.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'BillingCycle',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _billingCycle.add(BillingCyclePayload.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'LowBalanceWarning',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _lowBalance.add(LowBalanceWarningPayload.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'LowBalance',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _lowBalance.add(LowBalanceWarningPayload.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'SessionEnded',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _sessionEnded.add(SessionEndedSummary.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'HealerStatusChanged',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _healerStatusChanged.add(
          HealerStatusChangedPayload.fromJson(_asMap(args[0])),
        );
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'Error',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        final map = _asMap(args[0]);
        _hubError.add(map['message']?.toString() ?? 'Live hub error');
      },
    );

    connection.onreconnecting(({error}) {
      SignalREventLogger.logIncoming(
        hubName: _hubName,
        eventName: 'onreconnecting',
        extra: error,
      );
      _connectionState.add(HubConnectionState.Reconnecting);
      _logState('onreconnecting', error: error);
    });
    connection.onreconnected(({connectionId}) async {
      SignalREventLogger.logIncoming(
        hubName: _hubName,
        eventName: 'onreconnected',
        extra: 'connectionId=$connectionId',
      );
      _connectionState.add(HubConnectionState.Connected);
      _logState('onreconnected (connectionId: $connectionId)');
      if (_activeBookingId != null) {
        await joinSession(_activeBookingId!);
      }
    });
    connection.onclose(({error}) {
      SignalREventLogger.logIncoming(
        hubName: _hubName,
        eventName: 'onclose',
        extra: error,
      );
      _connectionState.add(HubConnectionState.Disconnected);
      _logState('onclose', error: error);
    });
  }

  Future<void> _invoke(String method, {List<Object>? args}) async {
    final conn = _connection;
    if (conn == null || conn.state != HubConnectionState.Connected) {
      throw StateError('Live hub not connected — cannot invoke $method');
    }
    await SignalREventLogger.invoke(
      conn,
      hubName: _hubName,
      method: method,
      args: args,
    );
  }

  Future<void> joinSession(String bookingId) async {
    if (_activeBookingId == bookingId &&
        _connection?.state == HubConnectionState.Connected) {
      _log('joinSession($bookingId) skipped — already joined');
      return;
    }
    _activeBookingId = bookingId;
    if (_connection?.state != HubConnectionState.Connected) {
      await connect();
    }
    _log('📤 Invoke JoinSession → bookingId=$bookingId');
    await _invoke('JoinSession', args: [bookingId]);
    _logState('joinSession($bookingId) invoked');
  }

  Future<void> leaveSession(String bookingId) async {
    _log('📤 Invoke LeaveSession → bookingId=$bookingId');
    if (_connection?.state == HubConnectionState.Connected) {
      await _invoke('LeaveSession', args: [bookingId]);
    }
    if (_activeBookingId == bookingId) {
      _activeBookingId = null;
    }
    _logState('leaveSession($bookingId) done');
  }

  Future<void> rejoinActiveSessionIfNeeded() async {
    final bookingId = _activeBookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    try {
      await joinSession(bookingId);
    } catch (e) {
      _logState('rejoinActiveSessionIfNeeded failed', error: e);
    }
  }

  /// Stops the socket but keeps [activeBookingId] for resume re-join.
  Future<void> suspend() async {
    _logState('suspend() starting');
    ++_connectGeneration;
    final conn = _connection;
    _connection = null;
    if (conn != null) {
      try {
        await conn.stop();
      } catch (_) {}
    }
    _connectionState.add(HubConnectionState.Disconnected);
    _logState('suspend() done — activeBookingId preserved');
  }

  Future<void> disconnect() async {
    _logState('disconnect() starting');
    _activeBookingId = null;
    await suspend();
    _logState('disconnect() done');
  }
}
