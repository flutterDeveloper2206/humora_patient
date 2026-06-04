import 'dart:async';
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

  @override
  void close() => _inner.close();
}
