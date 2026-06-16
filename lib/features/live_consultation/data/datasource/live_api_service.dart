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

  LiveApiException(this.statusCode, this.message, {this.walletError});

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

  Map<String, dynamic> _parseSuccess(http.Response response, Uri url) {
    developer.log('--- LIVE API ---', name: 'LiveApiService');
    developer.log('$url → ${response.statusCode}', name: 'LiveApiService');

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
    if (data is Map<String, dynamic>) {
      message = data['message']?.toString() ?? message;
      if (response.statusCode == 400 && data.containsKey('requiredBalance')) {
        walletError = LiveInsufficientWalletResponse.fromJson(data);
        message = walletError.message;
      }
    }
    throw LiveApiException(response.statusCode, message, walletError: walletError);
  }

  Future<LiveRequestResponse> sendRequest(LiveRequestBody body) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveRequest);
    final response = await _client.post(
      url,
      headers: _headers(token, json: true),
      body: jsonEncode(body.toJson()),
    );
    final data = _parseSuccess(response, url);
    return LiveRequestResponse.fromJson(data);
  }

  Future<LiveRequestResponse> getRequestStatus(String requestId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveRequestStatus(requestId));
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseSuccess(response, url);
    return LiveRequestResponse.fromJson(data);
  }

  Future<SessionEndedSummary> endSession(LiveEndBody body) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveEnd);
    final response = await _client.post(
      url,
      headers: _headers(token, json: true),
      body: jsonEncode(body.toJson()),
    );
    final data = _parseSuccess(response, url);
    return SessionEndedSummary.fromJson(data);
  }

  Future<Map<String, dynamic>> getSessionState(String bookingId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveSession(bookingId));
    final response = await _client.get(url, headers: _headers(token));
    return _parseSuccess(response, url);
  }

  Future<List<Map<String, dynamic>>> getHistory({
    int page = 1,
    int pageSize = 20,
  }) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.liveHistory(page: page, pageSize: pageSize));
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseSuccess(response, url);
    final list = data['data'] ?? data['items'] ?? data;
    if (list is List) {
      return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }
}
