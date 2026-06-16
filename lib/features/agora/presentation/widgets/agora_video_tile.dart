import 'dart:io';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Renders Agora video with platform-appropriate view mode (iOS texture / Android SurfaceView).
class AgoraVideoTile extends StatelessWidget {
  final RtcEngine? engine;
  final int uid;
  final bool isLocal;

  const AgoraVideoTile({
    super.key,
    required this.engine,
    required this.uid,
    this.isLocal = false,
  });

  @override
  Widget build(BuildContext context) {
    if (engine == null) {
      return const ColoredBox(color: Colors.black);
    }

    final useAndroidSurface = !kIsWeb && Platform.isAndroid;
    final useFlutterTexture = !kIsWeb && Platform.isIOS;

    return AgoraVideoView(
      controller: VideoViewController(
        rtcEngine: engine!,
        canvas: VideoCanvas(uid: uid),
        useAndroidSurfaceView: useAndroidSurface,
        useFlutterTexture: useFlutterTexture,
      ),
    );
  }
}
