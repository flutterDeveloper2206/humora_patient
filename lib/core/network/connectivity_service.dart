import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../../common/widgets/no_internet_dialog.dart';
import '../constants/api_endpoints.dart';
import 'app_http_client.dart';
import 'no_internet_exception.dart';

/// Global connectivity monitor — shows a blocking dialog when offline.
class ConnectivityService {
  ConnectivityService._();

  static final ConnectivityService instance = ConnectivityService._();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  GlobalKey<NavigatorState>? _navigatorKey;
  bool _isOnline = true;
  bool _dialogVisible = false;

  bool get isOnline => _isOnline;

  void bindNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> init() async {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (results) => _applyConnectivity(results, showDialogIfOffline: true),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await _connectivity.checkConnectivity();
      await _applyConnectivity(initial, showDialogIfOffline: true);
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
  }

  Future<void> _applyConnectivity(
    List<ConnectivityResult> results, {
    required bool showDialogIfOffline,
  }) async {
    final hasInterface = _hasNetworkInterface(results);
    if (!hasInterface) {
      _updateOnline(false, showDialog: showDialogIfOffline);
      return;
    }

    final reachable = await _verifyReachability();
    _updateOnline(reachable, showDialog: showDialogIfOffline && !reachable);
  }

  bool _hasNetworkInterface(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  Future<bool> _verifyReachability() async {
    try {
      final uri = Uri.parse(ApiEndpoints.baseUrl);
      final response = await AppHttpClient.rawInstance
          .head(uri)
          .timeout(const Duration(seconds: 8));
      return response.statusCode < 500;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } on IOException {
      return false;
    } catch (_) {
      return true;
    }
  }

  void _updateOnline(bool online, {required bool showDialog}) {
    _isOnline = online;
    if (online) {
      _dismissDialog();
    } else if (showDialog) {
      _presentDialog();
    }
  }

  void handleRequestFailure(Object error) {
    if (_isConnectivityFailure(error)) {
      _isOnline = false;
      _presentDialog();
    }
  }

  bool _isConnectivityFailure(Object error) {
    if (error is NoInternetException) return true;
    if (error is SocketException) return true;
    if (error is TimeoutException) return true;
    if (error is IOException) return true;
    final text = error.toString().toLowerCase();
    return text.contains('socket') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('connection refused') ||
        text.contains('connection timed out') ||
        text.contains('no internet');
  }

  Future<bool> retryConnection() async {
    final results = await _connectivity.checkConnectivity();
    if (!_hasNetworkInterface(results)) {
      _updateOnline(false, showDialog: true);
      return false;
    }
    final reachable = await _verifyReachability();
    _updateOnline(reachable, showDialog: !reachable);
    return reachable;
  }

  void _presentDialog() {
    if (_dialogVisible) return;
    final nav = _navigatorKey?.currentState;
    if (nav == null) return;
    final context = nav.context;
    if (!context.mounted) return;

    _dialogVisible = true;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      useRootNavigator: true,
      builder: (_) => NoInternetDialog(
        onRetry: retryConnection,
      ),
    ).whenComplete(() {
      _dialogVisible = false;
    });
  }

  void _dismissDialog() {
    if (!_dialogVisible) return;
    final nav = _navigatorKey?.currentState;
    if (nav != null && nav.canPop()) {
      nav.pop();
    }
    _dialogVisible = false;
  }

  Future<void> ensureOnlineOrThrow() async {
    if (_isOnline) return;
    _presentDialog();
    throw const NoInternetException();
  }
}
