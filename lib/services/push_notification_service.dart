import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../firebase_options.dart';
import '../models/push_notification_status.dart';
import '../models/push_notification_destination.dart';
import '../providers/conversation_provider.dart';
import 'device_timezone_service.dart';
import 'sync_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

class PushNotificationServiceException implements Exception {
  const PushNotificationServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  static const _tokenPreferenceKey = 'howai_fcm_registration_token';
  static const _iosRegistrationChannel = MethodChannel(
    'howai/push_notifications',
  );
  static const _reminderChannel = AndroidNotificationChannel(
    'howai_reminders',
    'Reminders',
    description: 'Time-sensitive reminders created with HowAI.',
    importance: Importance.high,
  );
  static const _automationChannel = AndroidNotificationChannel(
    'howai_automations',
    'Automations',
    description: 'Verified briefings and updates from HowAI Automations.',
    importance: Importance.high,
  );

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  GlobalKey<NavigatorState>? _navigatorKey;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedSubscription;
  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<AuthState>? _authSubscription;
  Map<String, dynamic>? _pendingNavigation;
  Future<bool>? _syncInFlight;
  bool _initialized = false;

  bool get supportsRemoteNotifications =>
      !kIsWeb && (Platform.isIOS || Platform.isAndroid);

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    _navigatorKey = navigatorKey;
    if (_initialized || !supportsRemoteNotifications) return;

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) return;
        try {
          final value = jsonDecode(payload);
          if (value is Map) {
            unawaited(
              _handleNotificationData(Map<String, dynamic>.from(value)),
            );
          }
        } catch (_) {
          // Ignore malformed payloads from old notification versions.
        }
      },
    );
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_reminderChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_automationChannel);
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _showForegroundNotification,
    );
    _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) => unawaited(_handleNotificationData(message.data)),
    );
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(_registerTokenSilently(token));
    });
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (state) {
        final user = state.session?.user;
        if (user != null && !user.isAnonymous) {
          unawaited(_syncSilently());
          flushPendingNavigation();
        } else if (state.event == AuthChangeEvent.signedOut) {
          unawaited(_clearLocalToken());
        }
      },
    );

    WidgetsBinding.instance.addObserver(this);
    _initialized = true;
    unawaited(_loadInitialMessageSilently());
    unawaited(_syncSilently());
  }

  Future<void> _loadInitialMessageSilently() async {
    try {
      final initialMessage = await _messaging
          .getInitialMessage()
          .timeout(const Duration(seconds: 3));
      if (initialMessage != null) {
        await _handleNotificationData(initialMessage.data);
      }
    } catch (_) {
      // Some iOS launches never resolve getInitialMessage. Notification launch
      // recovery is best-effort and must never delay the first app frame.
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncSilently());
    }
  }

  Future<PushNotificationStatus> status() async {
    final permission = await permissionState();
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous || !supportsRemoteNotifications) {
      return PushNotificationStatus(
        available: false,
        registered: false,
        permission: permission,
      );
    }
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'push-devices',
        body: const {'operation': 'status'},
      ).timeout(const Duration(seconds: 12));
      return PushNotificationStatus.fromJson(
        _map(response.data),
        permission: permission,
      );
    } catch (error) {
      throw PushNotificationServiceException(_friendlyError(error));
    }
  }

  Future<PushPermissionState> permissionState() async {
    if (!supportsRemoteNotifications) return PushPermissionState.unknown;
    final settings = await _messaging.getNotificationSettings();
    return _permissionState(settings.authorizationStatus);
  }

  Future<bool> requestPermissionAndRegister() async {
    if (!supportsRemoteNotifications) return false;
    final currentStatus = await status();
    if (!currentStatus.available) return false;
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    final permission = _permissionState(settings.authorizationStatus);
    if (permission != PushPermissionState.authorized &&
        permission != PushPermissionState.provisional) {
      return false;
    }
    return syncIfAuthorized();
  }

  Future<bool> syncIfAuthorized() async {
    final inFlight = _syncInFlight;
    if (inFlight != null) return inFlight;

    final operation = _performAuthorizedSync();
    _syncInFlight = operation;
    try {
      return await operation;
    } finally {
      if (identical(_syncInFlight, operation)) _syncInFlight = null;
    }
  }

  Future<bool> _performAuthorizedSync() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous || !supportsRemoteNotifications) {
      return false;
    }
    final permission = await permissionState();
    _debugLog('Permission state: $permission');
    if (permission != PushPermissionState.authorized &&
        permission != PushPermissionState.provisional) {
      return false;
    }
    if (Platform.isIOS) {
      await _requestIosRemoteNotificationRegistration();
      if (!await _waitForApnsToken()) {
        _debugLog(
            'APNs token was not delivered before registration timed out.');
        return false;
      }
    }
    _debugLog('APNs token is available; requesting the FCM token.');
    final token = await _messaging.getToken();
    if (token == null || token.trim().isEmpty) return false;
    _debugLog('FCM token is available; registering this device.');
    return _registerToken(token);
  }

  Future<bool> unregisterCurrentDevice() async {
    if (!supportsRemoteNotifications) return true;
    final preferences = await SharedPreferences.getInstance();
    final token = preferences.getString(_tokenPreferenceKey);
    final user = Supabase.instance.client.auth.currentUser;
    if (token == null || user == null || user.isAnonymous) return true;
    try {
      await Supabase.instance.client.functions.invoke(
        'push-devices',
        body: {'operation': 'unregister', 'token': token},
      ).timeout(const Duration(seconds: 8));
      await preferences.remove(_tokenPreferenceKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  void flushPendingNavigation() {
    final pending = _pendingNavigation;
    if (pending != null) unawaited(_handleNotificationData(pending));
  }

  Future<bool> _registerToken(String token) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || user.isAnonymous) return false;
    final preferences = await SharedPreferences.getInstance();
    final previousToken = preferences.getString(_tokenPreferenceKey);
    final packageInfo = await PackageInfo.fromPlatform();
    final timezone = await DeviceTimezoneService.currentIdentifier();
    final response = await Supabase.instance.client.functions.invoke(
      'push-devices',
      body: {
        'operation': 'register',
        'token': token,
        'previous_token': previousToken,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'timezone': timezone,
        'locale': PlatformDispatcher.instance.locale.toLanguageTag(),
        'app_version': '${packageInfo.version}+${packageInfo.buildNumber}',
      },
    ).timeout(const Duration(seconds: 12));
    final data = _map(response.data);
    if (data['registered'] != true) return false;
    await preferences.setString(_tokenPreferenceKey, token);
    return true;
  }

  Future<void> _registerTokenSilently(String token) async {
    try {
      await _registerToken(token);
    } catch (_) {
      // Background token refresh retries on the next auth or app lifecycle sync.
    }
  }

  Future<void> _syncSilently() async {
    try {
      await syncIfAuthorized();
    } catch (error, stackTrace) {
      _debugLog('Background registration failed: $error', stackTrace);
      // Startup must not fail when the rollout is disabled or the network is down.
    }
  }

  Future<bool> _waitForApnsToken() async {
    try {
      for (var attempt = 0; attempt < 20; attempt++) {
        if (await _messaging.getAPNSToken() != null) {
          _debugLog('APNs token arrived after ${attempt + 1} attempt(s).');
          return true;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
    } catch (error, stackTrace) {
      _debugLog('Reading the APNs token failed: $error', stackTrace);
    }
    return false;
  }

  Future<void> _requestIosRemoteNotificationRegistration() async {
    try {
      await _iosRegistrationChannel.invokeMethod<void>('register');
      _debugLog('Requested native APNs registration.');
    } catch (error, stackTrace) {
      _debugLog('Native APNs registration request failed: $error', stackTrace);
    }
  }

  void _debugLog(String message, [StackTrace? stackTrace]) {
    if (!kDebugMode) return;
    debugPrint('[PushNotifications] $message');
    if (stackTrace != null) debugPrintStack(stackTrace: stackTrace);
  }

  Future<void> _clearLocalToken() async {
    try {
      await _messaging.deleteToken();
    } catch (_) {
      // Token deletion is best-effort after the authenticated unregister call.
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_tokenPreferenceKey);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    if (!Platform.isAndroid) return;
    final notification = message.notification;
    if (notification == null) return;
    final isAutomation = message.data['type'] == 'automation';
    await _localNotifications.show(
      id: message.messageId?.hashCode ?? message.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          isAutomation ? 'howai_automations' : 'howai_reminders',
          isAutomation ? 'Automations' : 'Reminders',
          channelDescription: isAutomation
              ? 'Verified briefings and updates from HowAI Automations.'
              : 'Time-sensitive reminders created with HowAI.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_launcher',
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _handleNotificationData(Map<String, dynamic> data) async {
    final destination = PushNotificationDestination.tryParse(data);
    if (destination == null) return;
    final navigator = _navigatorKey?.currentState;
    final user = Supabase.instance.client.auth.currentUser;
    if (navigator == null || user == null || user.isAnonymous) {
      _pendingNavigation = Map<String, dynamic>.from(data);
      return;
    }
    _pendingNavigation = null;
    if (destination.type == PushNotificationDestinationType.reminder) {
      navigator.pushNamed('/actions', arguments: destination.reminderId);
      return;
    }

    final localId = await SyncService()
        .syncConversationByUuid(destination.conversationId!)
        .timeout(const Duration(seconds: 12), onTimeout: () => null);
    if (localId == null || !navigator.mounted) {
      _pendingNavigation = Map<String, dynamic>.from(data);
      return;
    }
    final provider = Provider.of<ConversationProvider>(
      navigator.context,
      listen: false,
    );
    await provider.loadConversations(profileId: 1);
    final matches = provider.allConversations
        .where((conversation) => conversation.id == localId);
    if (matches.isEmpty) {
      _pendingNavigation = Map<String, dynamic>.from(data);
      return;
    }
    provider.selectConversation(matches.first);
    navigator.popUntil((route) => route.isFirst);
  }

  PushPermissionState _permissionState(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
        return PushPermissionState.authorized;
      case AuthorizationStatus.provisional:
        return PushPermissionState.provisional;
      case AuthorizationStatus.denied:
        return PushPermissionState.denied;
      case AuthorizationStatus.notDetermined:
        return PushPermissionState.notDetermined;
    }
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is! Map) {
      throw const PushNotificationServiceException(
        'The push service returned invalid data.',
      );
    }
    return Map<String, dynamic>.from(value);
  }

  static String _friendlyError(Object error) {
    if (error is FunctionException) {
      final details = error.details;
      if (details is Map && details['error'] is String) {
        return details['error'] as String;
      }
      return error.reasonPhrase ?? 'Push notifications are unavailable.';
    }
    if (error is PushNotificationServiceException) return error.message;
    return 'Push notifications are unavailable. Please try again.';
  }

  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    await _foregroundSubscription?.cancel();
    await _openedSubscription?.cancel();
    await _tokenSubscription?.cancel();
    await _authSubscription?.cancel();
    _initialized = false;
  }
}
