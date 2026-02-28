import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../bloc/group_session_state.dart';

class MainSpeakerCard extends StatelessWidget {
  final GroupParticipant participant;
  final Duration duration;

  const MainSpeakerCard({
    super.key,
    required this.participant,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Container(
      height: 320.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.r),
        image: DecorationImage(
          image: NetworkImage(participant.imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Recording Panel
          Positioned(
            top: 16.h,
            left: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE81848),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '$hours:$minutes:$seconds',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Panel Top Right
          Positioned(
            top: 16.h,
            right: 16.w,
            child: Row(
              children: [
                _buildCircleIcon(Icons.mic),
                SizedBox(width: 8.w),
                _buildCircleIcon(Icons.more_vert),
              ],
            ),
          ),

          // Name and Info Bottom Panel
          Positioned(
            bottom: 16.h,
            left: 16.w,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundImage: NetworkImage(participant.imageUrl),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          participant.name,
                          style: AppTextStyles.bodyMedium
                        ),
                        Text(
                          participant.role,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 12.sp,
                            color: Color(0xff616161),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹ 55.00',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
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

  Widget _buildCircleIcon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.black, size: 20.sp),
    );
  }
}
