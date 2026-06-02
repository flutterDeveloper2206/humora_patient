import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../booking/data/datasource/booking_api_service.dart';
import '../models/my_booking_models.dart';

class MySessionsApiService {
  final http.Client _client;

  MySessionsApiService({http.Client? client})
      : _client = client ?? AppHttpClient.instance;

  Future<String> _requireToken() async {
    final token = await SessionManager.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found');
    }
    return token;
  }

  Map<String, String> _headers(String token) => {
        'accept': '*/*',
        'Authorization': 'Bearer $token',
      };

  dynamic _decode(http.Response response, Uri url, String tag) {
    developer.log('--- API RESPONSE ---', name: tag);
    developer.log('URL: $url', name: tag);
    developer.log('Status: ${response.statusCode}', name: tag);
    developer.log('Body: ${response.body}', name: tag);

    dynamic responseData;
    try {
      responseData = response.body.isEmpty ? null : jsonDecode(response.body);
    } catch (_) {
      throw BookingApiException(
        response.statusCode,
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseData;
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

  List<dynamic> _extractList(dynamic responseData) {
    if (responseData == null) return [];
    if (responseData is List) return responseData;

    if (responseData is Map<String, dynamic>) {
      const keys = [
        'data',
        'items',
        'bookings',
        'result',
        'records',
        'content',
      ];
      for (final key in keys) {
        final value = responseData[key];
        if (value is List) return value;
        if (value is Map<String, dynamic>) {
          for (final nested in keys) {
            final inner = value[nested];
            if (inner is List) return inner;
          }
        }
      }
      if (responseData.isEmpty) return [];
    }

    return [];
  }

  List<MyBookingModel> _parseBookings(List<dynamic> list) {
    final bookings = <MyBookingModel>[];
    for (final item in list) {
      if (item is! Map<String, dynamic>) continue;
      try {
        bookings.add(MyBookingModel.fromJson(item));
      } catch (e) {
        developer.log(
          'Skip invalid booking item: $e',
          name: 'MySessionsApiService',
        );
      }
    }
    return bookings;
  }

  Future<List<MyBookingModel>> fetchMyBookings() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.myBookings(isHealer: false));

    developer.log('--- API REQUEST ---', name: 'MySessionsApiService');
    developer.log('GET $url', name: 'MySessionsApiService');

    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url, 'MySessionsApiService');
    final list = _extractList(data);
    return _parseBookings(list);
  }

  Future<BookingDetailModel> fetchBookingDetail(String bookingId) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.bookingDetail(bookingId));

    developer.log('--- API REQUEST ---', name: 'MySessionsApiService');
    developer.log('GET $url', name: 'MySessionsApiService');

    final response = await _client.get(url, headers: _headers(token));
    final data = _decode(response, url, 'MySessionsApiService');

    if (data is Map<String, dynamic>) {
      final inner = data['data'];
      if (inner is Map<String, dynamic>) {
        return BookingDetailModel.fromJson(inner);
      }
      return BookingDetailModel.fromJson(data);
    }
    throw const BookingApiException(0, 'Invalid booking detail from server.');
  }
}
