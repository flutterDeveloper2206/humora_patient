import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/live_models.dart';

class LiveApiException implements Exception {
  final int statusCode;
  final String message;
  final LiveInsufficientWalletResponse? walletError;
  final int? queuePosition;

  LiveApiException(
    this.statusCode,
    this.message, {
    this.walletError,
    this.queuePosition,
  });

  @override
  String toString() => message;
}

class LiveApiService {
  final http.Client _client;

  LiveApiService({http.Client? client})
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

  void _logRequest({
    required String method,
    required Uri url,
    Map<String, dynamic>? params,
    Object? body,
  }) {
    developer.log('--- LIVE API REQUEST ---', name: 'LiveApiService');
    developer.log('$method $url', name: 'LiveApiService');
    if (params != null && params.isNotEmpty) {
      developer.log('Params: $params', name: 'LiveApiService');
    }
    if (body != null) {
      developer.log('Body: $body', name: 'LiveApiService');
    }
  }

  Map<String, dynamic> _parseSuccess(http.Response response, Uri url) {
    developer.log('--- LIVE API RESPONSE ---', name: 'LiveApiService');
    developer.log('URL: $url', name: 'LiveApiService');
    developer.log('Status: ${response.statusCode}', name: 'LiveApiService');
    developer.log('Body: ${response.body}', name: 'LiveApiService');

    dynamic data;
    try {
      data = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      throw LiveApiException(
        response.statusCode,
        'Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic>) return data;
      return {'data': data};
    }

    String message = 'Request failed (${response.statusCode})';
    LiveInsufficientWalletResponse? walletError;
    int? queuePosition;
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
      queuePosition = (data['position'] as num?)?.toInt();
      if (response.statusCode == 400 && data.containsKey('requiredBalance')) {
        walletError = LiveInsufficientWalletResponse.fromJson(data);
        message = walletError.message;
      }
    }
    throw LiveApiException(
      response.statusCode,
      message,
      walletError: walletError,
      queuePosition: queuePosition,
    );
  }

  Future<LiveRequestResponse> sendRequest(LiveRequestBody body) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveRequest);
    final encodedBody = jsonEncode(body.toJson());
    _logRequest(method: 'POST', url: url, body: encodedBody);
    final response = await _client.post(
      url,
      headers: _headers(token, json: true),
      body: encodedBody,
    );
    final data = _parseSuccess(response, url);
    return LiveRequestResponse.fromJson(data);
  }

  Future<LiveRequestResponse> getRequestStatus(String requestId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveRequestStatus(requestId));
    _logRequest(
      method: 'GET',
      url: url,
      params: {'requestId': requestId},
    );
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseSuccess(response, url);
    return LiveRequestResponse.fromJson(data);
  }

  Future<SessionEndedSummary> endSession(LiveEndBody body) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveEnd);
    final encodedBody = jsonEncode(body.toJson());
    _logRequest(method: 'POST', url: url, body: encodedBody);
    final response = await _client.post(
      url,
      headers: _headers(token, json: true),
      body: encodedBody,
    );
    final data = _parseSuccess(response, url);
    return SessionEndedSummary.fromJson(data);
  }

  Future<Map<String, dynamic>> getSessionState(String bookingId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveSession(bookingId));
    _logRequest(
      method: 'GET',
      url: url,
      params: {'bookingId': bookingId},
    );
    final response = await _client.get(url, headers: _headers(token));
    return _parseSuccess(response, url);
  }

  Future<List<Map<String, dynamic>>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveHistory(page: page, pageSize: pageSize));
    _logRequest(
      method: 'GET',
      url: url,
      params: {'page': page, 'pageSize': pageSize},
    );
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseSuccess(response, url);
    final list = data['data'] ?? data['items'] ?? data;
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<WaitlistPositionResponse> getWaitlistPosition(String healerId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveWaitlistPosition(healerId));
    _logRequest(
      method: 'GET',
      url: url,
      params: {'healerId': healerId},
    );
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseSuccess(response, url);
    return WaitlistPositionResponse.fromJson(data);
  }

  Future<void> leaveWaitlist(String healerId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveWaitlistLeave(healerId));
    _logRequest(
      method: 'DELETE',
      url: url,
      params: {'healerId': healerId},
    );
    final response = await _client.delete(url, headers: _headers(token));
    _parseSuccess(response, url);
  }
}
