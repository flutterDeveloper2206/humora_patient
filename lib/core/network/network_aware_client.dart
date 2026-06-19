import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:http/http.dart' as http;

import 'connectivity_service.dart';
import 'no_internet_exception.dart';

/// Wraps [http.Client] — blocks calls when offline and surfaces network failures globally.
class NetworkAwareClient extends http.BaseClient {
  final http.Client _inner;

  NetworkAwareClient(this._inner);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final curl = _toCurl(request);
      developer.log(curl, name: 'cURL');
    } catch (e, stackTrace) {
      developer.log(
        'Failed to generate cURL: $e',
        name: 'cURL',
        error: e,
        stackTrace: stackTrace,
      );
    }

    if (!ConnectivityService.instance.isOnline) {
      ConnectivityService.instance.handleRequestFailure(
        const NoInternetException(),
      );
      throw const NoInternetException();
    }

    try {
      return await _inner.send(request).timeout(const Duration(seconds: 30));
    } on TimeoutException catch (e) {
      ConnectivityService.instance.handleRequestFailure(e);
      throw const NoInternetException(
        'Connection timed out. Please check your internet and try again.',
      );
    } on SocketException catch (e) {
      ConnectivityService.instance.handleRequestFailure(e);
      throw const NoInternetException();
    } on IOException catch (e) {
      ConnectivityService.instance.handleRequestFailure(e);
      throw const NoInternetException();
    } catch (e) {
      if (ConnectivityService.instance.isOnline == false) {
        ConnectivityService.instance.handleRequestFailure(e);
        throw const NoInternetException();
      }
      rethrow;
    }
  }

  String _toCurl(http.BaseRequest request) {
    final buffer = StringBuffer('curl');

    // Method
    buffer.write(' -X ${request.method}');

    // Headers
    request.headers.forEach((key, value) {
      final escapedValue = value.replaceAll("'", "'\\''");
      buffer.write(" -H '$key: $escapedValue'");
    });

    // Body
    if (request is http.Request) {
      if (request.body.isNotEmpty) {
        final escapedBody = request.body.replaceAll("'", "'\\''");
        buffer.write(" -d '$escapedBody'");
      }
    } else if (request is http.MultipartRequest) {
      request.fields.forEach((key, value) {
        final escapedValue = value.replaceAll("'", "'\\''");
        buffer.write(" -F '$key=$escapedValue'");
      });
      for (final file in request.files) {
        buffer.write(" -F '${file.field}=@${file.filename ?? 'file'}'");
      }
    }

    // URL
    buffer.write(" '${request.url}'");

    return buffer.toString();
  }

  @override
  void close() => _inner.close();
}
