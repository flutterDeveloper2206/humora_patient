import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/notification_inbox_models.dart';

class NotificationApiService {
  final http.Client _client;

  NotificationApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- NOTIFICATION API ---', name: 'NotificationApiService');
    developer.log('URL: $url', name: 'NotificationApiService');
    developer.log('Status: ${response.statusCode}', name: 'NotificationApiService');
    developer.log('Body: ${response.body}', name: 'NotificationApiService');

    dynamic responseData;
    try {
      responseData = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) return responseData;
      return <String, dynamic>{};
    }

    String errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      }
    }
    throw Exception(errorMessage);
  }

  Future<NotificationInboxResponse> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool unreadOnly = false,
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.notifications).replace(
      queryParameters: {
        'page': '$page',
        'pageSize': '$pageSize',
        'unreadOnly': unreadOnly.toString(),
      },
    );
    final response = await _client.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    return NotificationInboxResponse.fromJson(_parseResponse(response, url));
  }

  Future<int> getUnreadCount() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.notificationsUnreadCount);
    final response = await _client.get(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    final data = _parseResponse(response, url);
    return (data['count'] as num?)?.toInt() ?? 0;
  }

  Future<MarkNotificationReadResponse> markRead(String id) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.notificationRead(id));
    final response = await _client.put(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return MarkNotificationReadResponse.fromJson(_parseResponse(response, url));
  }

  Future<MarkNotificationReadResponse> markAllRead() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.notificationsReadAll);
    final response = await _client.put(
      url,
      headers: {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    return MarkNotificationReadResponse.fromJson(_parseResponse(response, url));
  }

  Future<void> deleteNotification(String id) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.notificationDelete(id));
    final response = await _client.delete(
      url,
      headers: {'accept': '*/*', 'Authorization': 'Bearer $token'},
    );
    _parseResponse(response, url);
  }
}
