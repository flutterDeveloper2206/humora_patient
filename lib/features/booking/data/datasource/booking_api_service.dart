import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/booking_models.dart';

class BookingApiException implements Exception {
  final int statusCode;
  final String message;

  const BookingApiException(this.statusCode, this.message);

  bool get isIdempotencyInProgress =>
      statusCode == 409 &&
      message.toLowerCase().contains('idempotency');

  bool get isInsufficientBalance =>
      statusCode == 400 &&
      message.toLowerCase().contains('balance');

  @override
  String toString() => message;
}

class BookingApiService {
  final http.Client _client;

  BookingApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Future<CreateBookingResponse> createBooking(
    CreateBookingRequest request,
  ) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.createBooking);
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'BookingApiService');
    developer.log('POST $url', name: 'BookingApiService');
    developer.log('Body: $body', name: 'BookingApiService');

    final response = await _client.post(url, headers: headers, body: body);

    developer.log('--- API RESPONSE ---', name: 'BookingApiService');
    developer.log('Status: ${response.statusCode}', name: 'BookingApiService');
    developer.log('Body: ${response.body}', name: 'BookingApiService');

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      throw BookingApiException(
        response.statusCode,
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) {
        return CreateBookingResponse.fromJson(responseData);
      }
      throw const BookingApiException(0, 'Invalid response structure from server.');
    }

    var errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      }
    }

    throw BookingApiException(response.statusCode, errorMessage);
  }

  Future<CancelBookingResponse> cancelBooking(
    CancelBookingRequest request,
  ) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.cancelBooking);
    final headers = {
      'accept': '*/*',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final body = jsonEncode(request.toJson());

    developer.log('--- API REQUEST ---', name: 'BookingApiService');
    developer.log('POST $url', name: 'BookingApiService');
    developer.log('Body: $body', name: 'BookingApiService');

    final response = await _client.post(url, headers: headers, body: body);

    developer.log('--- API RESPONSE ---', name: 'BookingApiService');
    developer.log('Status: ${response.statusCode}', name: 'BookingApiService');
    developer.log('Body: ${response.body}', name: 'BookingApiService');

    dynamic responseData;
    try {
      responseData = jsonDecode(response.body);
    } catch (_) {
      throw BookingApiException(
        response.statusCode,
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (responseData is Map<String, dynamic>) {
        return CancelBookingResponse.fromJson(responseData);
      }
      throw const BookingApiException(
        0,
        'Invalid response structure from server.',
      );
    }

    var errorMessage = 'Request failed with status ${response.statusCode}';
    if (responseData is Map<String, dynamic>) {
      if (responseData['message'] != null) {
        errorMessage = responseData['message'].toString();
      } else if (responseData['error'] != null) {
        errorMessage = responseData['error'].toString();
      } else if (responseData['errors'] != null) {
        final errors = responseData['errors'];
        if (errors is List) {
          errorMessage = errors.map((e) => e.toString()).join(', ');
        } else if (errors is Map) {
          errorMessage = errors.values.map((e) => e.toString()).join(', ');
        }
      }
    }

    throw BookingApiException(response.statusCode, errorMessage);
  }
}
