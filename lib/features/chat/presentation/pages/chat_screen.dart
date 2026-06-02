import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../../common/widgets/common_image.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ChatBloc()..add(LoadChatHistory()),
      child: const ChatView(),
    );
  }
}

class ChatView extends StatefulWidget {
  final bool embedded;

  const ChatView({super.key, this.embedded = false});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatBody = Column(
        children: [
          _buildSessionStatusBar(),
          Expanded(
            child: Stack(
              children: [
                // Pattern Background
                _buildBackgroundContainer(),
                // Chat List
                Positioned.fill(
                  child: BlocListener<ChatBloc, ChatState>(
                    listener: (context, state) => _scrollToBottom(),
                    child: BlocBuilder<ChatBloc, ChatState>(
                      builder: (context, state) {
                        return ListView.builder(
                          controller: _scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 20.h,
                          ),
                          itemCount: state.messages.length + 1,
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 24.h),
                                child: Center(
                                  child: Text(
                                    'Today',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: const Color(0xff000000),
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                ),
                              );
                            }
                            final msg = state.messages[index - 1];
                            return ChatBubble(
                              message: msg,
                              avatar: msg.isMe
                                  ? 'assets/image/shortphoto.png'
                                  : state.healerImage,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildTypingIndicator(),
          _buildInputArea(context),
          if (widget.embedded) SizedBox(height: 88.h),
        ],
      );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: chatBody,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: !widget.embedded,
      leading: widget.embedded
          ? null
          : IconButton(
              icon: Icon(Icons.chevron_left, color: Colors.black, size: 28.sp),
              onPressed: () => context.pop(),
            ),
      titleSpacing: 0,
      title: BlocBuilder<ChatBloc, ChatState>(
        builder: (context, state) {
          return Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25.r),
                    child: CommonImage(
                      path: state.healerImage,
                      width: 40.w,
                      height: 40.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.healerName, style: AppTextStyles.bodyMedium),
                  Text(
                    '₹ ${state.healerPrice.toInt().toString()}/min',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: const Color(0xff717171),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      actions: [
        BlocBuilder<ChatBloc, ChatState>(
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
        IconButton(
          constraints: BoxConstraints(minWidth: 18.w, minHeight: 18.w),
          icon: Icon(Icons.more_vert, color: Colors.black, size: 24.sp),
          onPressed: () {},
        ),
        SizedBox(width: 8.w),
      ],
    );
  }

  Widget _buildSessionStatusBar() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFFF0F0F0)),
          ),
          child: Row(
            children: [
              Text(
                state.sessionTime,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff484848),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(Icons.circle, color: const Color(0xff1E1E1E), size: 10.sp),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Container(
                    height: 1,
                    color: const Color(0xFFF0F0F0),
                    child: Center(
                      child: Row(
                        children: List.generate(
                          20,
                          (index) => Expanded(
                            child: Container(
                              width: 2,
                              height: 1,
                              color: index % 2 == 0
                                  ? const Color(0xFFD9D9D9)
                                  : Colors.transparent,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Icon(Icons.circle, color: const Color(0xff1E1E1E), size: 10.sp),
              SizedBox(width: 4.w),
              Text(
                '₹ ${state.sessionCost.toInt().toString()}.00',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: const Color(0xff484848),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackgroundContainer() {
    return CommonImage(
      path: 'assets/image/chatbg.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildTypingIndicator() {
    return BlocBuilder<ChatBloc, ChatState>(
      builder: (context, state) {
        if (!state.isTyping) return const SizedBox.shrink();
        return Padding(
          padding: EdgeInsets.only(left: 20.w, bottom: 8.h),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${state.healerName.split(' ')[1]} is Typing ....',
              style: AppTextStyles.bodySmall.copyWith(
                color: const Color(0xff6B6B6B),
                fontWeight: FontWeight.w500,
                fontSize: 13.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputArea(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Row(
        children: [
          CommonImage(
            path: 'assets/image/uil_calender.png',
            height: 26.w,
            width: 26.w,
          ),

          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null && context.mounted) {
                context.read<ChatBloc>().add(SendImageMessage(image.path));
              }
            },
            child: CommonImage(
              path: 'assets/image/ci_paperclip-attechment-horizontal.png',
              height: 30.w,
              width: 26.w,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Write a message',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: const Color(0xff9E9E9E),
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                context.read<ChatBloc>().add(SendMessage(value));
                _controller.clear();
              },
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () {
              context.read<ChatBloc>().add(SendMessage(_controller.text));
              _controller.clear();
            },
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(13.r),
              ),
              child: CommonImage(
                path: 'assets/image/solar_map-arrow-right-bold.png',
                height: 25.w,
                width: 25.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
