import 'package:auto_skeleton/auto_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../agora/presentation/models/call_phase.dart';
import '../../../agora/presentation/models/call_route_args.dart';
import '../../../agora/presentation/widgets/call_error_body.dart';
import '../../../agora/presentation/widgets/call_missing_args_screen.dart';
import '../../../receipt/presentation/models/receipt_args.dart';
import '../bloc/group_session_bloc.dart';
import '../bloc/group_session_event.dart';
import '../bloc/group_session_state.dart';
import '../widgets/group_participant_card.dart';
import '../widgets/group_session_healer_waiting_body.dart';
import '../widgets/main_speaker_card.dart';

class GroupSessionScreen extends StatelessWidget {
  final CallRouteArgs? args;

  const GroupSessionScreen({super.key, this.args});

  @override
  Widget build(BuildContext context) {
    final callArgs = args;
    if (callArgs == null) {
      return const CallMissingArgsScreen(title: 'Group session unavailable');
    }

    return BlocProvider(
      create: (_) =>
          GroupSessionBloc(args: callArgs)..add(LoadSession(callArgs)),
      child: const GroupSessionView(),
    );
  }
}

class GroupSessionView extends StatelessWidget {
  const GroupSessionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: BlocConsumer<GroupSessionBloc, GroupSessionState>(
        listenWhen: (prev, curr) =>
            curr.phase == CallPhase.ended && prev.phase != CallPhase.ended,
        listener: (context, state) {
          if (state.endSummary != null) {
            final receiptArgs = ReceiptArgs.fromGroupSessionEnd(
              summary: state.endSummary!,
              sessionDuration: state.duration,
              healerName: state.sessionTitle,
              autoDisconnected: state.sessionAutoDisconnected,
            );
            context.pushReplacement('/receipt', extra: receiptArgs);
            return;
          }
          if (state.sessionAutoDisconnected) {
            final receiptArgs = ReceiptArgs(
              healerName: state.sessionTitle,
              healerRole: 'Healer',
              healerImage: 'assets/image/doctorprofile.png',
              startTime: '--:--',
              endTime: '--:--',
              duration: _groupDurationLabel(state.duration),
              date: '--',
              mode: 'Video Consultation',
              healingType: 'Group Healing',
              sessionType: 'Group (auto-ended)',
              totalAmount: 0,
              receiptId: '',
            );
            context.pushReplacement('/receipt', extra: receiptArgs);
            return;
          }
          if (state.sessionEndedByHealer) {
            final receiptArgs = ReceiptArgs(
              healerName: state.sessionTitle,
              healerRole: 'Healer',
              healerImage: 'assets/image/doctorprofile.png',
              startTime: '--:--',
              endTime: '--:--',
              duration: _groupDurationLabel(state.duration),
              date: '--',
              mode: 'Video Consultation',
              healingType: 'Group Healing',
              sessionType: 'Group',
              totalAmount: 0,
              receiptId: '',
            );
            context.pushReplacement('/receipt', extra: receiptArgs);
            return;
          }
          context.pop();
        },
        builder: (context, state) {
          if (state.phase == CallPhase.error) {
            return CallErrorBody(
              message: state.errorMessage ?? 'Something went wrong',
              onRetry: () =>
                  context.read<GroupSessionBloc>().add(RetrySession()),
            );
          }

          if (state.isLoading) {
            return AutoSkeleton(
              enabled: true,
              child: const Center(child: Text('Connecting to group session…')),
            );
          }

          if (state.isWaitingForHealer) {
            return Stack(
              children: [
                GroupSessionHealerWaitingBody(state: state),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomControlBar(context, state),
                ),
              ],
            );
          }

          if (state.participants.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Text(
                  'Waiting for participants to join…',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final mainSpeaker = state.participants.firstWhere(
            (p) => p.isMainSpeaker && !p.isLocal,
            orElse: () => state.participants.firstWhere(
              (p) => !p.isLocal,
              orElse: () => state.participants.first,
            ),
          );
          final otherParticipants = state.participants
              .where((p) => p.agoraUid != mainSpeaker.agoraUid)
              .toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    MainSpeakerCard(
                      participant: mainSpeaker,
                      duration: state.duration,
                      engine: state.engine,
                    ),
                    SizedBox(height: 20.h),
                    if (otherParticipants.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: otherParticipants.length,
                        itemBuilder: (context, index) {
                          return GroupParticipantCard(
                            participant: otherParticipants[index],
                            engine: state.engine,
                          );
                        },
                      ),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottomControlBar(context, state),
              ),
            ],
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.chevron_left, color: Colors.black, size: 28.sp),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Text(
        'Group Session',
        style: AppTextStyles.titleMedium,
      ),
    );
  }

  Widget _buildBottomControlBar(BuildContext context, GroupSessionState state) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCircleButton(
            icon: state.isMyMuted ? 'microphone-slash.png' : 'Microphone.png',
            onPressed: () =>
                context.read<GroupSessionBloc>().add(ToggleMyMute()),
          ),
          _buildCircleButton(
            icon: 'eva_video-fill.png',
            onPressed: () =>
                context.read<GroupSessionBloc>().add(ToggleMyVideo()),
          ),
          _buildCircleButton(
            icon: 'PhoneDisconnect.png',
            onPressed: () =>
                context.read<GroupSessionBloc>().add(EndSession()),
            backgroundColor: const Color(0xFFF52D56),
            iconColor: Colors.white,
            isLarge: true,
            size: 64.w,
            iconSize: 32.w,
          ),
          _buildCircleButton(
            icon: 'ChatCircleDots.png',
            onPressed: () => context.push('/chat'),
          ),
          _buildCircleButton(
            icon: 'Vector.png',
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required String icon,
    required VoidCallback onPressed,
    Color backgroundColor = const Color(0xFFF5F7F9),
    Color iconColor = Colors.black,
    double size = 54,
    double iconSize = 20,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size.w,
        height: size.w,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CommonImage(
            path: 'assets/image/$icon',
            height: iconSize.w,
            width: iconSize.w,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

String _groupDurationLabel(Duration duration) {
  final totalSeconds = duration.inSeconds;
  if (totalSeconds <= 0) return '0m';
  final mins = totalSeconds ~/ 60;
  final secs = totalSeconds % 60;
  if (mins > 0) return secs > 0 ? '${mins}m ${secs}s' : '${mins}m';
  return '${secs}s';
}
