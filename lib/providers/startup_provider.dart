import 'package:flutter/foundation.dart';

/// Tracks the readiness of services that must finish before feature screens
/// become interactive.
///
/// The widget tree can render immediately while local data is prepared, but
/// consumers still see the same fully initialized state before entering the
/// app.
class StartupProvider extends ChangeNotifier {
  bool _isReady = false;
  Object? _lastNonFatalError;

  bool get isReady => _isReady;
  Object? get lastNonFatalError => _lastNonFatalError;

  void recordNonFatalError(Object error) {
    _lastNonFatalError = error;
  }

  void markReady() {
    if (_isReady) return;
    _isReady = true;
    notifyListeners();
  }
}
