import 'package:flutter/material.dart';

import '../../../../core/incoming_call/incoming_call_controller.dart';
import '../pages/incoming_call_screen.dart';

/// Overlays [IncomingCallScreen] when a ring push is active.
class IncomingCallCoordinator extends StatefulWidget {
  final Widget child;

  const IncomingCallCoordinator({super.key, required this.child});

  @override
  State<IncomingCallCoordinator> createState() => _IncomingCallCoordinatorState();
}

class _IncomingCallCoordinatorState extends State<IncomingCallCoordinator> {
  @override
  void initState() {
    super.initState();
    IncomingCallController.instance.addListener(_onRingChanged);
  }

  @override
  void dispose() {
    IncomingCallController.instance.removeListener(_onRingChanged);
    super.dispose();
  }

  void _onRingChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final active = IncomingCallController.instance.active;
    return Stack(
      fit: StackFit.expand,
      children: [
        widget.child,
        if (active != null)
          Positioned.fill(
            child: IncomingCallScreen(payload: active),
          ),
      ],
    );
  }
}
