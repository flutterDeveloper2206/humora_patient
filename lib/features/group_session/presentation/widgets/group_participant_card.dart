import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/widgets/agora_video_tile.dart';
import '../bloc/group_session_state.dart';

class GroupParticipantCard extends StatelessWidget {
  final GroupParticipant participant;
  final RtcEngine? engine;

  const GroupParticipantCard({
    super.key,
    required this.participant,
    this.engine,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        color: Colors.black12,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AgoraVideoTile(
            engine: engine,
            uid: participant.agoraUid,
          ),
          if (participant.isMuted)
            Positioned(
              top: 10.h,
              left: 10.w,
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.mic_off, size: 14.sp, color: Colors.black),
              ),
            ),
          Positioned(
            bottom: 10.h,
            left: 10.w,
            right: 10.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                participant.name,
                style: AppTextStyles.bodySmall.copyWith(
                  fontSize: 9.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}







