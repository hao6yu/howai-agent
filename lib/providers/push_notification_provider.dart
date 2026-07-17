import 'package:flutter/foundation.dart';

import '../models/push_notification_status.dart';
import '../services/push_notification_service.dart';

class PushNotificationProvider extends ChangeNotifier {
  PushNotificationProvider({PushNotificationService? service})
      : _service = service ?? PushNotificationService.instance;

  final PushNotificationService _service;
  PushNotificationStatus _status = const PushNotificationStatus(
    available: false,
    registered: false,
    permission: PushPermissionState.unknown,
  );
  bool _isLoading = false;
  bool _initialized = false;
  String? _errorMessage;

  PushNotificationStatus get status => _status;
  bool get isLoading => _isLoading;
  bool get isAvailable => _status.available;
  bool get canDeliver => _status.canDeliver;
  bool get isDenied => _status.isDenied;
  String? get errorMessage => _errorMessage;

  Future<void> ensureInitialized({bool force = false}) async {
    if (_initialized && !force) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _status = await _service.status();
      _initialized = true;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> enable() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final registered = await _service.requestPermissionAndRegister();
      _status = await _service.status();
      _initialized = true;
      if (!registered && _status.available) {
        _errorMessage = _status.isDenied
            ? 'Notifications are disabled in your device settings.'
            : 'This device could not register for notifications.';
      }
      return registered;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
