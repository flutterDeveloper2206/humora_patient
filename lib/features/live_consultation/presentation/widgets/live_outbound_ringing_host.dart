import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/widgets/call_ringing_body.dart';
import '../../../booking/presentation/widgets/insufficient_wallet_dialog.dart';
import '../../data/models/live_models.dart';
import '../bloc/live_request_bloc.dart';
import '../bloc/live_request_event.dart';
import '../bloc/live_request_state.dart';
import '../models/live_consultation_args.dart';
import '../utils/live_request_routing.dart';

/// Sends outbound live request and shows [CallRingingBody] until healer accepts.
class LiveOutboundRingingHost extends StatefulWidget {
  final LiveConsultationArgs args;
  final CallMode mode;

  const LiveOutboundRingingHost({
    super.key,
    required this.args,
    required this.mode,
  });

  @override
  State<LiveOutboundRingingHost> createState() =>
      _LiveOutboundRingingHostState();
}

class _LiveOutboundRingingHostState extends State<LiveOutboundRingingHost> {
  bool _navigated = false;

  Future<void> _onAccepted(
    BuildContext context,
    RequestAcceptedPayload payload,
  ) async {
    if (_navigated || !mounted) return;
    _navigated = true;
    await navigateAfterLiveRequestAccepted(
      context: context,
      args: widget.args,
      payload: payload,
    );
  }

  void _cancel(BuildContext context) {
    context.read<LiveRequestBloc>().add(const CancelRequest());
    safePop(context);
  }

  String get _sessionLabel =>
      widget.mode == CallMode.video ? 'Video call' : 'Voice call';

  CallRingingMode _ringingMode(LiveRequestState state) =>
      state is LiveRequestLoading
          ? CallRingingMode.connecting
          : CallRingingMode.ringing;

  String? _statusSubtitle(LiveRequestState state) {
    final name = widget.args.healerName;
    if (state is LiveRequestQueued) {
      final rank = state.position <= 1 ? '1st' : '${state.position}th';
      return 'You are $rank in queue for $name';
    }
    if (state is LiveRequestWaiting && state.requestId.isEmpty) {
      return 'Calling $name — we will keep trying';
    }
    if (state is LiveRequestRejected ||
        state is LiveRequestExpired ||
        state is LiveRequestError) {
      return 'Still trying to reach $name';
    }
    if (state is LiveRequestWaiting || state is LiveRequestQueued) {
      return 'Waiting for healer to accept';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveRequestBloc()
        ..add(
          StartRequest(
            healerId: widget.args.healerId,
            consultationType: widget.args.consultationType,
          ),
        ),
      child: BlocConsumer<LiveRequestBloc, LiveRequestState>(
        listenWhen: (prev, curr) => curr is! LiveRequestLoading,
        listener: (context, state) {
          if (state is LiveRequestAccepted) {
            _onAccepted(context, state.payload);
          } else if (state is LiveRequestWalletError) {
            final wallet = state.walletError;
            InsufficientWalletDialog.show(
              context: context,
              message: wallet.message,
              requiredAmount: wallet.requiredBalance,
              availableAmount: wallet.currentBalance,
            );
          }
        },
        builder: (context, state) {
          if (state is LiveRequestWalletError) {
            return _buildWalletError(context);
          }

          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
              _cancel(context);
            },
            child: Scaffold(
              backgroundColor: Colors.white,
              body: CallRingingBody(
                sessionLabel: _sessionLabel,
                name: widget.args.healerName,
                imagePath: widget.args.healerImage,
                mode: _ringingMode(state),
                statusSubtitle: _statusSubtitle(state),
                bottom: Padding(
                  padding: EdgeInsets.only(bottom: 32.h),
                  child: Center(
                    child: CallRingingEndButton(
                      onPressed: () => _cancel(context),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWalletError(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64.sp,
              color: AppColors.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Insufficient wallet balance',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            CommonButton(
              text: 'Go to Wallet',
              backgroundColor: AppColors.darkButton,
              borderRadius: 12.r,
              onPressed: () => context.push('/wallet'),
            ),
            SizedBox(height: 12.h),
            TextButton(
              onPressed: () => safePop(context),
              child: Text(
                'Go back',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
