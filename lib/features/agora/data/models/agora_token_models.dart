import 'package:equatable/equatable.dart';

import '../../../../core/constants/agora_config.dart';

class AgoraTokenResponse extends Equatable {
  final String appId;
  final String channelName;
  final String token;
  final int uid;
  final String agoraUid;
  final int? expiresInSeconds;
  final DateTime? expiresAt;

  const AgoraTokenResponse({
    required this.appId,
    required this.channelName,
    required this.token,
    required this.uid,
    this.agoraUid = '',
    this.expiresInSeconds,
    this.expiresAt,
  });

  /// UID for [joinChannel] when using numeric uid (matches vendor app).
  int get uidForSdk {
    final fromAgoraUid = int.tryParse(agoraUid);
    if (fromAgoraUid != null && fromAgoraUid > 0) return fromAgoraUid;
    if (uid > 0) return uid;
    return 0;
  }

  /// True when token was issued for a string user account (UUID etc.).
  bool get usesStringUserAccount =>
      agoraUid.isNotEmpty && int.tryParse(agoraUid) == null;

  /// Wire value for POST /agora/join (REST).
  String get agoraUidWire {
    if (agoraUid.isNotEmpty) return agoraUid;
    if (uid > 0) return uid.toString();
    return '0';
  }

  bool get isValid => token.isNotEmpty && channelName.isNotEmpty;

  factory AgoraTokenResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    final rawUid = data['uid'] ?? data['userId'];
    final uid = rawUid is num
        ? rawUid.toInt()
        : int.tryParse(rawUid?.toString() ?? '') ?? 0;
    final agoraUidRaw = data['agoraUid'];
    final agoraUid = agoraUidRaw != null
        ? agoraUidRaw.toString()
        : (uid > 0 ? uid.toString() : '');

    final appId = (data['appId'] ?? data['app_id'] ?? AgoraConfig.appId)
        .toString();

    return AgoraTokenResponse(
      appId: appId.isNotEmpty ? appId : AgoraConfig.appId,
      channelName: (data['channelName'] ??
              data['agoraChannelName'] ??
              data['channel'] ??
              data['channelId'] ??
              '')
          .toString(),
      token: (data['token'] ?? data['rtcToken'] ?? data['agoraToken'] ?? '')
          .toString(),
      uid: uid,
      agoraUid: agoraUid,
      expiresInSeconds: (data['expiresInSeconds'] as num?)?.toInt(),
      expiresAt: _parseDate(data['expiresAt']),
    );
  }

  factory AgoraTokenResponse.fromLiveAccept({
    required String agoraToken,
    required String agoraChannelName,
    required String agoraUidWire,
    String? appId,
  }) {
    final uid = int.tryParse(agoraUidWire) ?? 0;
    return AgoraTokenResponse(
      appId: (appId != null && appId.isNotEmpty) ? appId : AgoraConfig.appId,
      channelName: agoraChannelName,
      token: agoraToken,
      uid: uid,
      agoraUid: agoraUidWire,
    );
  }

  @override
  List<Object?> get props => [appId, channelName, token, uid, agoraUid];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}
