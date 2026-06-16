import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:signalr_netcore/signalr_client.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/signalr_connection_helper.dart';
import '../../../../core/network/signalr_logging.dart';
import '../models/chat_models.dart';

class ChatHubError {
  final String message;
  final String? code;

  const ChatHubError(this.message, {this.code});
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is Map) return Map<String, dynamic>.from(decoded);
  }
  return {};
}

/// Singleton SignalR client for `/hubs/chat` via [signalr_netcore].
/// ChatFlow: connect → JoinChat only when [canWrite]; re-JoinChat on reconnect.
class ChatHubService {
  ChatHubService._();
  static final ChatHubService instance = ChatHubService._();

  static const _hubName = 'chat';

  HubConnection? _connection;
  String? _activeBookingId;
  Future<void>? _connectInFlight;
  int _connectGeneration = 0;
  Timer? _heartbeatTimer;

  final _messageSent = StreamController<ChatMessageDto>.broadcast();
  final _messageEdited = StreamController<ChatMessageDto>.broadcast();
  final _messageDeleted = StreamController<Map<String, dynamic>>.broadcast();
  final _messageDelivered = StreamController<Map<String, dynamic>>.broadcast();
  final _messageRead = StreamController<Map<String, dynamic>>.broadcast();
  final _conversationRead = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionAdded = StreamController<Map<String, dynamic>>.broadcast();
  final _reactionRemoved = StreamController<Map<String, dynamic>>.broadcast();
  final _typingStarted = StreamController<Map<String, dynamic>>.broadcast();
  final _typingStopped = StreamController<Map<String, dynamic>>.broadcast();
  final _userOnline = StreamController<Map<String, dynamic>>.broadcast();
  final _userOffline = StreamController<Map<String, dynamic>>.broadcast();
  final _chatWindow = StreamController<Map<String, dynamic>>.broadcast();
  final _chatAccessDenied = StreamController<Map<String, dynamic>>.broadcast();
  final _hubError = StreamController<ChatHubError>.broadcast();
  final _connectionState = StreamController<HubConnectionState>.broadcast();

  Stream<ChatMessageDto> get messageSent => _messageSent.stream;
  Stream<ChatMessageDto> get messageEdited => _messageEdited.stream;
  Stream<Map<String, dynamic>> get messageDeleted => _messageDeleted.stream;
  Stream<Map<String, dynamic>> get messageDelivered => _messageDelivered.stream;
  Stream<Map<String, dynamic>> get messageRead => _messageRead.stream;
  Stream<Map<String, dynamic>> get conversationRead => _conversationRead.stream;
  Stream<Map<String, dynamic>> get reactionAdded => _reactionAdded.stream;
  Stream<Map<String, dynamic>> get reactionRemoved => _reactionRemoved.stream;
  Stream<Map<String, dynamic>> get typingStarted => _typingStarted.stream;
  Stream<Map<String, dynamic>> get typingStopped => _typingStopped.stream;
  Stream<Map<String, dynamic>> get userOnline => _userOnline.stream;
  Stream<Map<String, dynamic>> get userOffline => _userOffline.stream;
  Stream<Map<String, dynamic>> get chatWindow => _chatWindow.stream;
  Stream<Map<String, dynamic>> get chatAccessDenied => _chatAccessDenied.stream;
  Stream<ChatHubError> get hubError => _hubError.stream;
  Stream<HubConnectionState> get connectionState => _connectionState.stream;

  HubConnectionState get state =>
      _connection?.state ?? HubConnectionState.Disconnected;

  bool get isConnected => state == HubConnectionState.Connected;
  String? get activeBookingId => _activeBookingId;

  void _log(String message) {
    developer.log(message, name: 'ChatHubService');
  }

  void _logState(String action, {Object? error}) {
    SignalRConnectionHelper.logState(
      hubName: _hubName,
      hubUrl: ApiEndpoints.chatHubUrl,
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
        final settled = await _waitForConnectionSettle(existing);
        if (settled == HubConnectionState.Connected) return;
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
      final hubState = connection.state;
      if (hubState == HubConnectionState.Connected ||
          hubState == HubConnectionState.Disconnected) {
        return hubState;
      }
      await Future.delayed(const Duration(milliseconds: 250));
    }
    return connection.state;
  }

  Future<void> _connectInternal() async {
    final generation = ++_connectGeneration;
    _logState('connect() starting (gen=$generation)');

    final existing = _connection;
    if (existing != null && existing.state != HubConnectionState.Disconnected) {
      try {
        await existing.stop();
      } catch (_) {}
      if (generation != _connectGeneration) return;
    }
    _connection = null;
    _stopHeartbeat();

    Object? lastError;
    for (var pass = 0; pass < 2; pass++) {
      if (generation != _connectGeneration) return;
      if (pass > 0) {
        await Future.delayed(const Duration(milliseconds: 900));
        if (generation != _connectGeneration) return;
      }

      try {
        final hub = await SignalRConnectionHelper.connectWithFallback(
          hubUrl: ApiEndpoints.chatHubUrl,
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

    throw lastError ?? StateError('Chat hub connection failed');
  }

  void _registerHandlers(HubConnection connection) {
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'MessageSent',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _messageSent.add(ChatMessageDto.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'MessageEdited',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _messageEdited.add(ChatMessageDto.fromJson(_asMap(args[0])));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'MessageDeleted',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _messageDeleted.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'MessageDelivered',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _messageDelivered.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'MessageRead',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _messageRead.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'ConversationRead',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _conversationRead.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'ReactionAdded',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _reactionAdded.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'ReactionRemoved',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _reactionRemoved.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'TypingStarted',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _typingStarted.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'TypingStopped',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _typingStopped.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'UserOnline',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _userOnline.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'UserOffline',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _userOffline.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'ChatWindow',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _chatWindow.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'ChatAccessDenied',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        _chatAccessDenied.add(_asMap(args[0]));
      },
    );
    SignalREventLogger.on(
      connection,
      hubName: _hubName,
      eventName: 'Error',
      handler: (args) {
        if (args == null || args.isEmpty) return;
        final map = _asMap(args[0]);
        _hubError.add(
          ChatHubError(
            map['message']?.toString() ?? 'Chat hub error',
            code: map['code']?.toString(),
          ),
        );
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
      final bookingId = _activeBookingId;
      if (bookingId != null) {
        try {
          await _invoke('JoinChat', args: [bookingId]);
          _startHeartbeat(bookingId);
        } catch (e) {
          _log('reconnect JoinChat failed: $e');
        }
      }
    });
    connection.onclose(({error}) {
      SignalREventLogger.logIncoming(
        hubName: _hubName,
        eventName: 'onclose',
        extra: error,
      );
      _connectionState.add(HubConnectionState.Disconnected);
      _stopHeartbeat();
      _logState('onclose', error: error);
    });
  }

  /// ChatFlow Step 5 — after access.canWrite and hub.start().
  Future<void> joinChat(String bookingId) async {
    if (bookingId.isEmpty) {
      throw ArgumentError('bookingId is required for JoinChat');
    }
    await connect();
    if (!isConnected) {
      throw StateError('Chat hub not connected');
    }
    _activeBookingId = bookingId;
    _log('📤 Invoke JoinChat → $bookingId');
    await _invoke('JoinChat', args: [bookingId]);
    _startHeartbeat(bookingId);
    _logState('joinChat($bookingId) invoked');
  }

  Future<void> leaveChat(String bookingId) async {
    _log('📤 Invoke LeaveChat → $bookingId');
    if (isConnected) {
      try {
        await _invoke('LeaveChat', args: [bookingId]);
      } catch (_) {}
    }
    if (_activeBookingId == bookingId) {
      _activeBookingId = null;
      _stopHeartbeat();
    }
    _logState('leaveChat($bookingId) done');
  }

  Future<void> _ensureJoined(String bookingId) async {
    if (_activeBookingId == bookingId && isConnected) return;
    await joinChat(bookingId);
  }

  Future<void> sendMessage({
    required String bookingId,
    required String content,
    required String idempotencyKey,
    String messageType = 'Text',
  }) async {
    await _ensureJoined(bookingId);
    await _invoke(
      'SendMessage',
      args: [bookingId, content, messageType, idempotencyKey, ''],
    );
  }

  Future<void> editMessage({
    required String bookingId,
    required String messageId,
    required String newContent,
  }) async {
    await _ensureJoined(bookingId);
    await _invoke('EditMessage', args: [bookingId, messageId, newContent]);
  }

  Future<void> deleteMessage({
    required String bookingId,
    required String messageId,
  }) async {
    await _ensureJoined(bookingId);
    await _invoke('DeleteMessage', args: [bookingId, messageId]);
  }

  Future<void> addReaction({
    required String bookingId,
    required String messageId,
    required String emoji,
  }) async {
    await _ensureJoined(bookingId);
    await _invoke('AddReaction', args: [bookingId, messageId, emoji]);
  }

  Future<void> removeReaction({
    required String bookingId,
    required String messageId,
    required String emoji,
  }) async {
    await _ensureJoined(bookingId);
    await _invoke('RemoveReaction', args: [bookingId, messageId, emoji]);
  }

  Future<void> heartbeat(String bookingId) async {
    if (!isConnected) return;
    await _invoke('Heartbeat', args: [bookingId]);
  }

  Future<void> startTyping(String bookingId) async {
    if (!isConnected) return;
    await _invoke('StartTyping', args: [bookingId]);
  }

  Future<void> stopTyping(String bookingId) async {
    if (!isConnected) return;
    await _invoke('StopTyping', args: [bookingId]);
  }

  Future<void> markRead(String bookingId, String messageId) async {
    if (!isConnected) return;
    await _invoke('MarkRead', args: [bookingId, messageId]);
  }

  Future<void> markConversationRead(String bookingId) async {
    if (!isConnected) return;
    await _invoke('MarkConversationRead', args: [bookingId]);
  }

  void _startHeartbeat(String bookingId) {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!isConnected) return;
      heartbeat(bookingId);
    });
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _invoke(String method, {List<Object>? args}) async {
    final conn = _connection;
    if (conn == null || conn.state != HubConnectionState.Connected) {
      throw StateError('Chat hub not connected — cannot invoke $method');
    }
    await SignalREventLogger.invoke(
      conn,
      hubName: _hubName,
      method: method,
      args: args,
    );
  }

  Future<void> rejoinActiveChatIfNeeded() async {
    final bookingId = _activeBookingId;
    if (bookingId == null || bookingId.isEmpty) return;
    try {
      await joinChat(bookingId);
    } catch (e) {
      _logState('rejoinActiveChatIfNeeded failed', error: e);
    }
  }

  /// Stops the socket but keeps [activeBookingId] for resume re-join.
  Future<void> suspend() async {
    _logState('suspend() starting');
    ++_connectGeneration;
    _stopHeartbeat();
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
