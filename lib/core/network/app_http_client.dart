import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

import 'network_aware_client.dart';

/// Single shared HTTP client for the app lifecycle.
///
/// Uses one underlying [HttpClient] so sockets are not opened/closed per call
/// (avoids debug `network_profiling.dart` assertion crashes).
class AppHttpClient {
  AppHttpClient._();

  static final HttpClient _io = HttpClient()
    ..connectionTimeout = const Duration(seconds: 30)
    ..idleTimeout = const Duration(seconds: 60);

  /// Raw client for connectivity reachability checks (avoids recursion).
  static final http.Client rawInstance = IOClient(_io);

  static final http.Client instance = NetworkAwareClient(rawInstance);
}
