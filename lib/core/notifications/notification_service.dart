import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/session_manager.dart';
import 'notification_payload.dart';
import 'notification_router.dart';

/// FCM push + local notifications. Token is sent via login API (`fcmToken`).
class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const String _androidChannelId = 'humora_patient_default';
  static const String _androidChannelName = 'Humora Patient';
  static const String _androidChannelDescription =
      'Session reminders, chat messages, and live consultation alerts';

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _cachedToken;

  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    await _initLocalNotifications();
    await _configureForegroundPresentation();
    _listenForMessages();
    _listenForTokenRefresh();

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _scheduleNavigation(NotificationPayload.fromRemoteMessage(initialMessage));
    }

    _initialized = true;
    developer.log('NotificationService initialized', name: 'NotificationService');
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (!status.isGranted) return false;
    }

    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final granted =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    if (granted) {
      await getDeviceToken();
    }
    return granted;
  }

  Future<String?> getDeviceToken({bool forceRefresh = false}) async {
    if (kIsWeb) return null;

    if (!forceRefresh && _cachedToken != null && _cachedToken!.isNotEmpty) {
      return _cachedToken;
    }

    try {
      if (Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          developer.log('APNS token not ready yet', name: 'NotificationService');
        }
      }

      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) {
        _cachedToken = token;
        await SessionManager.saveFcmToken(token);
      }
      return token;
    } catch (e) {
      developer.log('getDeviceToken failed: $e', name: 'NotificationService');
      return null;
    }
  }

  Future<void> clearLocalToken() async {
    if (kIsWeb) return;
    await SessionManager.clearFcmToken();
    _cachedToken = null;
    try {
      await _messaging.deleteToken();
    } catch (_) {}
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    final payload = NotificationPayload.fromRemoteMessage(message);
    developer.log(
      'Background message screen=${payload.screen}',
      name: 'NotificationService',
    );
    await instance._showLocalNotification(payload);
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (response) {
        final payload = NotificationPayload.fromLocalResponse(response);
        _scheduleNavigation(payload);
      },
    );

    if (Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.high,
        ),
      );
    }
  }

  Future<void> _configureForegroundPresentation() async {
    if (Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  void _listenForMessages() {
    FirebaseMessaging.onMessage.listen((message) async {
      final payload = NotificationPayload.fromRemoteMessage(message);
      await _showLocalNotification(payload);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final payload = NotificationPayload.fromRemoteMessage(message);
      _scheduleNavigation(payload);
    });
  }

  void _listenForTokenRefresh() {
    _messaging.onTokenRefresh.listen((token) async {
      _cachedToken = token;
      await SessionManager.saveFcmToken(token);
    });
  }

  Future<void> _showLocalNotification(NotificationPayload payload) async {
    final androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      _androidChannelName,
      channelDescription: _androidChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      id: payload.hashCode.abs(),
      title: payload.title,
      body: payload.body,
      notificationDetails: NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: payload.toLocalPayload(),
    );
  }

  void _scheduleNavigation(NotificationPayload payload) {
    Future<void>.delayed(const Duration(milliseconds: 400), () {
      NotificationRouter.open(payload);
    });
  }
}
