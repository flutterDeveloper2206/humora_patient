import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/common/utils/common_flushbar.dart';
import 'package:humora_patient/core/constants/app_colors.dart';
import 'package:humora_patient/core/constants/app_text_styles.dart';
import 'package:humora_patient/common/widgets/common_image.dart';
import 'package:humora_patient/features/healers/data/models/healer_model.dart';
import 'package:humora_patient/features/healers/presentation/widgets/availability_chip.dart';
import 'package:humora_patient/features/live_consultation/data/datasource/live_hub_service.dart';
import 'package:humora_patient/features/live_consultation/presentation/models/live_consultation_args.dart';
import 'package:humora_patient/features/live_consultation/presentation/utils/live_wallet_preflight.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'healer_rating_row.dart';

class HealerCard extends StatelessWidget {
  final HealerModel healer;
  final bool isNext;
  final VoidCallback onTap;

  const HealerCard({
    super.key,
    required this.healer,
    this.isNext = true,
    required this.onTap,
  });

  bool get _showLiveActions => healer.isLiveOnline && !healer.isLiveBusy;

  Future<void> _startLiveConsultation(
    BuildContext context,
    int consultationType,
  ) async {
    final typeLabel = switch (consultationType) {
      0 => 'Chat',
      1 => 'Audio',
      _ => 'Video',
    };

    developer.log(
      'HealerCard → live request tapped\n'
      '   Healer: ${healer.name} (${healer.id})\n'
      '   Type: $typeLabel ($consultationType)\n'
      '   Live status: ${healer.liveStatus ?? 'unknown'}',
      name: 'HealerCard',
    );

    // if (!healer.isLiveOnline) {
    //   CommonFlushbar.error(
    //     context,
    //     'This healer is not online for live sessions right now.',
    //   );
    //   return;
    // }

    final canAfford = await LiveWalletPreflight.ensureCanAfford(
      context: context,
      liveCounselling: healer.liveCounsellingPricing,
      consultationType: consultationType,
      fallbackPricePerMinute: healer.feesPerMin,
    );
    if (!canAfford || !context.mounted) return;

    final args = LiveConsultationArgs(
      healerId: healer.id,
      healerName: healer.name,
      healerImage: healer.imageUrl,
      consultationType: consultationType,
      liveCounselling: healer.liveCounsellingPricing,
    );

    context.push('/live-request-waiting', extra: args);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Header Row: Avatar, Name, Specialization & Experience, Chevron
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: CommonImage(
                          path: healer.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            healer.name,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF2F5),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CommonImage(
                                        path: 'assets/image/Mask1.png',
                                        width: 14.w,
                                        height: 14.w,
                                        color: AppColors.primary,
                                        fit: BoxFit.cover,
                                      ),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: Text(
                                          healer.specialization,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyles.bodySmall.copyWith(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 11.sp,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '|',
                                style: TextStyle(
                                  color: AppColors.divider,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              CommonImage(
                                path: 'assets/image/Mask.png',
                                width: 16.w,
                                height: 16.w,
                                color: AppColors.textSecondary,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${healer.experienceYears} Years',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 12.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (isNext)
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                  ],
                ),
                SizedBox(height: 10.h),
                // 2. Rating Row
                HealerRatingRow(
                  rating: healer.rating,
                  reviewsCount: healer.reviewsCount,
                ),
                SizedBox(height: 10.h),
                // 3. Divider
                const Divider(color: AppColors.divider, thickness: 1, height: 1),
                SizedBox(height: 12.h),
                // 4. Price & Status Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: RichText(
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          children: [
                            const TextSpan(text: '₹ '),
                            TextSpan(
                              text: '${healer.feesPerMin}',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 26.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const TextSpan(text: '/min'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Flexible(
                      child: _HealerAvailabilityRow(healer: healer),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (healer.availability.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 58.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.zero,
                itemCount: healer.availability.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final avail = healer.availability[index];
                  return AvailabilityChip(
                    label: avail.date,
                    isAvailable: avail.isAvailable,
                    time: avail.time,
                  );
                },
              ),
            ),
          ],
          // if (_showLiveActions)
            _LiveConsultationFooter(
              onChat: () => _startLiveConsultation(context, 0),
              onAudio: () => _startLiveConsultation(context, 1),
              onVideo: () => _startLiveConsultation(context, 2),
            ),
        ],
      ),
    );
  }
}

class _LiveConsultationFooter extends StatefulWidget {
  final VoidCallback onChat;
  final VoidCallback onAudio;
  final VoidCallback onVideo;

  const _LiveConsultationFooter({
    required this.onChat,
    required this.onAudio,
    required this.onVideo,
  });

  @override
  State<_LiveConsultationFooter> createState() =>
      _LiveConsultationFooterState();
}

class _LiveConsultationFooterState extends State<_LiveConsultationFooter> {
  StreamSubscription<HubConnectionState>? _socketSub;
  HubConnectionState _socketState = LiveHubService.instance.state;

  @override
  void initState() {
    super.initState();
    _socketSub = LiveHubService.instance.connectionState.listen((state) {
      if (mounted) setState(() => _socketState = state);
    });
  }

  @override
  void dispose() {
    _socketSub?.cancel();
    super.dispose();
  }

  bool get _isConnected => _socketState == HubConnectionState.Connected;

  Color get _socketColor {
    return switch (_socketState) {
      HubConnectionState.Connected => const Color(0xFF16B783),
      HubConnectionState.Reconnecting ||
      HubConnectionState.Connecting => const Color(0xFFE6A817),
      _ => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _LiveActionButton(
            iconPath: 'assets/image/ChatCircleDots.png',
            label: 'Chat',
            onTap: widget.onChat,
          ),
          SizedBox(width: 24.w),
          _LiveActionButton(
            iconPath: 'assets/image/hugeicons_call-02.png',
            label: 'Call',
            onTap: widget.onAudio,
          ),
          SizedBox(width: 24.w),
          _LiveActionButton(
            iconPath: 'assets/image/eva_video-fill.png',
            label: 'Video',
            onTap: widget.onVideo,
          ),
        ],
      ),
    );
  }
}

class _LiveActionButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const _LiveActionButton({
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: const Color(0xFFFFF2F5),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Container(
              width: 44.w,
              height: 44.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: CommonImage(
                path: iconPath,
                width: 20.w,
                height: 20.w,
                color: AppColors.primary,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }
}

class _HealerAvailabilityRow extends StatelessWidget {
  final HealerModel healer;

  const _HealerAvailabilityRow({required this.healer});

  @override
  Widget build(BuildContext context) {
    if (healer.isLiveOnline) {
      return _StatusChip(
        emoji: '🟢',
        label: 'Live Online',
        textColor: const Color(0xFF16B783),
        bgColor: const Color(0xFFE8F8EF),
        borderColor: const Color(0xFFB8E6C8),
      );
    }
    if (healer.isLiveBusy) {
      return _StatusChip(
        emoji: '🟡',
        label: 'Busy',
        textColor: const Color(0xFFE6A817),
        bgColor: const Color(0xFFFFF8E6),
        borderColor: const Color(0xFFFFE4A8),
      );
    }
    if (healer.isAvailableNow) {
      return _StatusChip(
        emoji: '🟢',
        label: 'Available Now',
        textColor: const Color(0xFF16B783),
        bgColor: const Color(0xFFE8F8EF),
        borderColor: const Color(0xFFB8E6C8),
      );
    }
    return _StatusChip(
      emoji: '⚪',
      label: 'Not Available',
      textColor: AppColors.textSecondary,
      bgColor: const Color(0xFFF5F5F5),
      borderColor: AppColors.divider,
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String emoji;
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _StatusChip({
    required this.emoji,
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: 12.sp)),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 11.sp,
                height: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
