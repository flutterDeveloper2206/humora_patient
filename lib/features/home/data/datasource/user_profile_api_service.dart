import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/app_http_client.dart';
import '../../../../core/utils/session_manager.dart';
import '../models/user_profile_model.dart';

class UserProfileApiService {
  final http.Client _client;

  UserProfileApiService({http.Client? client})
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

  Map<String, dynamic> _parseResponse(http.Response response, Uri url) {
    developer.log('--- API RESPONSE ---', name: 'UserProfileApiService');
    developer.log('URL: $url', name: 'UserProfileApiService');
    developer.log(
      'Status Code: ${response.statusCode}',
      name: 'UserProfileApiService',
    );
    developer.log(
      'Response Body: ${response.body}',
      name: 'UserProfileApiService',
    );

    dynamic data;
    try {
      data = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body);
    } catch (_) {
      throw Exception(
        'Server error (${response.statusCode}): Invalid response format.',
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (data is Map<String, dynamic>) return data;
      throw Exception('Invalid response structure from server.');
    }

    var message = 'Request failed with status ${response.statusCode}';
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        message = data['message'].toString();
      } else if (data['error'] != null) {
        message = data['error'].toString();
      } else if (data['errors'] != null) {
        final errors = data['errors'];
        if (errors is List) {
          message = errors.join(', ');
        } else if (errors is Map) {
          message = errors.values.map((e) => e.toString()).join(', ');
        } else {
          message = errors.toString();
        }
      }
    }
    throw Exception(message);
  }

  Future<UserProfileModel> getProfile() async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.userProfile);
    developer.log('GET $url', name: 'UserProfileApiService');
    final response = await _client.get(url, headers: _headers(token));
    final data = _parseResponse(response, url);
    return UserProfileModel.fromJson(data);
  }

  Future<void> updateProfile(UpdateUserProfileRequest request) async {
    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.userProfile);
    final multipart = http.MultipartRequest('PUT', url)
      ..headers.addAll(_headers(token))
      ..fields.addAll(request.toFormFields());

    developer.log(
      'PUT $url fields=${multipart.fields}',
      name: 'UserProfileApiService',
    );
    final streamed = await _client.send(multipart);
    final response = await http.Response.fromStream(streamed);
    _parseResponse(response, url);
  }

  Future<void> updateProfileImages({
    required String userId,
    File? profilePic,
    File? coverImage,
  }) async {
    if (profilePic == null && coverImage == null) return;

    final token = await _requireToken();
    final url = Uri.parse(ApiEndpoints.updateUserImage(userId));
    final multipart = http.MultipartRequest('PUT', url)
      ..headers.addAll(_headers(token));

    if (profilePic != null) {
      multipart.files.add(
        await http.MultipartFile.fromPath('ProfilePic', profilePic.path),
      );
    }
    if (coverImage != null) {
      multipart.files.add(
        await http.MultipartFile.fromPath('CoverImage', coverImage.path),
      );
    }

    developer.log(
      'PUT $url files=${multipart.files.map((f) => f.field).toList()}',
      name: 'UserProfileApiService',
    );
    final streamed = await _client.send(multipart);
    final response = await http.Response.fromStream(streamed);
    _parseResponse(response, url);
  }
}
