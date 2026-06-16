import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasource/live_api_service.dart';
import '../../data/models/live_models.dart';
import '../bloc/live_session_cubit.dart';

/// Opens the session summary screen (uses [summary] or a minimal fallback).
void navigateToLiveSessionSummary({
  required BuildContext context,
  required String bookingId,
  SessionEndedSummary? summary,
}) {
  context.pushReplacement(
    '/live-session-summary',
    extra: summary ??
        SessionEndedSummary(
          bookingId: bookingId,
          bookingReference: '',
        ),
  );
}

/// Ends the live session via REST and opens the summary screen.
Future<void> endLiveSessionAndNavigate({
  required BuildContext context,
  required String bookingId,
}) async {
  SessionEndedSummary? summary;
  try {
    summary = await LiveApiService().endSession(
      LiveEndBody(bookingId: bookingId),
    );
  } catch (_) {}

  if (!context.mounted) return;

  try {
    await context.read<LiveSessionCubit>().stopMonitoring();
  } catch (_) {}

  if (!context.mounted) return;
  navigateToLiveSessionSummary(
    context: context,
    bookingId: bookingId,
    summary: summary,
  );
}

/// After patient ends a live call/chat, stop hub monitoring and show summary.
Future<void> finishLiveSessionFromSummary({
  required BuildContext context,
  required String bookingId,
  SessionEndedSummary? summary,
}) async {
  try {
    await context.read<LiveSessionCubit>().stopMonitoring();
  } catch (_) {}

  if (!context.mounted) return;
  navigateToLiveSessionSummary(
    context: context,
    bookingId: bookingId,
    summary: summary,
  );
}
