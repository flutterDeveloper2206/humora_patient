import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/notification_badge_controller.dart';
import '../../../../core/notifications/notification_payload.dart';
import '../../../../core/notifications/notification_router.dart';
import '../../data/datasource/notification_api_service.dart';
import 'notification_inbox_event.dart';
import 'notification_inbox_state.dart';

class NotificationInboxBloc
    extends Bloc<NotificationInboxEvent, NotificationInboxState> {
  final NotificationApiService _api;

  NotificationInboxBloc({NotificationApiService? api})
      : _api = api ?? NotificationApiService(),
        super(NotificationInboxInitial()) {
    on<LoadNotificationInbox>(_onLoad);
    on<RefreshNotificationInbox>(_onRefresh);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<DeleteNotification>(_onDelete);
    on<OpenNotificationItem>(_onOpen);
  }

  Future<void> _onLoad(
    LoadNotificationInbox event,
    Emitter<NotificationInboxState> emit,
  ) async {
    emit(NotificationInboxLoading());
    try {
      final response = await _api.getNotifications();
      NotificationBadgeController.instance.setCount(response.unreadCount);
      emit(
        NotificationInboxLoaded(
          items: response.items,
          unreadCount: response.unreadCount,
        ),
      );
    } catch (e) {
      emit(NotificationInboxError(_cleanError(e)));
    }
  }

  Future<void> _onRefresh(
    RefreshNotificationInbox event,
    Emitter<NotificationInboxState> emit,
  ) async {
    final current = state;
    if (current is NotificationInboxLoaded) {
      emit(current.copyWith(isRefreshing: true));
    }
    try {
      final response = await _api.getNotifications();
      NotificationBadgeController.instance.setCount(response.unreadCount);
      emit(
        NotificationInboxLoaded(
          items: response.items,
          unreadCount: response.unreadCount,
        ),
      );
    } catch (e) {
      if (current is NotificationInboxLoaded) {
        emit(current.copyWith(isRefreshing: false));
      } else {
        emit(NotificationInboxError(_cleanError(e)));
      }
    }
  }

  Future<void> _onMarkRead(
    MarkNotificationRead event,
    Emitter<NotificationInboxState> emit,
  ) async {
    if (state is! NotificationInboxLoaded) return;
    final loaded = state as NotificationInboxLoaded;
    try {
      final response = await _api.markRead(event.id);
      NotificationBadgeController.instance.setCount(response.unreadCount);
      final items = loaded.items
          .map(
            (item) => item.id == event.id
                ? item.copyWith(isRead: true, readAt: DateTime.now())
                : item,
          )
          .toList();
      emit(
        loaded.copyWith(
          items: items,
          unreadCount: response.unreadCount,
        ),
      );
    } catch (_) {}
  }

  Future<void> _onMarkAllRead(
    MarkAllNotificationsRead event,
    Emitter<NotificationInboxState> emit,
  ) async {
    if (state is! NotificationInboxLoaded) return;
    final loaded = state as NotificationInboxLoaded;
    try {
      final response = await _api.markAllRead();
      NotificationBadgeController.instance.setCount(response.unreadCount);
      final items = loaded.items
          .map((item) => item.copyWith(isRead: true, readAt: DateTime.now()))
          .toList();
      emit(loaded.copyWith(items: items, unreadCount: response.unreadCount));
    } catch (_) {}
  }

  Future<void> _onDelete(
    DeleteNotification event,
    Emitter<NotificationInboxState> emit,
  ) async {
    if (state is! NotificationInboxLoaded) return;
    final loaded = state as NotificationInboxLoaded;
    try {
      await _api.deleteNotification(event.id);
      final removed = loaded.items.firstWhere((e) => e.id == event.id);
      final items = loaded.items.where((e) => e.id != event.id).toList();
      final unread = removed.isRead
          ? loaded.unreadCount
          : (loaded.unreadCount > 0 ? loaded.unreadCount - 1 : 0);
      NotificationBadgeController.instance.setCount(unread);
      emit(loaded.copyWith(items: items, unreadCount: unread));
    } catch (_) {}
  }

  Future<void> _onOpen(
    OpenNotificationItem event,
    Emitter<NotificationInboxState> emit,
  ) async {
    if (state is! NotificationInboxLoaded) return;
    final loaded = state as NotificationInboxLoaded;
    final itemIndex = loaded.items.indexWhere((e) => e.id == event.id);
    if (itemIndex < 0) return;
    final item = loaded.items[itemIndex];

    if (!item.isRead) {
      add(MarkNotificationRead(item.id));
    }

    await NotificationRouter.open(
      NotificationPayload.fromInbox(
        screen: item.screen,
        data: item.data,
        title: item.title,
        body: item.body,
      ),
    );
  }

  String _cleanError(Object e) =>
      e.toString().replaceAll('Exception: ', '');
}
