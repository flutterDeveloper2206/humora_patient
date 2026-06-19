import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../../common/utils/common_flushbar.dart';
import '../../../../common/utils/safe_navigation.dart';
import '../../../../common/widgets/common_button.dart';
import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../booking/presentation/widgets/insufficient_wallet_dialog.dart';
import '../../../live_consultation/presentation/utils/live_end_navigator.dart';
import '../../../live_consultation/presentation/bloc/live_request_bloc.dart';
import '../../../live_consultation/presentation/bloc/live_request_event.dart';
import '../../../live_consultation/presentation/bloc/live_request_state.dart';
import '../../../live_consultation/presentation/bloc/live_session_cubit.dart';
import '../../data/models/chat_models.dart';
import '../bloc/chat_session_bloc.dart';
import '../bloc/chat_session_event.dart';
import '../bloc/chat_session_state.dart';
import '../models/chat_session_args.dart';
import '../widgets/chat_booking_group_header.dart';
import '../widgets/chat_composer.dart';
import '../widgets/chat_waiting_room.dart';
import '../widgets/session_message_bubble.dart';
import '../widgets/system_message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatSessionPage extends StatelessWidget {
  final String bookingId;
  final ChatSessionArgs? args;

  const ChatSessionPage({super.key, required this.bookingId, this.args});

  ChatSessionArgs get _resolvedArgs =>
      args ?? ChatSessionArgs(bookingId: bookingId);

  @override
  Widget build(BuildContext context) {
    final resolved = _resolvedArgs.copyWith(bookingId: bookingId);
    final pending = resolved.pendingLiveRequest;

    if (pending != null) {
      return BlocProvider(
        create: (_) => LiveRequestBloc()
          ..add(StartRequest(healerId: pending.healerId, consultationType: 0)),
        child: ChatSessionView(
          bookingId: bookingId,
          healerName: resolved.healerName,
          otherUserProfile: resolved.otherUserProfile,
          isLiveSession: true,
          pendingLiveRequest: pending,
        ),
      );
    }

    final chatTree = BlocProvider(
      create: (_) =>
          ChatSessionBloc(args: resolved)..add(const StartChatSession()),
      child: ChatSessionView(
        bookingId: bookingId,
        healerName: resolved.healerName,
        otherUserProfile: resolved.otherUserProfile,
        isLiveSession: resolved.isLiveSession,
      ),
    );

    if (!resolved.isLiveSession || resolved.bookingId.isEmpty) return chatTree;

    return BlocProvider(
      create: (_) => LiveSessionCubit()..startMonitoring(bookingId),
      child: chatTree,
    );
  }
}

class ChatSessionView extends StatefulWidget {
  final String bookingId;
  final String? healerName;
  final String? otherUserProfile;
  final bool isLiveSession;
  final PendingLiveChatRequest? pendingLiveRequest;

  const ChatSessionView({
    super.key,
    required this.bookingId,
    this.healerName,
    this.otherUserProfile,
    this.isLiveSession = false,
    this.pendingLiveRequest,
  });

  @override
  State<ChatSessionView> createState() => _ChatSessionViewState();
}

class _ChatSessionViewState extends State<ChatSessionView>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _composerFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  String? _patientId;
  String? _editingMessageId;
  bool _isPickingAttachment = false;
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingAudio = false;
  bool _isRecordingLocked = false;
  double _recordingCancelProgress = 0;
  String? _recordingPath;
  Timer? _recordingTimer;
  Duration _recordingDuration = Duration.zero;
  late final AnimationController _recordingWaveController;
  Timer? _liveRequestCountdownTimer;
  int _liveRequestSecondsLeft = 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _recordingWaveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scrollController.addListener(_onScroll);
    _loadPatientId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (widget.pendingLiveRequest != null) return;
    context.read<ChatSessionBloc>().add(ChatAppLifecycleChanged(state));
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels <= 48) {
      context.read<ChatSessionBloc>().add(const LoadOlderChatMessages());
    }
  }

  Future<void> _loadPatientId() async {
    _patientId = await SessionManager.getPatientId();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveRequestCountdownTimer?.cancel();
    _recordingTimer?.cancel();
    _recordingWaveController.dispose();
    _audioRecorder.dispose();
    _controller.dispose();
    _composerFocusNode.dispose();
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

  bool _isMe(ChatMessageDto message) {
    if (_patientId != null &&
        _patientId!.isNotEmpty &&
        message.senderId == _patientId) {
      return true;
    }
    return message.senderRole.toLowerCase() == 'patient';
  }

  bool _canInteractWithMessage(
    ChatMessageDto message,
    ChatSessionActive? activeState,
  ) {
    if (activeState?.canCompose != true) return false;
    final activeBookingId = activeState?.activeBookingId;
    if (activeBookingId != null &&
        activeBookingId.isNotEmpty &&
        message.bookingId.isNotEmpty &&
        message.bookingId != activeBookingId) {
      return false;
    }
    if (message.isSystem || message.isDeleted || message.isPending) {
      return false;
    }
    if (message.messageId.isEmpty || message.messageId.startsWith('pending-')) {
      return false;
    }
    return true;
  }

  void _startEditingMessage(ChatMessageDto message) {
    setState(() {
      _editingMessageId = message.messageId;
      _controller.text = message.content;
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    });
    _composerFocusNode.requestFocus();
  }

  void _cancelEditingMessage() {
    if (_editingMessageId == null) return;
    setState(() {
      _editingMessageId = null;
      _controller.clear();
    });
  }

  void _submitComposer(ChatSessionActive? activeState) {
    final text = _controller.text.trim();
    if (text.isEmpty || activeState?.canCompose != true) return;

    if (_editingMessageId != null) {
      context.read<ChatSessionBloc>().add(
        EditChatMessage(messageId: _editingMessageId!, content: text),
      );
      _cancelEditingMessage();
      return;
    }

    context.read<ChatSessionBloc>().add(SendChatMessage(text));
    _controller.clear();
  }

  Future<void> _onAttachmentPressed(ChatSessionActive? activeState) async {
    if (activeState == null ||
        !activeState.canCompose ||
        activeState.isUploadingAttachment ||
        _isPickingAttachment) {
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _mediaActionTile(
                icon: Icons.photo_outlined,
                title: 'Image',
                onTap: () => Navigator.pop(ctx, 'image'),
              ),
              _mediaActionTile(
                icon: Icons.videocam_outlined,
                title: 'Video',
                onTap: () => Navigator.pop(ctx, 'video'),
              ),
              _mediaActionTile(
                icon: Icons.mic_none_outlined,
                title: _isRecordingAudio
                    ? 'Stop & send voice note'
                    : 'Record voice note',
                onTap: () => Navigator.pop(ctx, 'record-audio'),
              ),
              _mediaActionTile(
                icon: Icons.audio_file_outlined,
                title: 'Audio file',
                onTap: () => Navigator.pop(ctx, 'audio-file'),
              ),
              _mediaActionTile(
                icon: Icons.attach_file_outlined,
                title: 'File',
                onTap: () => Navigator.pop(ctx, 'file'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;

    _isPickingAttachment = true;
    try {
      switch (selected) {
        case 'image':
          await _pickAndSendImage();
          break;
        case 'video':
          await _pickAndSendVideo();
          break;
        case 'audio':
          break;
        case 'record-audio':
          if (_isRecordingAudio) {
            await _stopVoiceRecording(send: true);
          } else {
            await _startVoiceRecording();
          }
          break;
        case 'audio-file':
          await _pickAndSendAudioFile();
          break;
        case 'file':
          await _pickAndSendFile();
          break;
      }
    } finally {
      _isPickingAttachment = false;
    }
  }

  Future<void> _pickAndSendImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    final contentType = _mimeFromFilename(
      picked.name,
      fallback: picked.mimeType ?? 'image/jpeg',
    );
    _dispatchAttachment(
      bytes: bytes,
      fileName: picked.name,
      contentType: contentType,
      messageType: 'Image',
      thumbnailPath: picked.path,
    );
  }

  Future<void> _pickAndSendVideo() async {
    final picked = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    final ext = _fileExtension(picked.name);
    final fallback = ext == 'mov' ? 'video/quicktime' : 'video/mp4';
    final contentType = _mimeFromFilename(picked.name, fallback: fallback);
    _dispatchAttachment(
      bytes: bytes,
      fileName: picked.name,
      contentType: contentType,
      messageType: 'File',
    );
  }

  Future<void> _pickAndSendAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['m4a', 'aac', 'mp3', 'ogg', 'wav'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    final bytes = await _resolveBytes(file);
    if (bytes == null) return;
    final contentType = _mimeFromFilename(file.name, fallback: 'audio/mp4');
    _dispatchAttachment(
      bytes: bytes,
      fileName: file.name,
      contentType: contentType,
      messageType: 'Audio',
    );
  }

  Future<void> _startVoiceRecording() async {
    if (_isRecordingAudio) return;
    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission || !mounted) {
      if (mounted) {
        CommonFlushbar.error(context, 'Microphone permission is required.');
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _audioRecorder.start(
      const RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 64000,
        sampleRate: 44100,
      ),
      path: path,
    );

    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || !_isRecordingAudio) return;
      setState(() {
        _recordingDuration = Duration(
          seconds: _recordingDuration.inSeconds + 1,
        );
      });
    });
    setState(() {
      _isRecordingAudio = true;
      _isRecordingLocked = false;
      _recordingCancelProgress = 0;
      _recordingPath = path;
      _recordingDuration = Duration.zero;
    });
    _recordingWaveController.repeat();
    unawaited(HapticFeedback.mediumImpact());
  }

  Future<void> _stopVoiceRecording({required bool send}) async {
    if (!_isRecordingAudio) return;
    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (_) {}
    _recordingTimer?.cancel();

    if (!mounted) return;
    setState(() {
      _isRecordingAudio = false;
      _isRecordingLocked = false;
      _recordingCancelProgress = 0;
    });
    _recordingWaveController.stop();

    final finalPath = path ?? _recordingPath;
    final filePath = finalPath?.trim();
    _recordingPath = null;
    _recordingDuration = Duration.zero;
    if (filePath == null || filePath.isEmpty) return;

    if (!send) {
      try {
        await File(filePath).delete();
      } catch (_) {}
      return;
    }

    final file = File(filePath);
    if (!await file.exists()) return;
    final bytes = await file.readAsBytes();
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _dispatchAttachment(
      bytes: bytes,
      fileName: fileName,
      contentType: 'audio/mp4',
      messageType: 'Audio',
    );

    try {
      await file.delete();
    } catch (_) {}
  }

  String _recordingDurationLabel() {
    final m = _recordingDuration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final s = _recordingDuration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _onRecordLongPressStart(LongPressStartDetails details) async {
    final current = context.read<ChatSessionBloc>().state;
    if (current is! ChatSessionActive ||
        !current.canCompose ||
        current.isUploadingAttachment ||
        _isRecordingAudio) {
      return;
    }
    await _startVoiceRecording();
  }

  Future<void> _onMicTap(ChatSessionActive? activeState) async {
    if (activeState == null ||
        !activeState.canCompose ||
        activeState.isUploadingAttachment) {
      return;
    }
    if (_isRecordingAudio) {
      await _stopVoiceRecording(send: true);
      return;
    }
    await _startVoiceRecording();
  }

  Future<void> _onRecordLongPressEnd(LongPressEndDetails details) async {
    if (!_isRecordingAudio || _isRecordingLocked) return;
    await _stopVoiceRecording(send: true);
  }

  Future<void> _onRecordLongPressMove(
    LongPressMoveUpdateDetails details,
  ) async {
    if (!_isRecordingAudio || _isRecordingLocked) return;

    const cancelThreshold = 120.0;
    const lockThreshold = 70.0;

    final dx = details.offsetFromOrigin.dx;
    final dy = details.offsetFromOrigin.dy;
    final cancelProgress = (-dx / cancelThreshold).clamp(0.0, 1.0);

    if (mounted) {
      setState(() {
        _recordingCancelProgress = cancelProgress;
      });
    }

    if (dy <= -lockThreshold) {
      if (!mounted) return;
      setState(() {
        _isRecordingLocked = true;
        _recordingCancelProgress = 0;
      });
      unawaited(HapticFeedback.heavyImpact());
      return;
    }

    if (cancelProgress >= 1) {
      unawaited(HapticFeedback.vibrate());
      await _stopVoiceRecording(send: false);
    }
  }

  Future<void> _pickAndSendFile() async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty || !mounted) return;
    final file = result.files.first;
    final bytes = await _resolveBytes(file);
    if (bytes == null) return;
    final contentType = _mimeFromFilename(file.name);
    _dispatchAttachment(
      bytes: bytes,
      fileName: file.name,
      contentType: contentType,
      messageType: 'File',
    );
  }

  Future<Uint8List?> _resolveBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    final path = file.path;
    if (path == null || path.isEmpty) return null;
    return XFile(path).readAsBytes();
  }

  void _dispatchAttachment({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    required String messageType,
    String? thumbnailPath,
  }) {
    final caption = _controller.text.trim();
    context.read<ChatSessionBloc>().add(
      SendChatAttachment(
        bytes: bytes,
        fileName: fileName,
        contentType: contentType,
        messageType: messageType,
        thumbnailPath: thumbnailPath,
        caption: caption,
      ),
    );
    _controller.clear();
  }

  String _fileExtension(String fileName) {
    final idx = fileName.lastIndexOf('.');
    if (idx < 0 || idx == fileName.length - 1) return '';
    return fileName.substring(idx + 1).toLowerCase();
  }

  String _mimeFromFilename(
    String fileName, {
    String fallback = 'application/octet-stream',
  }) {
    const map = <String, String>{
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'heic': 'image/heic',
      'pdf': 'application/pdf',
      'doc': 'application/msword',
      'docx':
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
      'xls': 'application/vnd.ms-excel',
      'xlsx':
          'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'ppt': 'application/vnd.ms-powerpoint',
      'pptx':
          'application/vnd.openxmlformats-officedocument.presentationml.presentation',
      'txt': 'text/plain',
      'mp4': 'video/mp4',
      'mov': 'video/quicktime',
      'm4a': 'audio/mp4',
      'aac': 'audio/mp4',
      'mp3': 'audio/mpeg',
      'ogg': 'audio/ogg',
      'wav': 'audio/wav',
    };
    return map[_fileExtension(fileName)] ?? fallback;
  }

  Widget _mediaActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.textPrimary),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }

  Widget _buildRecordingStrip() {
    final isLocked = _isRecordingLocked;
    return Container(
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 6.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Row(
        children: [
          Icon(
            isLocked ? Icons.lock : Icons.mic,
            color: AppColors.primary,
            size: 18.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Recording ${_recordingDurationLabel()}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  isLocked
                      ? 'Locked · Tap Send when ready'
                      : 'Swipe left to cancel · Swipe up to lock',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 10.sp,
                  ),
                ),
                if (!isLocked) ...[
                  SizedBox(height: 5.h),
                  _buildRecordingWaveform(),
                  SizedBox(height: 5.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: LinearProgressIndicator(
                      minHeight: 4.h,
                      value: _recordingCancelProgress,
                      backgroundColor: Colors.white,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (!isLocked)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.primaryLiteChip),
              ),
              child: Text(
                'Lock',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              _stopVoiceRecording(send: false);
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              unawaited(HapticFeedback.selectionClick());
              _stopVoiceRecording(send: true);
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'Send',
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingWaveform() {
    return AnimatedBuilder(
      animation: _recordingWaveController,
      builder: (context, _) {
        final t = _recordingWaveController.value;
        return SizedBox(
          height: 16.h,
          child: Row(
            children: List.generate(20, (index) {
              final phase = (t * 2 * math.pi) + (index * 0.55);
              final value = (math.sin(phase) + 1) / 2;
              final height = (3.h + (value * 10.h)).clamp(3.h, 13.h);
              return Container(
                width: 3.w,
                height: height,
                margin: EdgeInsets.only(right: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Future<void> _endLiveSession() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End session?'),
        content: const Text(
          'This will end your live consultation and stop billing.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('End', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    context.read<ChatSessionBloc>().add(const EndChatSession());
    await endLiveSessionAndNavigate(
      context: context,
      bookingId: widget.bookingId,
    );
  }

  Widget _liveBanner() {
    return BlocBuilder<LiveSessionCubit, LiveSessionState>(
      builder: (context, liveState) {
        final billing = liveState.lastBillingCycle;
        final message = billing != null
            ? 'Live session · Balance ₹${billing.balanceAfter.toStringAsFixed(0)}'
            : 'Live session in progress';
        return _StatusBanner(
          icon: Icons.circle,
          message: message,
          color: AppColors.primary,
          iconSize: 10,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pendingLiveRequest != null) {
      return _buildPendingLiveRequest(context);
    }

    final chatBody = BlocConsumer<ChatSessionBloc, ChatSessionState>(
      listenWhen: (prev, curr) {
        if (curr is ChatSessionActive &&
            curr.sendError != null &&
            (prev is! ChatSessionActive || prev.sendError != curr.sendError)) {
          return true;
        }
        if (curr is ChatSessionError &&
            (curr.message.contains('cannot access') ||
                curr.message.contains('not found'))) {
          return true;
        }
        return false;
      },
      listener: (context, state) {
        if (state is ChatSessionActive && state.sendError != null) {
          CommonFlushbar.error(context, state.sendError!);
        }
        if (state is ChatSessionError &&
            (state.message.toLowerCase().contains('cannot') ||
                state.message.toLowerCase().contains('not found'))) {
          CommonFlushbar.error(context, state.message);
          safePop(context);
        }
      },
      builder: (context, state) {
        if (state is ChatSessionAccessLoading) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ChatSessionError) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: _ErrorBody(
              message: state.message,
              onRetry: () =>
                  context.read<ChatSessionBloc>().add(const RetryChatSession()),
            ),
          );
        }

        if (state is ChatSessionWaitingRoom) {
          return _buildScaffold(
            title: widget.healerName ?? state.healerName ?? 'Chat',
            showEndSession: widget.isLiveSession,
            body: Column(
              children: [
                if (state.messages.isNotEmpty)
                  Expanded(child: _buildMessageList(state.messages)),
                Expanded(
                  child: ChatWaitingRoom(
                    access: state.access,
                    countdown: state.countdown,
                  ),
                ),
              ],
            ),
          );
        }

        if (state is ChatSessionCancelled) {
          return _buildSessionScaffold(
            state: state,
            banner: _StatusBanner(
              icon: Icons.cancel_outlined,
              message: state.access.message.isNotEmpty
                  ? state.access.message
                  : 'This booking was cancelled.',
              color: AppColors.error,
            ),
            canCompose: false,
          );
        }

        if (state is ChatSessionHistoryOnly) {
          return _buildSessionScaffold(
            state: state,
            banner: state.showBookAgain
                ? _StatusBanner(
                    icon: Icons.lock_outline,
                    message: state.access.message.isNotEmpty
                        ? state.access.message
                        : 'This chat session has ended.',
                    color: AppColors.textSecondary,
                    actionLabel: 'Book Again',
                    onAction: () => context.go('/home'),
                  )
                : null,
            canCompose: false,
          );
        }

        if (state is ChatSessionActive) {
          return _buildSessionScaffold(
            state: state,
            banner: state.isLiveSession ? _liveBanner() : null,
            canCompose: state.canCompose,
            showEndSession: state.isLiveSession && state.canCompose,
            activeState: state,
          );
        }

        return _buildScaffold(
          title: widget.healerName ?? 'Chat',
          showEndSession: widget.isLiveSession,
          body: const SizedBox.shrink(),
        );
      },
    );

    if (!widget.isLiveSession) return chatBody;

    return MultiBlocListener(
      listeners: [
        BlocListener<LiveSessionCubit, LiveSessionState>(
          listenWhen: (prev, curr) =>
              curr.sessionEnded != null &&
              prev.sessionEnded != curr.sessionEnded,
          listener: (context, state) async {
            final summary = state.sessionEnded;
            if (summary == null || !context.mounted) return;
            await finishLiveSessionFromSummary(
              context: context,
              bookingId: widget.bookingId,
              summary: summary,
              healerName: widget.healerName,
              healerImage: widget.pendingLiveRequest?.healerImage,
              healerRole: 'Healer',
              sessionType: 'Live',
            );
            if (!context.mounted) return;
            context.read<ChatSessionBloc>().add(const RefreshChatAccess());
          },
        ),
        BlocListener<LiveSessionCubit, LiveSessionState>(
          listenWhen: (prev, curr) =>
              curr.lowBalanceWarning != null &&
              prev.lowBalanceWarning != curr.lowBalanceWarning,
          listener: (context, state) {
            final warning = state.lowBalanceWarning;
            if (warning == null || !context.mounted) return;
            CommonFlushbar.error(
              context,
              'Low wallet balance. About ${warning.estimatedMinutesLeft} minutes left.',
            );
          },
        ),
      ],
      child: chatBody,
    );
  }

  void _startLiveRequestCountdown(DateTime? expiresAt) {
    _liveRequestCountdownTimer?.cancel();
    if (expiresAt != null) {
      _liveRequestSecondsLeft = expiresAt
          .difference(DateTime.now())
          .inSeconds
          .clamp(0, 60);
    } else {
      _liveRequestSecondsLeft = 60;
    }

    _liveRequestCountdownTimer = Timer.periodic(const Duration(seconds: 1), (
      timer,
    ) {
      if (!mounted) return;
      setState(() {
        if (_liveRequestSecondsLeft > 0) {
          _liveRequestSecondsLeft--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  ChatMessageDto _liveRequestSystemMessage(String content) {
    return ChatMessageDto(
      messageId: content.hashCode.toString(),
      bookingId: '',
      senderId: 'system',
      senderName: 'System',
      senderRole: 'System',
      content: content,
      messageType: 'System',
      createdAt: DateTime.now(),
    );
  }

  List<ChatMessageDto> _liveRequestMessagesForState(LiveRequestState state) {
    final healerName = widget.healerName ?? 'healer';

    if (state is LiveRequestLoading) {
      return [
        _liveRequestSystemMessage(
          'Sending your live chat request to $healerName…',
        ),
      ];
    }

    if (state is LiveRequestWaiting) {
      final messages = <ChatMessageDto>[
        _liveRequestSystemMessage(
          'Live chat request sent. Waiting for $healerName to accept.',
        ),
      ];
      if (!state.hubConnected) {
        messages.add(
          _liveRequestSystemMessage(
            'Live connection is reconnecting — we will still notify you when the healer responds.',
          ),
        );
      }
      messages.add(
        _liveRequestSystemMessage(
          'Request expires in $_liveRequestSecondsLeft seconds.',
        ),
      );
      return messages;
    }

    if (state is LiveRequestRejected) {
      return [
        _liveRequestSystemMessage(
          state.message.isNotEmpty
              ? state.message
              : '$healerName declined your live chat request.',
        ),
      ];
    }

    if (state is LiveRequestExpired) {
      return [
        _liveRequestSystemMessage(
          'The healer did not respond in time. Please try again.',
        ),
      ];
    }

    if (state is LiveRequestError) {
      return [_liveRequestSystemMessage(state.message)];
    }

    if (state is LiveRequestWalletError) {
      return [
        _liveRequestSystemMessage(
          'Insufficient wallet balance. Add funds and try again.',
        ),
      ];
    }

    return [_liveRequestSystemMessage('Preparing your live chat request…')];
  }

  String _liveRequestComposerHint(LiveRequestState state) {
    if (state is LiveRequestWaiting || state is LiveRequestLoading) {
      return 'Messages unlock when the healer accepts';
    }
    return 'Chat is unavailable';
  }

  bool _liveRequestShowRetry(LiveRequestState state) =>
      state is LiveRequestError ||
      state is LiveRequestExpired ||
      state is LiveRequestRejected;

  Widget _buildPendingLiveRequest(BuildContext context) {
    final pending = widget.pendingLiveRequest!;

    return BlocConsumer<LiveRequestBloc, LiveRequestState>(
      listenWhen: (prev, curr) => curr is! LiveRequestLoading,
      listener: (context, state) {
        if (state is LiveRequestWaiting) {
          _startLiveRequestCountdown(state.expiresAt);
        } else if (state is LiveRequestAccepted) {
          final bookingId = state.payload.bookingId;
          context.pushReplacement(
            '/chat/$bookingId',
            extra: ChatSessionArgs(
              bookingId: bookingId,
              isLiveSession: true,
              healerName: widget.healerName,
              otherUserProfile: widget.pendingLiveRequest?.healerImage,
            ),
          );
        } else if (state is LiveRequestWalletError) {
          final wallet = state.walletError;
          InsufficientWalletDialog.show(
            context: context,
            message: wallet.message,
            requiredAmount: wallet.requiredBalance,
            availableAmount: wallet.currentBalance,
          );
        } else if (state is LiveRequestExpired && _liveRequestSecondsLeft > 0) {
          setState(() => _liveRequestSecondsLeft = 0);
        }
      },
      builder: (context, state) {
        final messages = _liveRequestMessagesForState(state);
        final isWaiting =
            state is LiveRequestLoading || state is LiveRequestWaiting;
        final hubBanner = state is LiveRequestWaiting && !state.hubConnected;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (isWaiting) {
              context.read<LiveRequestBloc>().add(const CancelRequest());
            }
            safePop(context);
          },
          child: _buildScaffold(
            title: widget.healerName ?? 'Chat',
            isOtherPartyOnline: isWaiting,
            onBack: () {
              if (isWaiting) {
                context.read<LiveRequestBloc>().add(const CancelRequest());
              }
              safePop(context);
            },
            body: Column(
              children: [
                if (hubBanner)
                  _StatusBanner(
                    icon: Icons.wifi_off_outlined,
                    message:
                        'Live socket unavailable — checking status every few seconds.',
                    color: AppColors.textSecondary,
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      _buildBackground(),
                      ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        itemCount: messages.length + (isWaiting ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (isWaiting && index == messages.length) {
                            return Padding(
                              padding: EdgeInsets.only(top: 24.h),
                              child: Column(
                                children: [
                                  if (pending.healerImage != null &&
                                      pending.healerImage!.isNotEmpty)
                                    CommonImage(
                                      path: pending.healerImage!,
                                      width: 72.w,
                                      height: 72.w,
                                      fit: BoxFit.cover,
                                      borderRadius: 36.r,
                                    ),
                                  SizedBox(height: 12.h),
                                  SizedBox(
                                    width: 48.w,
                                    height: 48.w,
                                    child: const CircularProgressIndicator(
                                      color: AppColors.primary,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return SystemMessageBubble(message: messages[index]);
                        },
                      ),
                    ],
                  ),
                ),
                if (_liveRequestShowRetry(state))
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: CommonButton(
                      text: 'Try again',
                      borderRadius: 12.r,
                      height: 48.h,
                      onPressed: () => context.read<LiveRequestBloc>().add(
                        const RetryRequest(),
                      ),
                    ),
                  )
                else if (state is LiveRequestWalletError)
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
                    child: CommonButton(
                      text: 'Go to Wallet',
                      backgroundColor: AppColors.darkButton,
                      borderRadius: 12.r,
                      height: 48.h,
                      onPressed: () => context.push('/wallet'),
                    ),
                  ),
                ChatComposer(
                  controller: _controller,
                  enabled: false,
                  hintText: _liveRequestComposerHint(state),
                  onSend: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSessionScaffold({
    required ChatSessionState state,
    required bool canCompose,
    Widget? banner,
    bool showEndSession = false,
    ChatSessionActive? activeState,
  }) {
    final messages = switch (state) {
      ChatSessionActive s => s.messages,
      ChatSessionHistoryOnly s => s.messages,
      ChatSessionCancelled s => s.messages,
      _ => const <ChatMessageDto>[],
    };

    final healerName = switch (state) {
      ChatSessionActive s => s.healerName,
      ChatSessionHistoryOnly s => s.healerName,
      ChatSessionCancelled s => s.healerName,
      _ => widget.healerName,
    };

    final bookingGroups = switch (state) {
      ChatSessionActive s => s.bookingGroups,
      ChatSessionHistoryOnly s => s.bookingGroups,
      _ => null,
    };

    return _buildScaffold(
      title: healerName ?? widget.healerName ?? 'Chat',
      showEndSession: showEndSession,
      isOtherPartyOnline: activeState?.isOtherPartyOnline ?? false,
      showSearch: activeState != null || state is ChatSessionHistoryOnly,
      body: Column(
        children: [
          if (banner != null) banner,
          if (activeState?.isLoadingOlder == true)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
          Expanded(
            child: Stack(
              children: [
                _buildBackground(),
                Positioned.fill(
                  child: BlocListener<ChatSessionBloc, ChatSessionState>(
                    listenWhen: (_, curr) =>
                        curr is ChatSessionActive ||
                        curr is ChatSessionHistoryOnly,
                    listener: (_, __) => _scrollToBottom(),
                    child: bookingGroups != null && bookingGroups.isNotEmpty
                        ? _buildGroupedMessageList(
                            bookingGroups,
                            activeState: activeState,
                          )
                        : _buildMessageList(messages, activeState: activeState),
                  ),
                ),
              ],
            ),
          ),
          if (activeState?.typingUserName != null)
            TypingIndicator(userName: activeState!.typingUserName!),
          if (activeState?.isUploadingAttachment == true)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              color: AppColors.primaryLite,
              child: Row(
                children: [
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'Uploading attachment...',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          if (_isRecordingAudio) _buildRecordingStrip(),
          ChatComposer(
            controller: _controller,
            focusNode: _composerFocusNode,
            enabled:
                canCompose &&
                !(activeState?.isUploadingAttachment ?? false) &&
                (!_isRecordingAudio || _isRecordingLocked),
            isEditing: _editingMessageId != null,
            isRecording: _isRecordingAudio,
            hintText: activeState?.isUploadingAttachment == true
                ? 'Uploading attachment...'
                : (_isRecordingAudio
                      ? 'Recording voice note...'
                      : 'Write a message'),
            onCancelEdit: _cancelEditingMessage,
            onChanged: canCompose
                ? (_) => context.read<ChatSessionBloc>().add(
                    const ChatUserTyping(),
                  )
                : null,
            onSend: () => _submitComposer(activeState),
            onAttachmentTap: () => _onAttachmentPressed(activeState),
            onMicTap: () => _onMicTap(activeState),
            onRecordLongPressStart: _onRecordLongPressStart,
            onRecordLongPressMoveUpdate: _onRecordLongPressMove,
            onRecordLongPressEnd: _onRecordLongPressEnd,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedMessageList(
    List<ChatBookingMessageGroup> groups, {
    ChatSessionActive? activeState,
  }) {
    final highlights = activeState?.searchHighlightIds ?? const {};

    if (groups.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return ListView(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      children: [
        for (final group in groups) ...[
          ChatBookingGroupHeader(booking: group.booking),
          if (group.messages.isEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                'No messages in this session',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textHint,
                  fontSize: 12.sp,
                ),
              ),
            )
          else
            for (final message in group.messages)
              _buildMessageItem(
                message,
                activeState: activeState,
                highlights: highlights,
              ),
          SizedBox(height: 8.h),
        ],
      ],
    );
  }

  Widget _buildMessageItem(
    ChatMessageDto message, {
    ChatSessionActive? activeState,
    Set<String> highlights = const {},
  }) {
    _maybeMarkRead(message);
    if (message.isSystem) {
      return SystemMessageBubble(message: message);
    }
    final isMe = _isMe(message);
    final canInteract = _canInteractWithMessage(message, activeState);
    final canEdit = canInteract && isMe;
    return SessionMessageBubble(
      message: message,
      isMe: isMe,
      avatarUrl: widget.otherUserProfile,
      currentUserId: _patientId,
      highlighted:
          highlights.contains(message.messageId) ||
          message.messageId == _editingMessageId,
      canEdit: canEdit,
      canReact: canInteract,
      onEdit: canEdit ? () => _startEditingMessage(message) : null,
      onDelete: canEdit
          ? () => context.read<ChatSessionBloc>().add(
              DeleteChatMessage(message.messageId),
            )
          : null,
      onToggleReaction: canInteract
          ? (emoji) => context.read<ChatSessionBloc>().add(
              ToggleChatReaction(messageId: message.messageId, emoji: emoji),
            )
          : null,
    );
  }

  Widget _buildMessageList(
    List<ChatMessageDto> messages, {
    ChatSessionActive? activeState,
  }) {
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    final highlights = activeState?.searchHighlightIds ?? const {};

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageItem(
          message,
          activeState: activeState,
          highlights: highlights,
        );
      },
    );
  }

  void _maybeMarkRead(ChatMessageDto message) {
    if (_isMe(message) || message.isSystem) return;
    context.read<ChatSessionBloc>().add(
      MarkVisibleMessageRead(message.messageId),
    );
  }

  Widget _buildBackground() {
    return CommonImage(
      path: 'assets/image/chatbg.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Future<void> _showSearchDialog() async {
    final controller = TextEditingController();
    final query = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Search messages'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Search…'),
          onSubmitted: (value) => Navigator.pop(ctx, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Search'),
          ),
        ],
      ),
    );
    if (query == null || !mounted) return;
    if (query.trim().isEmpty) {
      context.read<ChatSessionBloc>().add(const ClearChatSearch());
    } else {
      context.read<ChatSessionBloc>().add(SearchChatMessages(query));
    }
  }

  Widget _buildScaffold({
    required String title,
    required Widget body,
    bool showEndSession = false,
    bool isOtherPartyOnline = false,
    bool showSearch = false,
    VoidCallback? onBack,
  }) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left,
            color: AppColors.textPrimary,
            size: 28.sp,
          ),
          onPressed: onBack ?? () => safePop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h3.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (isOtherPartyOnline)
              Text(
                'Online',
                style: AppTextStyles.caption.copyWith(
                  color: const Color(0xFF16B783),
                  fontSize: 11.sp,
                ),
              ),
          ],
        ),
        actions: [
          if (showSearch)
            IconButton(
              icon: Icon(
                Icons.search,
                color: AppColors.textPrimary,
                size: 22.sp,
              ),
              onPressed: _showSearchDialog,
            ),
          if (showEndSession)
            TextButton(
              onPressed: _endLiveSession,
              child: Text(
                'End',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: body,
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final double? iconSize;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatusBanner({
    required this.icon,
    required this.message,
    required this.color,
    this.iconSize,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: iconSize ?? 18.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontSize: 12.sp,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTextStyles.button.copyWith(
                  color: AppColors.primary,
                  fontSize: 12.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),
            CommonButton(text: 'Retry', onPressed: onRetry, borderRadius: 12.r),
          ],
        ),
      ),
    );
  }
}
