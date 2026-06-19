import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

import '../../../../common/widgets/common_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/models/chat_models.dart';
import '../../data/models/chat_reaction_model.dart';
import '../pages/chat_video_player_screen.dart';

class SessionMessageBubble extends StatelessWidget {
  final ChatMessageDto message;
  final bool isMe;
  final String? avatarUrl;
  final String? currentUserId;
  final bool highlighted;
  final bool canEdit;
  final bool canReact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final ValueChanged<String>? onToggleReaction;

  const SessionMessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.avatarUrl,
    this.currentUserId,
    this.highlighted = false,
    this.canEdit = false,
    this.canReact = false,
    this.onEdit,
    this.onDelete,
    this.onToggleReaction,
  });

  static const _quickEmojis = ['👍', '❤️', '😂', '😮', '😢', '🙏'];

  bool get _canShowMenu =>
      (canEdit || canReact) && !message.isPending && !message.isDeleted;

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Center(
          child: Text(
            '[Message deleted]',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    }

    final avatar = avatarUrl ?? 'assets/image/doctorprofile.png';
    final timeLabel = message.createdAt != null
        ? DateFormat(
            'h:mm a',
          ).format(message.createdAt!.toLocal()).toLowerCase()
        : '';

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: GestureDetector(
        onLongPress: _canShowMenu ? () => _showActionsSheet(context) : null,
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) _Avatar(path: avatar),
            if (!isMe) SizedBox(width: 8.w),
            if (isMe && _canShowMenu) _buildMenuButton(context),
            if (isMe && _canShowMenu) SizedBox(width: 4.w),
            Flexible(child: _buildBubble(context, timeLabel)),
            if (!isMe && _canShowMenu) SizedBox(width: 4.w),
            if (!isMe && _canShowMenu) _buildMenuButton(context),
            if (isMe) ...[
              SizedBox(width: 8.w),
              _Avatar(path: 'assets/image/shortphoto.png'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(BuildContext context, String timeLabel) {
    final attachment = message.attachment;
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
      decoration: BoxDecoration(
        color: highlighted ? AppColors.primaryLiteChip : Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
          bottomLeft: isMe ? Radius.circular(20.r) : Radius.zero,
          bottomRight: isMe ? Radius.zero : Radius.circular(20.r),
        ),
        border: highlighted
            ? Border.all(color: AppColors.primary, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (attachment != null) ...[
            _buildAttachmentPreview(context, attachment),
            if (message.content.trim().isNotEmpty &&
                message.content.trim() != attachment.fileName)
              Padding(
                padding: EdgeInsets.only(top: 8.h),
                child: Text(
                  message.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: const Color(0xff181818),
                    fontWeight: FontWeight.w400,
                    fontSize: 13.sp,
                  ),
                ),
              ),
          ] else
            Text(
              message.content,
              style: AppTextStyles.bodyMedium.copyWith(
                color: const Color(0xff181818),
                fontWeight: FontWeight.w400,
                fontSize: 13.sp,
              ),
            ),
          if (attachment != null && attachment.formattedSize.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                attachment.formattedSize,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10.sp,
                ),
              ),
            ),
          if (message.isEdited)
            Text(
              'edited',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textHint,
                fontSize: 9.sp,
              ),
            ),
          if (message.reactions.isNotEmpty) ...[
            SizedBox(height: 6.h),
            Wrap(
              spacing: 4.w,
              runSpacing: 4.h,
              children: message.reactions.map(_reactionChip).toList(),
            ),
          ],
          SizedBox(height: 4.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (timeLabel.isNotEmpty)
                Text(
                  timeLabel,
                  style: AppTextStyles.label.copyWith(
                    fontSize: 10.sp,
                    color: const Color(0xff9E9E9E),
                  ),
                ),
              if (message.isPending) ...[
                SizedBox(width: 6.w),
                SizedBox(
                  width: 12.w,
                  height: 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: Colors.grey.shade400,
                  ),
                ),
              ] else if (isMe) ...[
                SizedBox(width: 4.w),
                Icon(
                  message.isReadByOther
                      ? Icons.done_all
                      : (message.isDelivered ? Icons.done_all : Icons.done),
                  size: 14.sp,
                  color: message.isReadByOther
                      ? const Color(0xFF4CAF50)
                      : const Color(0xff9E9E9E),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(
    BuildContext context,
    AttachmentInfo attachment,
  ) {
    final inferredType = _resolveAttachmentType(attachment);
    final isAudio = inferredType == _AttachmentRenderType.audio;
    final isVideo = inferredType == _AttachmentRenderType.video;
    final isImage = inferredType == _AttachmentRenderType.image;

    if (isImage) {
      final path = attachment.previewUrl;
      if (path.isNotEmpty) {
        return CommonImage(
          path: path,
          width: 190.w,
          height: 160.h,
          borderRadius: 12.r,
          fit: BoxFit.cover,
        );
      }
    }

    if (isVideo) {
      final preview = attachment.previewUrl;
      return GestureDetector(
        onTap: attachment.fileUrl.isEmpty
            ? null
            : () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChatVideoPlayerScreen(
                      videoUrl: attachment.fileUrl,
                      title: attachment.fileName,
                    ),
                  ),
                );
              },
        child: Container(
          width: 190.w,
          height: 120.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (preview.isNotEmpty)
                Positioned.fill(
                  child: CommonImage(
                    path: preview,
                    borderRadius: 12.r,
                    fit: BoxFit.cover,
                  ),
                ),
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              Positioned(
                right: 8.w,
                bottom: 8.h,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Tap to play',
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isAudio) {
      return _AudioAttachmentTile(
        attachment: attachment,
        isPending: message.isPending,
        isOutgoing: isMe,
      );
    }

    return _FileAttachmentTile(
      attachment: attachment,
      isPending: message.isPending,
      isOutgoing: isMe,
    );
  }

  _AttachmentRenderType _resolveAttachmentType(AttachmentInfo attachment) {
    final messageType = message.messageType.toLowerCase();
    final fileName = attachment.fileName.toLowerCase();
    final fileUrl = attachment.fileUrl.toLowerCase();
    final contentType = attachment.contentType.toLowerCase();
    final content = message.content.toLowerCase();

    bool hasAny(String source, List<String> suffixes) =>
        suffixes.any((s) => source.endsWith(s));

    // Prefer explicit audio/video extensions and hints first.
    final looksAudio =
        messageType == 'audio' ||
        hasAny(fileName, ['.m4a', '.aac', '.mp3', '.ogg', '.wav']) ||
        hasAny(fileUrl, ['.m4a', '.aac', '.mp3', '.ogg', '.wav']) ||
        content.contains('voice note');
    if (looksAudio) return _AttachmentRenderType.audio;

    final looksVideo =
        hasAny(fileName, ['.mp4', '.mov', '.m4v']) ||
        hasAny(fileUrl, ['.mp4', '.mov', '.m4v']);
    if (looksVideo) return _AttachmentRenderType.video;

    final looksImage =
        messageType == 'image' ||
        hasAny(fileName, ['.jpg', '.jpeg', '.png', '.webp', '.heic']) ||
        hasAny(fileUrl, ['.jpg', '.jpeg', '.png', '.webp', '.heic']) ||
        contentType.startsWith('image/');
    if (looksImage) return _AttachmentRenderType.image;

    if (contentType.startsWith('video/')) return _AttachmentRenderType.video;
    if (contentType.startsWith('audio/')) return _AttachmentRenderType.audio;

    return _AttachmentRenderType.file;
  }

  Widget _buildMenuButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showActionsSheet(context),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: Icon(
            Icons.more_horiz,
            size: 20.sp,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _reactionChip(ChatReactionDto reaction) {
    final userId = currentUserId ?? '';
    final mine = reaction.hasUser(userId);
    final count = reaction.userIds.length;

    return GestureDetector(
      onTap: onToggleReaction != null
          ? () => onToggleReaction!(reaction.emoji)
          : null,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
        decoration: BoxDecoration(
          color: mine ? AppColors.primaryLiteChip : AppColors.primaryLite,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: mine ? AppColors.primary : AppColors.primaryLiteChip,
            width: mine ? 1.2 : 1,
          ),
        ),
        child: Text(
          count > 1 ? '${reaction.emoji} $count' : reaction.emoji,
          style: AppTextStyles.caption.copyWith(
            fontSize: 12.sp,
            fontWeight: mine ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                if (canReact) ...[
                  Text(
                    'Add reaction',
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 10.w,
                    runSpacing: 8.h,
                    children: _quickEmojis
                        .map(
                          (emoji) => GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              onToggleReaction?.call(emoji);
                            },
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.primaryLite,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.divider),
                              ),
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: 24.sp),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ],
                if (canEdit && onEdit != null) ...[
                  SizedBox(height: 12.h),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.edit_outlined,
                      color: AppColors.textPrimary,
                    ),
                    title: const Text('Edit message'),
                    onTap: () {
                      Navigator.pop(ctx);
                      onEdit!();
                    },
                  ),
                ],
                if (canEdit && onDelete != null) ...[
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.delete_outline, color: AppColors.error),
                    title: Text(
                      'Delete message',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDelete(context);
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete message?'),
        content: const Text('This message will be removed for everyone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) onDelete?.call();
  }
}

class _AttachmentDownloadHelper {
  static Future<String> download(AttachmentInfo attachment) async {
    final url = attachment.fileUrl.trim();
    if (url.isEmpty) throw Exception('Attachment URL missing');
    final uri = Uri.parse(url);
    final response = await http.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Failed to download attachment');
    }
    final dir = await getTemporaryDirectory();
    final safeName = _safeFileName(
      attachment.fileName.isNotEmpty ? attachment.fileName : 'attachment.bin',
    );
    final path = '${dir.path}/$safeName';
    final file = File(path);
    await file.writeAsBytes(response.bodyBytes, flush: true);
    return file.path;
  }

  static String _safeFileName(String name) {
    return name.replaceAll(RegExp(r'[^\w\-.]'), '_');
  }
}

class _AudioAttachmentTile extends StatefulWidget {
  final AttachmentInfo attachment;
  final bool isPending;
  final bool isOutgoing;

  const _AudioAttachmentTile({
    required this.attachment,
    required this.isPending,
    required this.isOutgoing,
  });

  @override
  State<_AudioAttachmentTile> createState() => _AudioAttachmentTileState();
}

class _AudioAttachmentTileState extends State<_AudioAttachmentTile> {
  late final AudioPlayer _player;
  bool _isDownloading = false;
  bool _isPreparingPlayback = false;
  String? _localPath;
  String? _error;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (widget.isPending) return;
    if (_player.playing) {
      await _player.pause();
      return;
    }
    if (!widget.isOutgoing && _localPath == null) {
      final ok = await _downloadAudioForPlayback();
      if (!ok) return;
    }
    final sourcePath = (_localPath ?? widget.attachment.fileUrl).trim();
    if (sourcePath.isEmpty) return;
    try {
      if (_localPath != null) {
        await _player.setFilePath(_localPath!);
      } else {
        await _player.setUrl(widget.attachment.fileUrl);
      }
      await _player.play();
      if (mounted) setState(() => _error = null);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Unable to play audio.');
      }
    }
  }

  Future<bool> _downloadAudioForPlayback() async {
    if (widget.isPending || _isDownloading || _isPreparingPlayback) {
      return false;
    }
    if (_localPath != null) {
      return true;
    }
    try {
      setState(() {
        _isPreparingPlayback = true;
        _isDownloading = true;
        _error = null;
      });
      _localPath ??= await _AttachmentDownloadHelper.download(
        widget.attachment,
      );
      return true;
    } catch (_) {
      if (mounted) setState(() => _error = 'Audio download failed');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _isPreparingPlayback = false;
        });
      }
    }
  }

  Future<void> _downloadOnly() async {
    await _downloadAudioForPlayback();
  }

  @override
  Widget build(BuildContext context) {
    final canDownload = !widget.isOutgoing;
    final downloaded = _localPath != null;
    return Container(
      width: 220.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: _togglePlay,
                child: Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snap) {
                      final playing = snap.data?.playing ?? false;
                      return Icon(
                        widget.isPending
                            ? Icons.hourglass_top
                            : (playing
                                  ? Icons.pause
                                  : Icons.play_arrow_rounded),
                        size: 20.sp,
                        color: AppColors.primary,
                      );
                    },
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  widget.attachment.fileName.isNotEmpty
                      ? widget.attachment.fileName
                      : 'Audio',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (canDownload)
                GestureDetector(
                  onTap: _downloadOnly,
                  child: SizedBox(
                    width: 26.w,
                    height: 26.w,
                    child: _isDownloading
                        ? const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          )
                        : Icon(
                            downloaded
                                ? Icons.download_done_rounded
                                : Icons.download_rounded,
                            size: 20.sp,
                            color: AppColors.primary,
                          ),
                  ),
                ),
            ],
          ),
          if (canDownload && !downloaded) ...[
            SizedBox(height: 4.h),
            Text(
              'Download once to play',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10.sp,
              ),
            ),
          ],
          SizedBox(height: 6.h),
          StreamBuilder<Duration?>(
            stream: _player.durationStream,
            builder: (context, durationSnap) {
              return StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, posSnap) {
                  final total = durationSnap.data ?? Duration.zero;
                  final pos = posSnap.data ?? Duration.zero;
                  final progress = total.inMilliseconds <= 0
                      ? 0.0
                      : (pos.inMilliseconds / total.inMilliseconds).clamp(
                          0.0,
                          1.0,
                        );
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(999.r),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4.h,
                      backgroundColor: Colors.white,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          if (_error != null) ...[
            SizedBox(height: 4.h),
            Text(
              _error!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.error,
                fontSize: 10.sp,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FileAttachmentTile extends StatefulWidget {
  final AttachmentInfo attachment;
  final bool isPending;
  final bool isOutgoing;

  const _FileAttachmentTile({
    required this.attachment,
    required this.isPending,
    required this.isOutgoing,
  });

  @override
  State<_FileAttachmentTile> createState() => _FileAttachmentTileState();
}

class _FileAttachmentTileState extends State<_FileAttachmentTile> {
  bool _isDownloading = false;
  String? _localPath;
  String? _error;

  Future<void> _downloadOrOpen() async {
    if (widget.isPending || _isDownloading) return;
    try {
      setState(() {
        _isDownloading = true;
        _error = null;
      });
      _localPath ??= await _AttachmentDownloadHelper.download(
        widget.attachment,
      );
      if (!mounted) return;
      await OpenFilex.open(_localPath!);
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to open file');
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canDownload = !widget.isOutgoing;
    return Container(
      width: 220.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primaryLiteChip),
      ),
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.insert_drive_file_outlined,
              size: 18.sp,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.attachment.fileName.isNotEmpty
                      ? widget.attachment.fileName
                      : 'Attachment',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_error != null)
                  Text(
                    _error!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.error,
                      fontSize: 10.sp,
                    ),
                  ),
              ],
            ),
          ),
          if (canDownload)
            GestureDetector(
              onTap: _downloadOrOpen,
              child: SizedBox(
                width: 26.w,
                height: 26.w,
                child: _isDownloading
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      )
                    : Icon(
                        Icons.download_rounded,
                        size: 20.sp,
                        color: AppColors.primary,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String path;

  const _Avatar({required this.path});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.w,
      height: 32.w,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19.r),
        child: CommonImage(path: path, fit: BoxFit.cover),
      ),
    );
  }
}

enum _AttachmentRenderType { image, audio, video, file }
