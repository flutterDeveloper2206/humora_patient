import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/chat_models.dart';

class ChatApiException implements Exception {
  final int statusCode;
  final String message;
  final String? code;

  ChatApiException(this.statusCode, this.message, {this.code});

  @override
  String toString() => message;
}

class ChatApiService {
  final http.Client _client;

  ChatApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, String> _headers(String token, {bool json = false}) => {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        if (json) 'Content-Type': 'application/json',
      };

  dynamic _decode(http.Response response, Uri url) {
    developer.log('--- CHAT API ---', name: 'ChatApiService');
    developer.log('$url → ${response.statusCode}', name: 'ChatApiService');

    dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      throw ChatApiException(
        response.statusCode,
        'Invalid response format.',
      );
    }
    return data;
  }

  Future<ChatAccessResponse> getAccess(String bookingId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatAccess(bookingId));
    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ChatAccessResponse.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Access check failed',
      code: map['code']?.toString(),
    );
  }

  Future<ChatHistoryResponse> getHistory(
    String bookingId, {
    int page = 1,
    int pageSize = 50,
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(
      ApiEndpoints.chatHistory(bookingId, page: page, pageSize: pageSize),
    );
    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ChatHistoryResponse.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Failed to load history',
    );
  }

  Future<List<ConversationListItemDto>> getConversations() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatConversations);
    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = data is List
          ? data
          : (data is Map ? (data['data'] ?? data['items']) : null);
      if (list is List) {
        return list
            .map(
              (e) => ConversationListItemDto.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
      return [];
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Failed to load conversations',
    );
  }

  Future<ChatMessageDto> sendMessageRest({
    required String bookingId,
    required String content,
    required String idempotencyKey,
    String messageType = 'Text',
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatSend);
    final body = jsonEncode({
      'bookingId': bookingId,
      'content': content,
      'messageType': messageType,
      'idempotencyKey': idempotencyKey,
    });
    final response = await _client.post(
      url,
      headers: _headers(token, json: true),
      body: body,
    );
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final map = data is Map<String, dynamic>
          ? (data['data'] is Map ? data['data'] as Map<String, dynamic> : data)
          : <String, dynamic>{};
      return ChatMessageDto.fromJson(map);
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Send failed',
      code: map['code']?.toString(),
    );
  }

  Future<ConversationDetailDto> getConversation(String bookingId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatConversation(bookingId));
    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ConversationDetailDto.fromJson(
        data is Map<String, dynamic> ? data : {},
      );
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Failed to load conversation',
    );
  }

  Future<List<ChatMessageDto>> searchMessages(
    String bookingId,
    String query,
  ) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatSearch(bookingId, query));
    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final list = data is List
          ? data
          : (data is Map ? (data['data'] ?? data['messages'] ?? data['items']) : null);
      if (list is List) {
        return list
            .map(
              (e) => ChatMessageDto.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();
      }
      return [];
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Search failed',
    );
  }

  Future<ChatMessageDto> editMessageRest({
    required String messageId,
    required String content,
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatEditMessage);
    final response = await _client.put(
      url,
      headers: _headers(token, json: true),
      body: jsonEncode({'messageId': messageId, 'content': content}),
    );
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final map = data is Map<String, dynamic>
          ? (data['data'] is Map ? data['data'] as Map<String, dynamic> : data)
          : <String, dynamic>{};
      return ChatMessageDto.fromJson(map);
    }
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Edit failed',
      code: map['code']?.toString(),
    );
  }

  Future<void> deleteMessageRest(String messageId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.chatDeleteMessage(messageId));
    final response = await _client.delete(url, headers: _headers(token));
    final data = _decode(response, url);
    if (response.statusCode >= 200 && response.statusCode < 300) return;
    final map = data is Map<String, dynamic> ? data : <String, dynamic>{};
    throw ChatApiException(
      response.statusCode,
      map['message']?.toString() ?? 'Delete failed',
      code: map['code']?.toString(),
    );
  }
}
