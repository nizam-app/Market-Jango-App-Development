import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kDebugMode, TargetPlatform;
import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:market_jango/core/constants/api_control/notification_api.dart';
import 'package:market_jango/core/utils/auth_local_storage.dart';
import 'package:market_jango/firebase_options.dart';
import 'package:permission_handler/permission_handler.dart';

/// Background isolate — must be a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (defaultTargetPlatform == TargetPlatform.android) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  }
  debugPrint(
    'FCM [background] id=${message.messageId} '
    'title=${message.notification?.title} body=${message.notification?.body} data=${message.data}',
  );
}

/// Registers FCM token with `POST /api/save-fcm` and shows foreground notifications on Android.
class FcmPushService {
  FcmPushService._();
  static final FcmPushService instance = FcmPushService._();

  static final Logger _log = Logger(
    printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5, lineLength: 120),
  );

  static void _logFcmToken(String? token, String reason) {
    if (!kDebugMode) return;
    if (token == null || token.isEmpty) {
      _log.w('FCM token [$reason]: null or empty');
      return;
    }
    _log.i('FCM token [$reason]: $token');
  }

  final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'market_jango_push',
    'Push notifications',
    description: 'Order and account notifications',
    importance: Importance.high,
  );

  bool _initialized = false;

  Future<void> initializeIfAndroid() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    if (_initialized) return;
    _initialized = true;

    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);

    final perm = await Permission.notification.request();
    if (kDebugMode) {
      if (perm.isDenied || perm.isPermanentlyDenied) {
        _log.w(
          'Notification permission denied — enable in Settings or no tray/banner will show. status=$perm',
        );
      } else {
        _log.i('Notification permission: $perm');
      }
    }

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (_) {},
    );

    final androidPlugin = _local.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(_channel);

    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    FirebaseMessaging.onMessageOpenedApp.listen((m) {
      if (kDebugMode) {
        _log.i(
          'FCM [opened from tray] title=${m.notification?.title} data=${m.data}',
        );
      }
    });

    final initial = await messaging.getInitialMessage();
    if (initial != null && kDebugMode) {
      _log.i(
        'FCM [cold start from notification] title=${initial.notification?.title} data=${initial.data}',
      );
    }

    FirebaseMessaging.instance.onTokenRefresh.listen((t) {
      _logFcmToken(t, 'onTokenRefresh');
      postFcmTokenToBackend(t);
    });

    final token = await messaging.getToken();
    _logFcmToken(token, 'getToken');
    if (token != null) {
      await postFcmTokenToBackend(token);
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    final n = message.notification;
    final title = n?.title ?? message.data['title']?.toString() ?? 'Notification';
    final body = n?.body ?? message.data['body']?.toString() ?? '';

    if (kDebugMode) {
      _log.i(
        'FCM [foreground] id=${message.messageId} title=$title body=$body data=${message.data}',
      );
    }

    _local.show(
      id: message.hashCode,
      title: title,
      body: body.isEmpty ? null : body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );
  }

  /// Call after login or on cold start when a session already exists.
  static Future<void> postFcmTokenToBackend(String fcmToken) async {
    if (fcmToken.isEmpty) return;
    final auth = AuthLocalStorage();
    final token = await auth.getToken();
    if (token == null || token.isEmpty) return;

    final uri = Uri.parse(NotificationAPIController.saveFcm);
    final body = <String, dynamic>{
      'fcm_token': fcmToken,
      'token': fcmToken,
      'device_type': defaultTargetPlatform == TargetPlatform.android
          ? 'android'
          : 'ios',
    };

    try {
      final res = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'token': token,
        },
        body: jsonEncode(body),
      );
      if (res.statusCode < 200 || res.statusCode >= 300) {
        // Non-fatal: server may reject guest paths; avoid crashing the app.
        debugPrint('save-fcm failed: ${res.statusCode} ${res.body}');
      }
    } catch (e, st) {
      debugPrint('save-fcm error: $e\n$st');
    }
  }

  /// Re-fetch FCM token and register (e.g. after login).
  Future<void> syncTokenToBackend() async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    final t = await FirebaseMessaging.instance.getToken();
    _logFcmToken(t, 'syncTokenToBackend');
    if (t != null) await postFcmTokenToBackend(t);
  }
}
