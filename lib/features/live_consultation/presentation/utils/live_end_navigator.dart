import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../receipt/presentation/models/receipt_args.dart';
import '../../data/datasource/live_api_service.dart';
import '../../data/models/live_models.dart';
import '../bloc/live_session_cubit.dart';

/// Opens the e-receipt screen using session end payload data.
void navigateToLiveReceipt({
  required BuildContext context,
  required String bookingId,
  SessionEndedSummary? summary,
  String? healerName,
  String? healerRole,
  String? healerImage,
  String? healingType,
  String? sessionType,
}) {
  final resolved =
      summary ??
      SessionEndedSummary(
        bookingId: bookingId,
        bookingReference: '',
      );
  final receiptArgs = ReceiptArgs.fromSessionSummary(
    summary: resolved,
    healerName: healerName,
    healerRole: healerRole,
    healerImage: healerImage,
    healingType: healingType,
    sessionType: sessionType,
  );
  context.pushReplacement(
    '/receipt',
    extra: receiptArgs,
  );
}

/// Ends the live session via REST and opens the e-receipt screen.
Future<void> endLiveSessionAndNavigate({
  required BuildContext context,
  required String bookingId,
  String? healerName,
  String? healerRole,
  String? healerImage,
  String? healingType,
  String? sessionType,
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
  navigateToLiveReceipt(
    context: context,
    bookingId: bookingId,
    summary: summary,
    healerName: healerName,
    healerRole: healerRole,
    healerImage: healerImage,
    healingType: healingType,
    sessionType: sessionType,
  );
}

/// After patient ends a live call/chat, stop hub monitoring and show e-receipt.
Future<void> finishLiveSessionFromSummary({
  required BuildContext context,
  required String bookingId,
  SessionEndedSummary? summary,
  String? healerName,
  String? healerRole,
  String? healerImage,
  String? healingType,
  String? sessionType,
}) async {
  try {
    await context.read<LiveSessionCubit>().stopMonitoring();
  } catch (_) {}

  if (!context.mounted) return;
  navigateToLiveReceipt(
    context: context,
    bookingId: bookingId,
    summary: summary,
    healerName: healerName,
    healerRole: healerRole,
    healerImage: healerImage,
    healingType: healingType,
    sessionType: sessionType,
  );
}
