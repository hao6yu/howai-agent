import 'dart:math';
import 'package:flutter/foundation.dart';
import 'database_service.dart';

/// Voice call allowance check result.
class VoiceCallAllowance {
  final bool allowed;
  final int perCallLimitSeconds;
  final int remainingTodaySeconds;
  final int remainingThisWeekSeconds;
  final int remainingForThisCallSeconds;
  final int usedTodaySeconds;
  final int usedThisWeekSeconds;
  final String? blockedReason;

  const VoiceCallAllowance({
    required this.allowed,
    required this.perCallLimitSeconds,
    required this.remainingTodaySeconds,
    required this.remainingThisWeekSeconds,
    required this.remainingForThisCallSeconds,
    required this.usedTodaySeconds,
    required this.usedThisWeekSeconds,
    this.blockedReason,
  });

  /// Format remaining time as "X min" or "X min Y sec".
  String formatRemaining(int seconds) {
    if (seconds <= 0) return '0 min';
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    if (secs == 0) return '$minutes min';
    return '$minutes min $secs sec';
  }

  String get remainingTodayFormatted => formatRemaining(remainingTodaySeconds);
  String get remainingThisWeekFormatted => formatRemaining(remainingThisWeekSeconds);
  String get perCallLimitFormatted => formatRemaining(perCallLimitSeconds);
}

/// Voice call tier limits.
class VoiceCallLimits {
  final int perCallSeconds;
  final int dailySeconds;
  final int weeklySeconds;

  const VoiceCallLimits({
    required this.perCallSeconds,
    required this.dailySeconds,
    required this.weeklySeconds,
  });

  int get perCallMinutes => perCallSeconds ~/ 60;
  int get dailyMinutes => dailySeconds ~/ 60;
  int get weeklyMinutes => weeklySeconds ~/ 60;

  /// Free tier: 4 min/call, 12 min/day, 45 min/week
  static const VoiceCallLimits free = VoiceCallLimits(
    perCallSeconds: 4 * 60,   // 4 minutes
    dailySeconds: 12 * 60,    // 12 minutes
    weeklySeconds: 45 * 60,   // 45 minutes
  );

  /// Premium tier: 10 min/call, 60 min/day, 300 min/week
  static const VoiceCallLimits premium = VoiceCallLimits(
    perCallSeconds: 10 * 60,  // 10 minutes
    dailySeconds: 60 * 60,    // 60 minutes (1 hour)
    weeklySeconds: 300 * 60,  // 300 minutes (5 hours)
  );

  static VoiceCallLimits forTier({required bool isPremium}) {
    return isPremium ? premium : free;
  }
}

/// Service for tracking voice call usage and enforcing limits.
class VoiceCallUsageService {
  final DatabaseService _db;

  VoiceCallUsageService({DatabaseService? databaseService})
      : _db = databaseService ?? DatabaseService();

  /// Get the voice call allowance for a profile.
  Future<VoiceCallAllowance> getVoiceCallAllowance({
    required int profileId,
    required bool isPremium,
    DateTime? now,
  }) async {
    final current = now ?? DateTime.now();
    final limits = VoiceCallLimits.forTier(isPremium: isPremium);

    final usedToday = await _getUsageSeconds(
      profileId: profileId,
      since: _startOfDay(current),
    );
    final usedThisWeek = await _getUsageSeconds(
      profileId: profileId,
      since: _startOfWeek(current),
    );

    final remainingToday = max(0, limits.dailySeconds - usedToday);
    final remainingWeek = max(0, limits.weeklySeconds - usedThisWeek);
    final remainingForCall = min(
      limits.perCallSeconds,
      min(remainingToday, remainingWeek),
    );

    final allowed = remainingForCall > 0;
    String? blockedReason;
    
    if (!allowed) {
      if (remainingWeek <= 0) {
        blockedReason = isPremium
            ? 'Weekly voice call limit reached. Resets next week.'
            : 'Free weekly limit reached. Upgrade for more time!';
      } else if (remainingToday <= 0) {
        blockedReason = isPremium
            ? 'Daily voice call limit reached. Try again tomorrow.'
            : 'Free daily limit reached. Upgrade for more time!';
      }
    }

    return VoiceCallAllowance(
      allowed: allowed,
      perCallLimitSeconds: limits.perCallSeconds,
      remainingTodaySeconds: remainingToday,
      remainingThisWeekSeconds: remainingWeek,
      remainingForThisCallSeconds: remainingForCall,
      usedTodaySeconds: usedToday,
      usedThisWeekSeconds: usedThisWeek,
      blockedReason: blockedReason,
    );
  }

  /// Start a voice call session. Returns the session ID.
  Future<int> startVoiceCallSession({
    required int profileId,
    required bool isPremium,
  }) async {
    final db = await _db.database;
    final now = DateTime.now();
    
    final id = await db.insert('voice_call_sessions', {
      'profile_id': profileId,
      'started_at': now.toIso8601String(),
      'duration_seconds': 0,
      'is_premium': isPremium ? 1 : 0,
      'end_reason': null,
    });
    
    debugPrint('VoiceCallUsageService: Started session $id for profile $profileId');
    return id;
  }

  /// End a voice call session and record the duration.
  Future<void> endVoiceCallSession({
    required int sessionId,
    required int durationSeconds,
    String? endReason,
  }) async {
    final db = await _db.database;
    
    await db.update(
      'voice_call_sessions',
      {
        'duration_seconds': durationSeconds,
        'end_reason': endReason ?? 'completed',
        'ended_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );
    
    debugPrint('VoiceCallUsageService: Ended session $sessionId with duration ${durationSeconds}s');
  }

  /// Get total usage in seconds since a given time.
  Future<int> _getUsageSeconds({
    required int profileId,
    required DateTime since,
  }) async {
    final db = await _db.database;
    
    final result = await db.rawQuery('''
      SELECT COALESCE(SUM(duration_seconds), 0) as total
      FROM voice_call_sessions
      WHERE profile_id = ? AND started_at >= ?
    ''', [profileId, since.toIso8601String()]);

    final total = result.first['total'];
    if (total is int) return total;
    if (total is double) return total.toInt();
    return 0;
  }

  DateTime _startOfDay(DateTime dt) {
    return DateTime(dt.year, dt.month, dt.day);
  }

  DateTime _startOfWeek(DateTime dt) {
    // Week starts on Monday
    final daysToSubtract = (dt.weekday - 1) % 7;
    final startOfWeek = dt.subtract(Duration(days: daysToSubtract));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
  }
}
