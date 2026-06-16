import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../utils/session_manager.dart';
import 'signalr_logging.dart';

/// Builds + connects [HubConnection] instances using [signalr_netcore] ^1.4.4.
/// https://pub.dev/packages/signalr_netcore
///
/// JWT via [accessTokenFactory] (Authorization on negotiate + long-poll).
/// Do NOT append `access_token` to the hub URL on Flutter mobile — the library
/// sends Bearer on WebSocket upgrade; duplicating the token on the URL breaks
/// negotiate URL parsing and can confuse reverse proxies.
class SignalRConnectionHelper {
  SignalRConnectionHelper._();

  /// Auto/WebSockets first on native apps; LongPolling last (proxy fallback).
  static const List<_ConnAttempt> _connectionAttempts = [
    _ConnAttempt(transport: null),
    _ConnAttempt(transport: HttpTransportType.WebSockets),
    _ConnAttempt(transport: HttpTransportType.LongPolling),
  ];

  static const Duration _betweenAttemptDelay = Duration(milliseconds: 600);

  static String connectionLabel(HubConnectionState? state) {
    return switch (state) {
      HubConnectionState.Connected => 'CONNECTED',
      HubConnectionState.Connecting => 'CONNECTING',
      HubConnectionState.Reconnecting => 'RECONNECTING',
      HubConnectionState.Disconnecting => 'DISCONNECTING',
      HubConnectionState.Disconnected => 'DISCONNECTED',
      _ => 'DISCONNECTED',
    };
  }

  static String _transportLabel(HttpTransportType? transport) =>
      transport?.name ?? 'auto';

  static void logState({
    required String hubName,
    required String hubUrl,
    required HubConnectionState? state,
    required String action,
    Object? error,
  }) {
    final connected = state == HubConnectionState.Connected;
    final marker = connected ? '✅' : '❌';
    final buffer = StringBuffer()
      ..writeln('━━━━━━━━ SIGNALR [$hubName] ━━━━━━━━')
      ..writeln('$marker Socket: ${connectionLabel(state)}')
      ..writeln('   URL: $hubUrl')
      ..writeln('   Action: $action');
    if (error != null) {
      buffer.writeln('   Error: $error');
    }
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    developer.log(buffer.toString(), name: 'SignalRConnectionHelper');
  }

  static Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.trim().isEmpty) {
      throw StateError(
        'Not logged in — JWT access token is missing. Please log in again.',
      );
    }
    return token.trim();
  }

  /// Builds a single [HubConnection] for a given transport (no start()).
  static Future<HubConnection> buildConnection({
    required String hubUrl,
    required String hubName,
    HttpTransportType? transport,
  }) async {
    SignalRLogging.init();

    final options = HttpConnectionOptions(
      accessTokenFactory: () async => await _requireToken(),
      transport: transport,
      // null transport logger — signalr_netcore 1.4.4 crashes on GET requests
      // when finest logging casts null request.content to String.
      logger: null,
      logMessageContent: false,
      requestTimeout: 30000,
    );

    developer.log(
      '[$hubName] buildConnection url=$hubUrl transport=${_transportLabel(transport)}',
      name: 'SignalRConnectionHelper',
    );

    final connection = HubConnectionBuilder()
        .withUrl(hubUrl, options: options)
        .withAutomaticReconnect(retryDelays: [0, 2000, 5000, 10000, 30000])
        .configureLogging(SignalRLogging.hubLogger(hubName))
        .build();

    connection.serverTimeoutInMilliseconds = 120000;
    connection.keepAliveIntervalInMilliseconds = 15000;
    return connection;
  }

  /// Builds, wires handlers, and starts — trying each attempt until one succeeds.
  static Future<HubConnection> connectWithFallback({
    required String hubUrl,
    required String hubName,
    required void Function(HubConnection connection) registerHandlers,
  }) async {
    logState(
      hubName: hubName,
      hubUrl: hubUrl,
      state: HubConnectionState.Connecting,
      action: 'connectWithFallback() starting',
    );

    Object? lastError;
    for (var i = 0; i < _connectionAttempts.length; i++) {
      final attempt = _connectionAttempts[i];
      final label = attempt.label;
      HubConnection? connection;
      try {
        if (i > 0) {
          await Future.delayed(_betweenAttemptDelay);
        }
        developer.log(
          '[$hubName] trying: $label',
          name: 'SignalRConnectionHelper',
        );
        connection = await buildConnection(
          hubUrl: hubUrl,
          hubName: hubName,
          transport: attempt.transport,
        );
        registerHandlers(connection);
        await connection.start();

        logState(
          hubName: hubName,
          hubUrl: hubUrl,
          state: connection.state,
          action: 'connected via $label',
        );
        return connection;
      } catch (e, st) {
        lastError = e;
        logState(
          hubName: hubName,
          hubUrl: hubUrl,
          state: HubConnectionState.Disconnected,
          action: 'attempt $label failed',
          error: e,
        );
        developer.log(
          '[$hubName] attempt $label failed',
          name: 'SignalRConnectionHelper',
          error: e,
          stackTrace: st,
        );
        final conn = connection;
        if (conn != null &&
            conn.state != null &&
            conn.state != HubConnectionState.Disconnected) {
          try {
            await conn.stop();
          } catch (_) {}
          await Future.delayed(_betweenAttemptDelay);
        }
      }
    }

    throw lastError ??
        StateError('[$hubName] SignalR connection failed (all attempts).');
  }

  static String friendlyError(Object error) {
    final msg = error.toString();
    if (msg.contains('access token is missing') ||
        msg.contains('Not logged in')) {
      return 'Session expired. Please log in again.';
    }
    if (msg.contains('negotiate 401') || msg.contains('not Authorize')) {
      return 'Authentication failed. Please log in again.';
    }
    if (msg.contains('stopped before the hub handshake') ||
        msg.contains('before stop() was called') ||
        msg.contains('before the hub handshake could complete')) {
      return 'Live connection interrupted during setup. Retrying…';
    }
    if (msg.contains('not upgraded to websocket') ||
        msg.contains('HTTP status code: 200')) {
      return 'Live server WebSocket is unavailable (proxy config). '
          'Retrying with long polling…';
    }
    if (msg.contains('any of the available transports')) {
      return 'Could not connect to the live server. Check your network and '
          'make sure you are logged in.';
    }
    if (msg.contains('negotiate')) {
      return 'Live server rejected the connection. Please log in again.';
    }
    if (msg.contains('Server timeout elapsed')) {
      return 'Could not reach the server. Check your internet connection.';
    }
    if (msg.contains('requestTimeout') || msg.contains('Timeout')) {
      return 'Connection timed out. Check your network and try again.';
    }
    return msg;
  }
}

class _ConnAttempt {
  final HttpTransportType? transport;

  const _ConnAttempt({required this.transport});

  String get label => transport?.name ?? 'auto';
}
