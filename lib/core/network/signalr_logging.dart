import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:signalr_netcore/signalr_client.dart';

/// Configures [logging] for [signalr_netcore] hub + transport loggers.
/// See https://pub.dev/packages/signalr_netcore
class SignalRLogging {
  SignalRLogging._();

  static bool _initialized = false;

  static void init({bool enabled = kDebugMode}) {
    if (_initialized || !enabled) return;
    _initialized = true;

    // IMPORTANT: Do NOT use Level.ALL. signalr_netcore 1.4.4 throws while
    // logging at FINER/FINEST because it casts a null request body to String
    // on GET/negotiate/long-polling requests, which aborts the connection.
    hierarchicalLoggingEnabled = true;
    Logger.root.level = Level.WARNING;
    Logger.root.onRecord.listen((rec) {
      developer.log(
        rec.message,
        name: rec.loggerName,
        level: _mapLevel(rec.level),
      );
    });
  }

  static int _mapLevel(Level level) {
    if (level >= Level.SEVERE) return 1000;
    if (level >= Level.WARNING) return 900;
    if (level >= Level.INFO) return 800;
    return 500;
  }

  /// Child loggers inherit [Logger.root.level] — do not set `.level` here
  /// (requires hierarchicalLoggingEnabled and throws otherwise).
  static Logger hubLogger(String hubName) => Logger('SignalR-hub-$hubName');

  static Logger transportLogger(String hubName) =>
      Logger('SignalR-transport-$hubName');
}

/// Debug console logging for SignalR hub events + invoke request/response.
class SignalREventLogger {
  SignalREventLogger._();

  static bool get enabled => kDebugMode;

  static void logIncoming({
    required String hubName,
    required String eventName,
    List<Object?>? args,
    Object? extra,
  }) {
    if (!enabled) return;
    final payload = formatPayload(args);
    final line =
        '[SignalR][$hubName] ◀ EVENT $eventName\n  payload: $payload'
        '${extra != null ? '\n  extra: $extra' : ''}';
    debugPrint(line);
    developer.log(line, name: 'SignalR-$hubName');
  }

  static void logOutgoingInvoke({
    required String hubName,
    required String method,
    List<Object>? args,
  }) {
    if (!enabled) return;
    final payload = formatPayload(args);
    final line =
        '[SignalR][$hubName] ▶ INVOKE $method\n  request: $payload';
    debugPrint(line);
    developer.log(line, name: 'SignalR-$hubName');
  }

  static void logInvokeResponse({
    required String hubName,
    required String method,
    Object? response,
    Object? error,
  }) {
    if (!enabled) return;
    if (error != null) {
      final line =
          '[SignalR][$hubName] ✖ INVOKE $method FAILED\n  error: $error';
      debugPrint(line);
      developer.log(line, name: 'SignalR-$hubName', error: error);
      return;
    }
    final line =
        '[SignalR][$hubName] ✔ INVOKE $method OK\n  response: ${formatValue(response)}';
    debugPrint(line);
    developer.log(line, name: 'SignalR-$hubName');
  }

  static void on(
    HubConnection connection, {
    required String hubName,
    required String eventName,
    required void Function(List<Object?>? args) handler,
  }) {
    connection.on(eventName, (args) {
      logIncoming(hubName: hubName, eventName: eventName, args: args);
      handler(args);
    });
  }

  static Future<Object?> invoke(
    HubConnection connection, {
    required String hubName,
    required String method,
    List<Object>? args,
  }) async {
    logOutgoingInvoke(hubName: hubName, method: method, args: args);
    try {
      final result = args != null
          ? await connection.invoke(method, args: args)
          : await connection.invoke(method);
      logInvokeResponse(
        hubName: hubName,
        method: method,
        response: result,
      );
      return result;
    } catch (e, st) {
      logInvokeResponse(hubName: hubName, method: method, error: e);
      Error.throwWithStackTrace(e, st);
    }
  }

  static String formatPayload(List<Object?>? args) {
    if (args == null || args.isEmpty) return '<empty>';
    try {
      return const JsonEncoder.withIndent('  ').convert(
        args.map(formatValue).toList(),
      );
    } catch (_) {
      return args.toString();
    }
  }

  static dynamic formatValue(Object? value) {
    if (value == null) return null;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    if (value is List) {
      return value.map(formatValue).toList();
    }
    if (value is String || value is num || value is bool) return value;
    return value.toString();
  }
}
