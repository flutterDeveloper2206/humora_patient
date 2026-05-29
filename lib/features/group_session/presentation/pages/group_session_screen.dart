import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:humora_patient/common/widgets/common_image.dart' show CommonImage;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../bloc/group_session_bloc.dart';
import '../bloc/group_session_event.dart';
import '../bloc/group_session_state.dart';
import '../widgets/group_participant_card.dart';
import '../widgets/main_speaker_card.dart';

class GroupSessionScreen extends StatelessWidget {
  const GroupSessionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupSessionBloc()..add(LoadSession()),
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
      body: BlocBuilder<GroupSessionBloc, GroupSessionState>(
        builder: (context, state) {
          if (state.participants.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final mainSpeaker = state.participants.firstWhere(
            (p) => p.isMainSpeaker,
          );
          final otherParticipants = state.participants
              .where((p) => !p.isMainSpeaker)
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
                    ),
                    SizedBox(height: 20.h),
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
                        );
                      },
                    ),
                    SizedBox(height: 120.h), // Space for bottom bar
                  ],
                ),
              ),

              // Bottom Bar
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
        icon: Icon(Icons.chevron_left, color: Colors.black, size: 15.sp),
        onPressed: () => context.pop(),
      ),
      titleSpacing: 0,
      title: Text(
        'Group Sessions',
        style: AppTextStyles.titleMedium
      ),
      actions: [
        BlocBuilder<GroupSessionBloc, GroupSessionState>(
          builder: (context, state) {
            return Container(
              // margin: EdgeInsets.symmetric(vertical: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                borderRadius: BorderRadius.circular(21.r),
                border: Border.all(color: const Color(0xFFF0F0F0)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xfFFB5B5B26).withOpacity(0.15),
                    blurRadius: 1.5,
                    spreadRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CommonImage(
                    path: 'assets/image/commonwallet.png',
                    height: 18.w,
                    width: 18.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    '₹ ${state.walletBalance.toInt().toString()}.00',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Color(0xff5B5B5B),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        SizedBox(width: 20.w),
      ],
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
            isLarge: false,
            backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 54.w,
            iconSize: 20.w,
            icon: state.isMyMuted ? 'Microphone.png' : 'microphone-slash.png',
            onPressed: () =>
                context.read<GroupSessionBloc>().add(ToggleMyMute()),
          ),

          _buildCircleButton(
            icon: state.isMyVideoOff
                ? 'eva_video-fill.png'
                : 'eva_video-fill.png',
            backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 54.w,
            iconSize: 20.w,
            onPressed: () =>
                context.read<GroupSessionBloc>().add(ToggleMyVideo()),
          ),
          _buildCircleButton(
            icon: 'PhoneDisconnect.png',
            onPressed: () {
              context.push('/payment-method');
            },
            backgroundColor: const Color(0xFFF52D56),
            iconColor: Colors.white,
            isLarge: true,
            size: 64.w,
            iconSize: 32.w,
          ),
          _buildCircleButton(
            icon: 'ChatCircleDots.png',
            onPressed: () {},
            backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 54.w,
            iconSize: 20.w,
          ),
          _buildCircleButton(icon: 'Vector.png', onPressed: () {}, backgroundColor: const Color(0xFFF5F7F9),
            iconColor: Colors.black,
            size: 54.w,
            iconSize: 20.w,),
        ],
      ),
    );
  }


  Widget _buildCircleButton({
    required String icon,
    required VoidCallback onPressed,
    required  Color backgroundColor,
    required Color iconColor,
    required double size,
    required double iconSize,
    bool isLarge = false,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: isLarge
                  ? const Color(0xFFF52D56).withOpacity(0.25)
                  : Colors.black.withOpacity(0.03),
              blurRadius: isLarge ? 20 : 10,
              offset: Offset(0, isLarge ? 8 : 4),
            ),
          ],
        ),
        child: Center(
          child: CommonImage(
            path: 'assets/image/$icon',
            height: iconSize,
            width: iconSize,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
