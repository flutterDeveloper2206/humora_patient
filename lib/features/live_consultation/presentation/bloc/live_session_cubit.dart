import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';

class LiveSessionState extends Equatable {
  final String? bookingId;
  final BillingCyclePayload? lastBillingCycle;
  final LowBalanceWarningPayload? lowBalanceWarning;
  final SessionEndedSummary? sessionEnded;

  const LiveSessionState({
    this.bookingId,
    this.lastBillingCycle,
    this.lowBalanceWarning,
    this.sessionEnded,
  });

  LiveSessionState copyWith({
    String? bookingId,
    BillingCyclePayload? lastBillingCycle,
    LowBalanceWarningPayload? lowBalanceWarning,
    SessionEndedSummary? sessionEnded,
    bool clearLowBalance = false,
    bool clearSessionEnded = false,
  }) {
    return LiveSessionState(
      bookingId: bookingId ?? this.bookingId,
      lastBillingCycle: lastBillingCycle ?? this.lastBillingCycle,
      lowBalanceWarning:
          clearLowBalance ? null : (lowBalanceWarning ?? this.lowBalanceWarning),
      sessionEnded:
          clearSessionEnded ? null : (sessionEnded ?? this.sessionEnded),
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        lastBillingCycle,
        lowBalanceWarning,
        sessionEnded,
      ];
}

class LiveSessionCubit extends Cubit<LiveSessionState> {
  final LiveHubService _hub;

  StreamSubscription<BillingCyclePayload>? _billingSub;
  StreamSubscription<LowBalanceWarningPayload>? _lowBalanceSub;
  StreamSubscription<SessionEndedSummary>? _sessionEndedSub;

  LiveSessionCubit({LiveHubService? hub})
      : _hub = hub ?? LiveHubService.instance,
        super(const LiveSessionState());

  Future<void> startMonitoring(String bookingId) async {
    await stopMonitoring();
    emit(LiveSessionState(bookingId: bookingId));

    await _hub.connect();
    await _hub.joinSession(bookingId);

    _billingSub = _hub.billingCycle.listen((payload) {
      if (payload.bookingId != bookingId) return;
      emit(state.copyWith(lastBillingCycle: payload, clearLowBalance: true));
    });

    _lowBalanceSub = _hub.lowBalanceWarning.listen((payload) {
      if (payload.bookingId != bookingId) return;
      emit(state.copyWith(lowBalanceWarning: payload));
    });

    _sessionEndedSub = _hub.sessionEnded.listen((summary) {
      if (summary.bookingId != bookingId) return;
      emit(state.copyWith(sessionEnded: summary));
    });
  }

  Future<void> stopMonitoring() async {
    final bookingId = state.bookingId;
    await _billingSub?.cancel();
    await _lowBalanceSub?.cancel();
    await _sessionEndedSub?.cancel();
    _billingSub = null;
    _lowBalanceSub = null;
    _sessionEndedSub = null;

    if (bookingId != null) {
      await _hub.leaveSession(bookingId);
    }
    emit(const LiveSessionState());
  }

  @override
  Future<void> close() async {
    await stopMonitoring();
    return super.close();
  }
}
