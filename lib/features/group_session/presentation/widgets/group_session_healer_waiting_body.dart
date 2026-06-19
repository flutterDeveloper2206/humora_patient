import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/widgets/agora_video_tile.dart';
import '../bloc/group_session_state.dart';

/// Shown when the patient is connected but the healer has not joined yet.
class GroupSessionHealerWaitingBody extends StatelessWidget {
  final GroupSessionState state;

  const GroupSessionHealerWaitingBody({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    GroupParticipant? localParticipant;
    for (final participant in state.participants) {
      if (participant.isLocal) {
        localParticipant = participant;
        break;
      }
    }
    final healerName = state.sessionTitle.trim().isEmpty
        ? 'Your healer'
        : state.sessionTitle.trim();

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryLite,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.primaryLiteChip),
            ),
            child: Column(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryLiteChip),
                  ),
                  child: Icon(
                    Icons.groups_outlined,
                    color: AppColors.primary,
                    size: 32.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'You\'re connected',
                  style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.h),
                Text(
                  '$healerName will join shortly. Please stay on this screen.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 14.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Waiting for healer',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (localParticipant != null) ...[
            SizedBox(height: 24.h),
            Text(
              'Your preview',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: SizedBox(
                height: 180.h,
                width: double.infinity,
                child: AgoraVideoTile(
                  engine: state.engine,
                  uid: localParticipant.agoraUid,
                ),
              ),
            ),
          ],
          SizedBox(height: 120.h),
        ],
      ),
    );
  }
}
