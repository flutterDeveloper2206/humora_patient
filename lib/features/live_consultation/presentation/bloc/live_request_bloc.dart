import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/live_api_service.dart';
import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';
import '../utils/live_request_routing.dart';
import '../utils/live_waitlist_cache.dart';
import 'live_request_event.dart';
import 'live_request_state.dart';

class LiveRequestBloc extends Bloc<LiveRequestEvent, LiveRequestState> {
  final LiveApiService _api;
  final LiveHubService _hub;

  StreamSubscription<RequestAcceptedPayload>? _acceptedSub;
  StreamSubscription<Map<String, dynamic>>? _rejectedSub;
  StreamSubscription<Map<String, dynamic>>? _expiredSub;
  StreamSubscription<String>? _hubErrorSub;
  Timer? _pollTimer;
  Timer? _unavailableRetryTimer;

  String? _lastHealerId;
  int? _lastConsultationType;
  String? _activeRequestId;
  String? _activeWaitlistId;

  LiveRequestBloc({LiveApiService? api, LiveHubService? hub})
    : _api = api ?? LiveApiService(),
      _hub = hub ?? LiveHubService.instance,
      super(LiveRequestInitial()) {
    on<StartRequest>(_onStartRequest);
    on<CancelRequest>(_onCancelRequest);
    on<RetryRequest>(_onRetryRequest);
    on<PollRequestStatus>(_onPollRequest);
    on<PollWaitlistPosition>(_onPollWaitlistPosition);
    on<LeaveWaitlist>(_onLeaveWaitlist);
    on<_AcceptedHubEvent>(_onAcceptedHub);
    on<_RejectedHubEvent>(_onRejectedHub);
    on<_ExpiredHubEvent>(_onExpiredHub);
    on<_ErrorHubEvent>(_onErrorHub);
  }

  Future<void> _onStartRequest(
    StartRequest event,
    Emitter<LiveRequestState> emit,
  ) async {
    _lastHealerId = event.healerId;
    _lastConsultationType = event.consultationType;

    await _cancelSubscriptions();
    emit(LiveRequestLoading());

    // Doc §6 Step 4: register hub listeners BEFORE POST /live/request.
    try {
      await _hub.connect();
      _listenToHub();
      developer.log(
        'LiveRequestBloc → hub ${LiveHubService.connectionLabel(_hub.state)}',
        name: 'LiveRequestBloc',
      );
    } catch (e) {
      developer.log(
        'LiveRequestBloc → hub unavailable, REST poll will be used: $e',
        name: 'LiveRequestBloc',
      );
    }

    try {
      developer.log(
        'LiveRequestBloc → POST /live/request '
        'healerId=${event.healerId} type=${event.consultationType}',
        name: 'LiveRequestBloc',
      );
      final response = await _api.sendRequest(
        LiveRequestBody(
          healerId: event.healerId,
          consultationType: event.consultationType,
        ),
      );

      if (response.isQueued) {
        _activeRequestId = null;
        _activeWaitlistId = response.waitlistId;
        emit(
          LiveRequestQueued(
            waitlistId: response.waitlistId,
            healerId: response.healerId,
            consultationType: response.consultationType,
            position: response.position,
            estimatedWaitMinutes: response.estimatedWaitMinutes,
            joinedAt: response.joinedAt,
          ),
        );
        _startWaitlistPoll();
        return;
      }

      _activeRequestId = response.requestId;
      _unavailableRetryTimer?.cancel();
      if (response.requestId.isEmpty) {
        _emitWaitingForHealer(emit, event);
        return;
      }
      emit(
        LiveRequestWaiting(
          requestId: response.requestId,
          expiresAt: response.expiresAt,
          hubConnected: _hub.isConnected,
        ),
      );
      // When hub is connected, rely on SignalR events; otherwise poll REST.
      if (!_hub.isConnected) {
        _startPoll();
      }
    } on LiveApiException catch (e) {
      if (e.walletError != null) {
        emit(LiveRequestWalletError(e.walletError!));
      } else if (e.isWaitlistConflict) {
        _activeRequestId = null;
        _activeWaitlistId = null;
        emit(
          LiveRequestQueued(
            waitlistId: '',
            healerId: event.healerId,
            consultationType: event.consultationType,
            position: e.queuePosition!,
          ),
        );
        _startWaitlistPoll();
      } else if (e.shouldContinueWaiting) {
        _emitWaitingForHealer(emit, event);
      } else {
        emit(LiveRequestError(e.message));
      }
    } catch (e) {
      final msg = _cleanError(e);
      if (_isAuthError(msg)) {
        emit(LiveRequestError(msg));
      } else {
        _emitWaitingForHealer(emit, event);
      }
    }
  }

  bool _isAuthError(String message) {
    final m = message.toLowerCase();
    return m.contains('token') ||
        m.contains('auth') ||
        m.contains('unauthorized');
  }

  void _emitWaitingForHealer(
    Emitter<LiveRequestState> emit,
    StartRequest event,
  ) {
    _activeRequestId = null;
    _activeWaitlistId = null;
    emit(
      LiveRequestWaiting(
        requestId: '',
        expiresAt: DateTime.now().add(const Duration(seconds: 60)),
        hubConnected: _hub.isConnected,
      ),
    );
    _startWaitlistPoll();
    _startUnavailableRetry();
  }

  void _startUnavailableRetry() {
    _unavailableRetryTimer?.cancel();
    _unavailableRetryTimer = Timer.periodic(const Duration(seconds: 25), (_) {
      if (isClosed) return;
      final s = state;
      final awaitingRequest = s is LiveRequestWaiting &&
          (_activeRequestId == null || _activeRequestId!.isEmpty);
      if (awaitingRequest || s is LiveRequestQueued) {
        add(const RetryRequest());
      }
    });
  }

  Future<void> _onPollRequest(
    PollRequestStatus event,
    Emitter<LiveRequestState> emit,
  ) async {
    final requestId = _activeRequestId;
    if (requestId == null ||
        requestId.isEmpty ||
        state is! LiveRequestWaiting) {
      return;
    }

    try {
      final response = await _api.getRequestStatus(requestId);
      if (LiveRequestStatus.isAccepted(response.status) &&
          response.bookingId != null &&
          response.bookingId!.isNotEmpty) {
        await _cancelSubscriptions();
        _activeRequestId = null;
        final payload = enrichAcceptedPayload(
          payload: RequestAcceptedPayload(
            bookingId: response.bookingId!,
            bookingReference: response.bookingReference ?? '',
            consultationType: response.consultationType,
          ),
          requestedType: _lastConsultationType ?? 0,
        );
        _rememberAcceptedBookingType(payload);
        emit(LiveRequestAccepted(payload));
      } else if (LiveRequestStatus.isRejected(response.status)) {
        await _cancelSubscriptions();
        _activeRequestId = null;
        emit(const LiveRequestRejected('The healer declined your request.'));
      } else if (LiveRequestStatus.isExpired(response.status)) {
        await _cancelSubscriptions();
        _activeRequestId = null;
        emit(LiveRequestExpired());
      } else if (LiveRequestStatus.isCancelled(response.status)) {
        await _cancelSubscriptions();
        _activeRequestId = null;
        emit(const LiveRequestRejected('Request was cancelled.'));
      }
    } catch (_) {}
  }

  void _startPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) add(const PollRequestStatus());
    });
  }

  void _startWaitlistPoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      if (!isClosed) add(const PollWaitlistPosition());
    });
  }

  Future<void> _onPollWaitlistPosition(
    PollWaitlistPosition event,
    Emitter<LiveRequestState> emit,
  ) async {
    final healerId = _lastHealerId;
    if (healerId == null || state is! LiveRequestQueued) return;

    try {
      final position = await _api.getWaitlistPosition(healerId);
      final current = state as LiveRequestQueued;
      emit(
        current.copyWith(
          waitlistId: position.waitlistId.isNotEmpty
              ? position.waitlistId
              : current.waitlistId,
          position: position.position,
          estimatedWaitMinutes: position.estimatedWaitMinutes,
          joinedAt: position.joinedAt ?? current.joinedAt,
        ),
      );
      _activeWaitlistId = position.waitlistId.isNotEmpty
          ? position.waitlistId
          : _activeWaitlistId;
    } catch (_) {}
  }

  Future<void> _onLeaveWaitlist(
    LeaveWaitlist event,
    Emitter<LiveRequestState> emit,
  ) async {
    final healerId = _lastHealerId;
    if (healerId == null) return;

    await _cancelSubscriptions();
    try {
      await _api.leaveWaitlist(healerId);
    } catch (_) {}
    _activeWaitlistId = null;
    LiveWaitlistCache.instance.forget(healerId);
    emit(LiveRequestInitial());
  }

  Future<void> _onCancelRequest(
    CancelRequest event,
    Emitter<LiveRequestState> emit,
  ) async {
    await _cancelSubscriptions();
    _activeRequestId = null;
    emit(LiveRequestInitial());
  }

  Future<void> _onRetryRequest(
    RetryRequest event,
    Emitter<LiveRequestState> emit,
  ) async {
    final healerId = _lastHealerId;
    final consultationType = _lastConsultationType;
    if (healerId == null || consultationType == null) {
      emit(
        const LiveRequestError(
          'Unable to retry. Please go back and try again.',
        ),
      );
      return;
    }
    add(StartRequest(healerId: healerId, consultationType: consultationType));
  }

  void _rememberAcceptedBookingType(RequestAcceptedPayload payload) {
    final type = _lastConsultationType;
    if (type == null || payload.bookingId.isEmpty) return;
    LiveWaitlistCache.instance.rememberBookingType(payload.bookingId, type);
  }

  Future<void> _onAcceptedHub(
    _AcceptedHubEvent event,
    Emitter<LiveRequestState> emit,
  ) async {
    if (state is! LiveRequestWaiting && state is! LiveRequestQueued) return;
    await _cancelSubscriptions();
    _activeRequestId = null;
    final payload = enrichAcceptedPayload(
      payload: event.payload,
      requestedType: _lastConsultationType ?? 0,
    );
    _rememberAcceptedBookingType(payload);
    emit(LiveRequestAccepted(payload));
  }

  Future<void> _onRejectedHub(
    _RejectedHubEvent event,
    Emitter<LiveRequestState> emit,
  ) async {
    await _cancelSubscriptions();
    _activeRequestId = null;
    emit(LiveRequestRejected(event.message));
  }

  Future<void> _onExpiredHub(
    _ExpiredHubEvent event,
    Emitter<LiveRequestState> emit,
  ) async {
    await _cancelSubscriptions();
    _activeRequestId = null;
    emit(LiveRequestExpired());
  }

  Future<void> _onErrorHub(
    _ErrorHubEvent event,
    Emitter<LiveRequestState> emit,
  ) async {
    if (state is! LiveRequestWaiting && state is! LiveRequestQueued) return;
    // Hub invoke noise — REST poll / retry handles request status.
    developer.log(
      'LiveRequestBloc → hub error ignored while waiting: ${event.message}',
      name: 'LiveRequestBloc',
    );
  }

  void _listenToHub() {
    _acceptedSub = _hub.requestAccepted.listen((payload) {
      if (isClosed) return;
      add(_AcceptedHubEvent(payload));
    });
    _rejectedSub = _hub.requestRejected.listen((data) {
      if (isClosed) return;
      if (!_matchesRequest(data)) return;
      add(
        _RejectedHubEvent(
          data['reason']?.toString() ??
              data['message']?.toString() ??
              'The healer declined your request.',
        ),
      );
    });
    _expiredSub = _hub.requestExpired.listen((data) {
      if (isClosed) return;
      if (!_matchesRequest(data)) return;
      add(const _ExpiredHubEvent());
    });
    _hubErrorSub = _hub.hubError.listen((message) {
      if (isClosed) return;
      add(_ErrorHubEvent(message));
    });
  }

  bool _matchesRequest(Map<String, dynamic> data) {
    final requestId = data['requestId']?.toString();
    if (requestId == null || requestId.isEmpty) return true;
    return requestId == _activeRequestId;
  }

  Future<void> _cancelSubscriptions() async {
    _pollTimer?.cancel();
    _pollTimer = null;
    _unavailableRetryTimer?.cancel();
    _unavailableRetryTimer = null;
    await _acceptedSub?.cancel();
    await _rejectedSub?.cancel();
    await _expiredSub?.cancel();
    await _hubErrorSub?.cancel();
    _acceptedSub = null;
    _rejectedSub = null;
    _expiredSub = null;
    _hubErrorSub = null;
  }

  String _cleanError(Object e) => e.toString().replaceAll('Exception: ', '');

  @override
  Future<void> close() async {
    await _cancelSubscriptions();
    return super.close();
  }
}

final class _AcceptedHubEvent extends LiveRequestEvent {
  final RequestAcceptedPayload payload;
  const _AcceptedHubEvent(this.payload);
}

final class _RejectedHubEvent extends LiveRequestEvent {
  final String message;
  const _RejectedHubEvent(this.message);
}

final class _ExpiredHubEvent extends LiveRequestEvent {
  const _ExpiredHubEvent();
}

final class _ErrorHubEvent extends LiveRequestEvent {
  final String message;
  const _ErrorHubEvent(this.message);
}
