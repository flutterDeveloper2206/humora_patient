import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/agora_token_models.dart';

class AgoraTokenApiService {
  final http.Client _client;

  AgoraTokenApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'AgoraTokenApiService');
    developer.log('URL: $url', name: 'AgoraTokenApiService');
    developer.log(
      'Status Code: ${response.statusCode}',
      name: 'AgoraTokenApiService',
    );
    developer.log('Response Body: ${response.body}', name: 'AgoraTokenApiService');

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) {
        return responseData;
      }
      throw Exception('Invalid response structure from server.');
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

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, String> _headers(String authToken, {bool json = false}) => {
        'accept': '*/*',
        'Authorization': 'Bearer $authToken',
        if (json) 'Content-Type': 'application/json',
      };

  /// Scheduled: GET /booking/{id}/agora-token.
  /// Live: POST /booking/{id}/join (primary), then POST /agora/token, then GET agora-token.
  Future<AgoraTokenResponse> fetchToken(
    String bookingId, {
    bool isLive = false,
    String? liveMode,
  }) async {
    if (isLive) {
      return _fetchLiveToken(
        bookingId,
        mode: liveMode ?? 'audio',
      );
    }
    return _fetchScheduledToken(bookingId);
  }

  Future<AgoraTokenResponse> _fetchScheduledToken(String bookingId) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.scheduledAgoraToken(bookingId));
    developer.log('GET $url', name: 'AgoraTokenApiService');
    final response = await _client.get(url, headers: _headers(authToken));
    final data = _parseResponse(response, url);
    return AgoraTokenResponse.fromJson(data);
  }

  Future<AgoraTokenResponse> _fetchLiveToken(
    String bookingId, {
    required String mode,
  }) async {
    Object? lastError;

    for (final strategy in [
      () => _fetchViaBookingJoin(bookingId, mode),
      () => _fetchViaAgoraTokenPost(bookingId),
      () => _fetchScheduledToken(bookingId),
    ]) {
      try {
        final result = await strategy();
        if (result.isValid) return result;
        lastError = Exception('Incomplete Agora credentials from server');
      } catch (e) {
        lastError = e;
        developer.log(
          'Live Agora credential strategy failed: $e',
          name: 'AgoraTokenApiService',
        );
      }
    }

    throw lastError ?? Exception('Unable to obtain live call credentials');
  }

  Future<AgoraTokenResponse> _fetchViaBookingJoin(
    String bookingId,
    String mode,
  ) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.bookingAgoraJoin(bookingId));
    final body = jsonEncode({'mode': mode});
    developer.log('POST $url body=$body', name: 'AgoraTokenApiService');
    final response = await _client.post(
      url,
      headers: _headers(authToken, json: true),
      body: body,
    );
    final data = _parseResponse(response, url);
    return AgoraTokenResponse.fromJson(data);
  }

  Future<AgoraTokenResponse> _fetchViaAgoraTokenPost(String bookingId) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.agoraToken);
    final body = jsonEncode({
      'bookingId': bookingId,
      'role': 'Publisher',
    });
    developer.log('POST $url', name: 'AgoraTokenApiService');
    final response = await _client.post(
      url,
      headers: _headers(authToken, json: true),
      body: body,
    );
    final data = _parseResponse(response, url);
    return AgoraTokenResponse.fromJson(data);
  }

  Future<void> notifyJoined({
    required String bookingId,
    required String agoraUid,
  }) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.agoraJoin);
    final response = await _client.post(
      url,
      headers: _headers(authToken, json: true),
      body: jsonEncode({
        'bookingId': bookingId,
        'agoraUid': agoraUid,
      }),
    );
    _parseResponse(response, url);
  }

  Future<void> notifyLeft({
    required String bookingId,
    String reason = 'Normal',
  }) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.agoraLeave);
    final response = await _client.post(
      url,
      headers: _headers(authToken, json: true),
      body: jsonEncode({
        'bookingId': bookingId,
        'reason': reason,
      }),
    );
    _parseResponse(response, url);
  }

  Future<void> reconnect({
    required String bookingId,
    required String agoraUid,
  }) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.agoraReconnect);
    final response = await _client.post(
      url,
      headers: _headers(authToken, json: true),
      body: jsonEncode({
        'bookingId': bookingId,
        'agoraUid': agoraUid,
      }),
    );
    _parseResponse(response, url);
  }

  Future<Map<String, dynamic>> getSessionState(String bookingId) async {
    final authToken = await _requireToken();
    final url = Uri.parse(ApiEndpoints.agoraState(bookingId));
    final response = await _client.get(url, headers: _headers(authToken));
    return _parseResponse(response, url);
  }
}
