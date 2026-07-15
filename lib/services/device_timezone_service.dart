import 'package:flutter_timezone/flutter_timezone.dart';

class DeviceTimezoneService {
  DeviceTimezoneService._();

  static String? _cachedIdentifier;

  static Future<String> currentIdentifier() async {
    if (_cachedIdentifier case final cached?) return cached;
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      final identifier = timezone.identifier.trim();
      _cachedIdentifier = identifier.isEmpty ? 'UTC' : identifier;
    } catch (_) {
      _cachedIdentifier = 'UTC';
    }
    return _cachedIdentifier!;
  }
}
