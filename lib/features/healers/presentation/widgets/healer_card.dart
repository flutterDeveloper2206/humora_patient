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
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFC),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30.r),
                      child: CommonImage(
                        path: healer.imageUrl,
                        width: 50.w,
                        height: 50.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                healer.name,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15.sp,
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
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              CommonImage(
                                path: 'assets/image/Mask1.png',
                                width: 19.w,
                                height: 19.w,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                healer.specialization,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                width: 4.w,
                                height: 4.w,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD9D9D9),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              CommonImage(
                                path: 'assets/image/Mask.png',
                                width: 19.w,
                                height: 19.w,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                '${healer.experienceYears} Years',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          HealerRatingRow(
                            rating: healer.rating,
                            reviewsCount: healer.reviewsCount,
                          ),
                          SizedBox(height: 8.h),
                          _HealerAvailabilityRow(healer: healer),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              CommonImage(
                                path: 'assets/image/price.png',
                                width: 10.w,
                                height: 14.w,
                                fit: BoxFit.cover,
                              ),
                              Text(
                                ' ${healer.feesPerMin}/min',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5.h),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (healer.availability.isNotEmpty)
            SizedBox(
              height: 48.h,
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
                  );
                },
              ),
            ),
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
      padding: EdgeInsets.only(top: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Container(
              //   width: 7.w,
              //   height: 7.w,
              //   decoration: BoxDecoration(
              //     color: _socketColor,
              //     shape: BoxShape.circle,
              //     boxShadow: [
              //       BoxShadow(
              //         color: _socketColor.withValues(alpha: 0.45),
              //         blurRadius: 4,
              //         spreadRadius: 1,
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(width: 6.w),
              // Text(
              //   _isConnected
              //       ? 'Live socket connected'
              //       : 'Live socket ${LiveHubService.connectionLabel(_socketState).toLowerCase()}',
              //   style: AppTextStyles.caption.copyWith(
              //     color: _socketColor,
              //     fontSize: 10.sp,
              //     fontWeight: FontWeight.w500,
              //   ),
              // ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Expanded(
                child: _LiveActionButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Chat',
                  onTap: widget.onChat,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _LiveActionButton(
                  icon: Icons.call,
                  label: 'Audio',
                  onTap: widget.onAudio,
                ),
              ),
              SizedBox(width: 6.w),
              Expanded(
                child: _LiveActionButton(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: widget.onVideo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LiveActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _LiveActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primaryLite,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppColors.primaryLiteChip),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.primary, size: 14.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
        icon: Icons.circle,
        label: 'Live Online',
        color: const Color(0xFF16B783),
        iconSize: 10.sp,
      );
    }
    if (healer.isLiveBusy) {
      return _StatusChip(
        icon: Icons.schedule,
        label: 'Busy',
        color: const Color(0xFFE6A817),
      );
    }
    if (healer.isAvailableNow) {
      return _StatusChip(
        icon: Icons.check_circle,
        label: 'Available Now',
        color: const Color(0xFF16B783),
      );
    }
    return Text(
      'Not available',
      style: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w400,
        fontSize: 14.sp,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double? iconSize;

  const _StatusChip({
    required this.icon,
    required this.label,
    required this.color,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: iconSize ?? 18.sp),
        SizedBox(width: 4.w),
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: color,
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }
}
