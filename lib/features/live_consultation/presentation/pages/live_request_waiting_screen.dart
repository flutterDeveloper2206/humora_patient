import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../models/live_consultation_args.dart';
import '../utils/live_request_routing.dart';

/// Legacy route — redirects to direct chat / voice / video connect flow.
class LiveRequestWaitingScreen extends StatefulWidget {
  final LiveConsultationArgs args;

  const LiveRequestWaitingScreen({super.key, required this.args});

  @override
  State<LiveRequestWaitingScreen> createState() =>
      _LiveRequestWaitingScreenState();
}

class _LiveRequestWaitingScreenState extends State<LiveRequestWaitingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await navigateToLiveConsultation(
        context: context,
        args: widget.args,
        replaceCurrent: true,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }
}
