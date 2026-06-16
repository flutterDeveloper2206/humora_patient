import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/datasource/live_api_service.dart';
import '../../data/datasource/live_hub_service.dart';
import '../../data/models/live_models.dart';
import '../utils/live_request_routing.dart';
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

  String? _lastHealerId;
  int? _lastConsultationType;
  String? _activeRequestId;

  LiveRequestBloc({LiveApiService? api, LiveHubService? hub})
    : _api = api ?? LiveApiService(),
      _hub = hub ?? LiveHubService.instance,
      super(LiveRequestInitial()) {
    on<StartRequest>(_onStartRequest);
    on<CancelRequest>(_onCancelRequest);
    on<RetryRequest>(_onRetryRequest);
    on<PollRequestStatus>(_onPollRequest);
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

      _activeRequestId = response.requestId;
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
      } else if (e.statusCode == 409) {
        emit(
          const LiveRequestError(
            'This healer is busy or your request expired. Please try again.',
          ),
        );
      } else {
        emit(LiveRequestError(e.message));
      }
    } catch (e) {
      emit(LiveRequestError(_cleanError(e)));
    }
  }

  Future<void> _onPollRequest(
    PollRequestStatus event,
    Emitter<LiveRequestState> emit,
  ) async {
    final requestId = _activeRequestId;
    if (requestId == null || state is! LiveRequestWaiting) return;

    try {
      final response = await _api.getRequestStatus(requestId);
      if (LiveRequestStatus.isAccepted(response.status) &&
          response.bookingId != null &&
          response.bookingId!.isNotEmpty) {
        await _cancelSubscriptions();
        _activeRequestId = null;
        emit(
          LiveRequestAccepted(
            enrichAcceptedPayload(
              payload: RequestAcceptedPayload(
                bookingId: response.bookingId!,
                bookingReference: response.bookingReference ?? '',
                consultationType: response.consultationType,
              ),
              requestedType: _lastConsultationType ?? 0,
            ),
          ),
        );
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

  Future<void> _onAcceptedHub(
    _AcceptedHubEvent event,
    Emitter<LiveRequestState> emit,
  ) async {
    await _cancelSubscriptions();
    _activeRequestId = null;
    emit(
      LiveRequestAccepted(
        enrichAcceptedPayload(
          payload: event.payload,
          requestedType: _lastConsultationType ?? 0,
        ),
      ),
    );
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
    if (state is! LiveRequestWaiting) return;
    // Ignore stale hub invoke errors; request status comes from REST poll or events.
    final msg = event.message.toLowerCase();
    if (msg.contains('hubmethod does not exist') ||
        msg.contains('sendrequest')) {
      return;
    }
    emit(LiveRequestError(event.message));
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
