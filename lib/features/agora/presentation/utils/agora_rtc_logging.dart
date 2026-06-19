import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

import '../../data/models/agora_token_models.dart';

/// Debug console logging for Agora RTC engine init, join params, and callbacks.
class AgoraRtcLogger {
  AgoraRtcLogger._();

  static const _tag = '[Agora RTC]';

  static bool get enabled => kDebugMode;

  static void credentialsFromServer({
    required String source,
    required String bookingId,
    required AgoraTokenResponse response,
  }) {
    _block(
      title: '◀ TOKEN FROM SERVER ($source)',
      lines: {
        'bookingId': bookingId,
        'appId': response.appId,
        'channelName': response.channelName,
        'agoraUid': response.agoraUid,
        'agoraUidWire': response.agoraUidWire,
        'uidForSdk': response.uidForSdk,
        'requiresUserAccountJoin': response.requiresUserAccountJoin,
        'userAccountForJoin': response.userAccountForJoin,
        'token (full)': response.token,
        'tokenLength': response.token.length,
        'expiresInSeconds': response.expiresInSeconds ?? '(n/a)',
        'expiresAt': response.expiresAt?.toIso8601String() ?? '(n/a)',
      },
      highlight: true,
    );
  }

  static void initialize({
    required String appId,
    required bool enableVideo,
  }) {
    _block(
      title: '▶ INITIALIZE ENGINE',
      lines: {
        'appId': appId,
        'enableVideo': enableVideo,
        'channelProfile': 'Communication',
      },
    );
  }

  static void registerUserAccount({
    required String appId,
    required String userAccount,
  }) {
    _block(
      title: '▶ registerLocalUserAccount',
      lines: {
        'appId': appId,
        'userAccount': userAccount,
      },
    );
  }

  static void joinChannel({
    required String joinMethod,
    required String appId,
    required String token,
    required String channelId,
    required int uid,
    String? userAccount,
    required bool publishVideo,
    required bool publishAudio,
  }) {
    _block(
      title: '▶ JOIN CHANNEL → $joinMethod',
      lines: {
        'appId': appId,
        'channelId': channelId,
        'channelName': channelId,
        'token (full)': token.isEmpty ? '(empty)' : token,
        'tokenLength': token.length,
        'uid (numeric join)': uid,
        'userAccount (string join)': userAccount ?? '(none — numeric uid)',
        'publishMicrophone': publishAudio,
        'publishCamera': publishVideo,
        'clientRole': 'Broadcaster',
      },
      highlight: true,
    );
  }

  static void event(String name, [Map<String, Object?>? params]) {
    _block(
      title: '◀ EVENT $name',
      lines: params,
    );
  }

  static void action(String name, [Map<String, Object?>? params]) {
    _block(
      title: '→ $name',
      lines: params,
    );
  }

  static void error(String action, Object error) {
    _block(
      title: '✗ $action',
      lines: {'error': error.toString()},
      highlight: true,
    );
  }

  static void _block({
    required String title,
    Map<String, Object?>? lines,
    bool highlight = false,
  }) {
    if (!enabled) return;

    const bar = '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━';
    const star = '★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★★';

    debugPrint('');
    if (highlight) {
      debugPrint('$_tag $star');
    }
    debugPrint('$_tag $bar');
    debugPrint('$_tag $title');
    debugPrint('$_tag $bar');

    if (lines != null) {
      for (final entry in lines.entries) {
        final value = _formatValue(entry.value);
        if (entry.key == 'token (full)' && value.length > 80) {
          debugPrint('$_tag   ${entry.key}:');
          debugPrint('$_tag     $value');
        } else {
          debugPrint('$_tag   ${entry.key}: $value');
        }
      }
    }

    debugPrint('$_tag $bar');
    if (highlight) {
      debugPrint('$_tag $star');
    }
    debugPrint('');

    developer.log(
      '$title${lines == null ? '' : '\n${lines.entries.map((e) => '${e.key}: ${_formatValue(e.value)}').join('\n')}'}',
      name: 'AgoraRtc',
    );
  }

  static String _formatValue(Object? value) {
    if (value == null) return 'null';
    return value.toString();
  }
}
