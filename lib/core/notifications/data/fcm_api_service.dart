// Device-token API disabled until backend is ready.
// Restore with ApiEndpoints.registerDeviceToken / unregisterDeviceToken.

// import 'dart:convert';
// import 'dart:developer' as developer;
//
// import 'package:http/http.dart' as http;
//
// import '../../constants/api_endpoints.dart';
// import '../../network/app_http_client.dart';
// import '../../utils/session_manager.dart';
// import '../models/notification_device_request.dart';
//
// class FcmApiService {
//   final http.Client _client;
//
//   FcmApiService({http.Client? client})
//       : _client = client ?? AppHttpClient.instance;
//
//   Future<void> registerDevice(NotificationDeviceRequest request) async { ... }
//
//   Future<void> unregisterDevice(String deviceToken) async { ... }
// }
