import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/group_session_state.dart';

class GroupParticipantCard extends StatelessWidget {
  final GroupParticipant participant;

  const GroupParticipantCard({super.key, required this.participant});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24.r),
        image: DecorationImage(
          image: NetworkImage(participant.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Mute Icon Overlay
          Positioned(
            top: 10.h,
            left: 10.w,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                participant.isMuted ? Icons.mic_off : Icons.mic,
                size: 14.sp,
                color: Colors.black,
              ),
            ),
          ),

          // Hand Raised Overlay
          if (participant.isHandRaised)
            Positioned(
              top: -8.h,
              right: -8.w,
              child: Transform.rotate(
                angle: 0.2, // Slight tilt
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE81848),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.front_hand,
                    size: 16.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

          // Name Overlay
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 8.r,
                    backgroundImage: NetworkImage(participant.imageUrl),
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      '${participant.name} - ${participant.role}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
