import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';

class ChatVideoPlayerScreen extends StatefulWidget {
  final String videoUrl;
  final String? title;

  const ChatVideoPlayerScreen({super.key, required this.videoUrl, this.title});

  @override
  State<ChatVideoPlayerScreen> createState() => _ChatVideoPlayerScreenState();
}

class _ChatVideoPlayerScreenState extends State<ChatVideoPlayerScreen> {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      );
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _isLoading = false;
      });
      await controller.play();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to play this video.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title?.isNotEmpty == true ? widget.title! : 'Video'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator(color: AppColors.primary)
            : (_error != null || controller == null)
            ? Text(
                _error ?? 'Unable to play this video.',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: controller.value.aspectRatio == 0
                        ? 16 / 9
                        : controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  const SizedBox(height: 12),
                  IconButton(
                    iconSize: 42,
                    color: Colors.white,
                    onPressed: () {
                      if (!controller.value.isInitialized) return;
                      if (controller.value.isPlaying) {
                        controller.pause();
                      } else {
                        controller.play();
                      }
                      setState(() {});
                    },
                    icon: Icon(
                      controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_fill,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
