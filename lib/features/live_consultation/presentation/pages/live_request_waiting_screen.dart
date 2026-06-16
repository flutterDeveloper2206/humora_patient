import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../booking/presentation/widgets/insufficient_wallet_dialog.dart';
import '../../data/models/live_models.dart';
import '../bloc/live_request_bloc.dart';
import '../bloc/live_request_event.dart';
import '../bloc/live_request_state.dart';
import '../models/live_consultation_args.dart';
import '../utils/live_request_routing.dart';

class LiveRequestWaitingScreen extends StatelessWidget {
  final LiveConsultationArgs args;

  const LiveRequestWaitingScreen({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LiveRequestBloc()
        ..add(
          StartRequest(
            healerId: args.healerId,
            consultationType: args.consultationType,
          ),
        ),
      child: LiveRequestWaitingView(args: args),
    );
  }
}

class LiveRequestWaitingView extends StatefulWidget {
  final LiveConsultationArgs args;

  const LiveRequestWaitingView({super.key, required this.args});

  @override
  State<LiveRequestWaitingView> createState() => _LiveRequestWaitingViewState();
}

class _LiveRequestWaitingViewState extends State<LiveRequestWaitingView> {
  Timer? _countdownTimer;
  int _secondsLeft = 60;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown(DateTime? expiresAt) {
    _countdownTimer?.cancel();
    final now = DateTime.now();
    if (expiresAt != null) {
      _secondsLeft = expiresAt.difference(now).inSeconds.clamp(0, 60);
    } else {
      _secondsLeft = 60;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _onAccepted(
    BuildContext context,
    RequestAcceptedPayload payload,
  ) async {
    await navigateAfterLiveRequestAccepted(
      context: context,
      args: widget.args,
      payload: payload,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LiveRequestBloc, LiveRequestState>(
      listenWhen: (prev, curr) => curr is! LiveRequestLoading,
      listener: (context, state) {
        if (state is LiveRequestWaiting) {
          _startCountdown(state.expiresAt);
        } else if (state is LiveRequestAccepted) {
          _onAccepted(context, state.payload);
        } else if (state is LiveRequestWalletError) {
          final wallet = state.walletError;
          InsufficientWalletDialog.show(
            context: context,
            message: wallet.message,
            requiredAmount: wallet.requiredBalance,
            availableAmount: wallet.currentBalance,
          );
        } else if (state is LiveRequestExpired && _secondsLeft > 0) {
          setState(() => _secondsLeft = 0);
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            context.read<LiveRequestBloc>().add(const CancelRequest());
            safePop(context);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.close, color: AppColors.textPrimary, size: 22.sp),
                onPressed: () {
                  context.read<LiveRequestBloc>().add(const CancelRequest());
                  safePop(context);
                },
              ),
              title: Text(
                'Waiting for healer',
                style: AppTextStyles.titleMedium.copyWith(fontSize: 18.sp),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildBody(context, state),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, LiveRequestState state) {
    if (state is LiveRequestLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (state is LiveRequestRejected ||
        state is LiveRequestExpired ||
        state is LiveRequestError) {
      return _buildResultState(context, state);
    }

    if (state is LiveRequestWalletError) {
      return _buildWalletError(context);
    }

    final hubBanner = state is LiveRequestWaiting && !state.hubConnected;

    return Column(
      children: [
        if (hubBanner) ...[
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLite,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              'Live socket unavailable — checking status every few seconds. '
              'You will still be notified when the healer responds.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.h),
        ],
        SizedBox(height: hubBanner ? 16.h : 48.h),
        CommonImage(
          path: widget.args.healerImage,
          width: 120.w,
          height: 120.w,
          fit: BoxFit.cover,
          borderRadius: 60.r,
        ),
        SizedBox(height: 24.h),
        Text(
          widget.args.healerName,
          style: AppTextStyles.h3.copyWith(fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Waiting for the healer to accept your request…',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),
        _CountdownRing(secondsLeft: _secondsLeft),
        SizedBox(height: 16.h),
        Text(
          'Request expires in $_secondsLeft s',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
        ),
        const Spacer(),
        CommonButton(
          text: 'Cancel Request',
          backgroundColor: AppColors.darkButton,
          borderRadius: 12.r,
          height: 52.h,
          onPressed: () {
            context.read<LiveRequestBloc>().add(const CancelRequest());
            safePop(context);
          },
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildWalletError(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.account_balance_wallet_outlined,
            size: 64.sp, color: AppColors.primary),
        SizedBox(height: 16.h),
        Text(
          'Insufficient wallet balance',
          style: AppTextStyles.h3,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 8.h),
        Text(
          'Add money to your wallet and try again.',
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
    );
  }

  Widget _buildResultState(BuildContext context, LiveRequestState state) {
    final (icon, title, message) = switch (state) {
      LiveRequestRejected s => (
          Icons.cancel_outlined,
          'Request declined',
          s.message,
        ),
      LiveRequestExpired _ => (
          Icons.timer_off_outlined,
          'Request expired',
          'The healer did not respond in time. Please try again.',
        ),
      LiveRequestError s => (
          Icons.error_outline,
          'Something went wrong',
          s.message,
        ),
      _ => (Icons.info_outline, 'Request', ''),
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64.sp, color: AppColors.primary),
        SizedBox(height: 16.h),
        Text(title, style: AppTextStyles.h3, textAlign: TextAlign.center),
        SizedBox(height: 8.h),
        Text(
          message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 32.h),
        if (state is LiveRequestError || state is LiveRequestExpired)
          CommonButton(
            text: 'Retry',
            borderRadius: 12.r,
            onPressed: () =>
                context.read<LiveRequestBloc>().add(const RetryRequest()),
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
    );
  }
}

class _CountdownRing extends StatelessWidget {
  final int secondsLeft;

  const _CountdownRing({required this.secondsLeft});

  @override
  Widget build(BuildContext context) {
    final progress = secondsLeft / 60.0;
    return SizedBox(
      width: 120.w,
      height: 120.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120.w,
            height: 120.w,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 6,
              backgroundColor: AppColors.primaryLite,
              color: AppColors.primary,
            ),
          ),
          Text(
            '$secondsLeft',
            style: AppTextStyles.h1.copyWith(
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
