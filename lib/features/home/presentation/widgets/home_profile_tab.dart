import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_textfield.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../chat/presentation/models/chat_session_args.dart';

/// Dev shortcuts aligned with integration docs:
/// - Chat: GET /chat/access → history → JoinChat (handled by ChatSessionBloc)
/// - Calls: scheduled uses /booking/{id}/agora-token; live uses /agora/token/{id}
class HomeProfileTab extends StatefulWidget {
  const HomeProfileTab({super.key});

  @override
  State<HomeProfileTab> createState() => _HomeProfileTabState();
}

class _HomeProfileTabState extends State<HomeProfileTab> {
  final TextEditingController _bookingIdController = TextEditingController();
  bool _isLiveSession = false;

  static const _testHealerName = 'Test Healer';

  @override
  void dispose() {
    _bookingIdController.dispose();
    super.dispose();
  }

  String? _bookingIdOrWarn() {
    final id = _bookingIdController.text.trim();
    if (id.isEmpty) {
      CommonFlushbar.error(context, 'Enter a booking ID first');
      return null;
    }
    return id;
  }

  void _openChat() {
    final bookingId = _bookingIdOrWarn();
    if (bookingId == null) return;
    context.push(
      '/chat/$bookingId',
      extra: ChatSessionArgs(
        bookingId: bookingId,
        isLiveSession: _isLiveSession,
        healerName: _testHealerName,
      ),
    );
  }

  void _openVoiceCall() {
    final bookingId = _bookingIdOrWarn();
    if (bookingId == null) return;
    context.push(
      '/voice-call',
      extra: CallRouteArgs(
        bookingId: bookingId,
        healerName: _testHealerName,
        mode: CallMode.audio,
        isLive: _isLiveSession,
      ),
    );
  }

  void _openVideoCall() {
    final bookingId = _bookingIdOrWarn();
    if (bookingId == null) return;
    context.push(
      '/video-call',
      extra: CallRouteArgs(
        bookingId: bookingId,
        healerName: _testHealerName,
        mode: CallMode.video,
        isLive: _isLiveSession,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 120.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 64.sp,
                color: AppColors.textHint,
              ),
              SizedBox(height: 16.h),
              Text(
                'Profile',
                textAlign: TextAlign.center,
                style: AppTextStyles.h3.copyWith(fontSize: 18.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Profile settings coming soon.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 32.h),
              Text(
                'Session testing (dev)',
                style: AppTextStyles.h3.copyWith(fontSize: 16.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                'Chat runs access check + hub per ChatFlow doc. '
                'Toggle live for on-demand token path.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              CommonTextField(
                controller: _bookingIdController,
                hintText: 'Booking ID',
                labelText: 'Booking ID',
              ),
              SizedBox(height: 12.h),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Live on-demand session',
                  style: AppTextStyles.bodyMedium,
                ),
                subtitle: Text(
                  _isLiveSession
                      ? 'Uses GET /agora/token/{id} + live billing hub'
                      : 'Uses GET /booking/{id}/agora-token (scheduled)',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                value: _isLiveSession,
                activeThumbColor: AppColors.primary,
                onChanged: (value) => setState(() => _isLiveSession = value),
              ),
              SizedBox(height: 8.h),
              CommonButton(
                text: 'Open Chat',
                onPressed: _openChat,
                borderRadius: 12.r,
              ),
              SizedBox(height: 12.h),
              CommonButton(
                text: 'Open Audio Call',
                onPressed: _openVoiceCall,
                backgroundColor: AppColors.darkButton,
                borderRadius: 12.r,
              ),
              SizedBox(height: 12.h),
              CommonButton(
                text: 'Open Video Call',
                onPressed: _openVideoCall,
                borderRadius: 12.r,
              ),
              SizedBox(height: 32.h),
              OutlinedButton.icon(
                onPressed: () => context.push('/live-history'),
                icon: Icon(Icons.history, size: 20.sp, color: AppColors.primary),
                label: Text(
                  'Live session history',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: AppColors.primaryLiteChip),
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
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
