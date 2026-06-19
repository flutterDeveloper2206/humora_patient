import 'package:equatable/equatable.dart';

import 'agora_token_models.dart';

/// Channel credentials from GET /booking/my or booking detail (`agoraInfo`).
/// RTC token is fetched separately via POST /agora/token.
class AgoraInfo extends Equatable {
  final String channelName;
  final String appId;
  final String agoraUid;

  const AgoraInfo({
    required this.channelName,
    required this.appId,
    required this.agoraUid,
  });

  bool get isValid =>
      channelName.isNotEmpty && appId.isNotEmpty && agoraUid.isNotEmpty;

  int get uidForSdk {
    final parsed = int.tryParse(agoraUid);
    if (parsed != null &&
        parsed > 0 &&
        parsed <= AgoraTokenResponse.maxNativeUid) {
      return parsed;
    }
    return 0;
  }

  factory AgoraInfo.fromJson(Map<String, dynamic> json) {
    return AgoraInfo(
      channelName: json['channelName']?.toString() ?? '',
      appId: json['appId']?.toString() ?? '',
      agoraUid: json['agoraUid']?.toString() ?? '',
    );
  }

  static AgoraInfo? tryParse(dynamic json) {
    if (json is! Map<String, dynamic>) return null;
    final info = AgoraInfo.fromJson(json);
    return info.isValid ? info : null;
  }

  @override
  List<Object?> get props => [channelName, appId, agoraUid];
}
