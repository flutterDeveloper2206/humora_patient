import '../../data/models/agora_info.dart';
import '../../data/models/agora_token_models.dart';

/// Merges booking [AgoraInfo] with on-demand RTC token response.
AgoraTokenResponse mergeAgoraCredentials({
  required AgoraTokenResponse token,
  AgoraInfo? agoraInfo,
}) {
  if (agoraInfo == null || !agoraInfo.isValid) return token;

  final agoraUid = token.agoraUid.isNotEmpty
      ? token.agoraUid
      : agoraInfo.agoraUid;
  final uid = token.uid > 0 ? token.uid : agoraInfo.uidForSdk;

  return AgoraTokenResponse(
    appId: token.appId.isNotEmpty ? token.appId : agoraInfo.appId,
    channelName: token.channelName.isNotEmpty
        ? token.channelName
        : agoraInfo.channelName,
    token: token.token,
    uid: uid,
    agoraUid: agoraUid,
    expiresInSeconds: token.expiresInSeconds,
    expiresAt: token.expiresAt,
  );
}
