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
  String get remainingThisWeekFormatted =>
      formatRemaining(remainingThisWeekSeconds);
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
    perCallSeconds: 4 * 60, // 4 minutes
    dailySeconds: 12 * 60, // 12 minutes
    weeklySeconds: 45 * 60, // 45 minutes
  );

  /// Premium tier: 10 min/call, 60 min/day, 300 min/week
  static const VoiceCallLimits premium = VoiceCallLimits(
    perCallSeconds: 10 * 60, // 10 minutes
    dailySeconds: 60 * 60, // 60 minutes (1 hour)
    weeklySeconds: 300 * 60, // 300 minutes (5 hours)
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

    final usedToday = await _getUsageSecondsInWindow(
      profileId: profileId,
      windowStart: _startOfDay(current),
      windowEnd: current,
    );
    final usedThisWeek = await _getUsageSecondsInWindow(
      profileId: profileId,
      windowStart: _startOfWeek(current),
      windowEnd: current,
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

    debugPrint(
        'VoiceCallUsageService: Started session $id for profile $profileId');
    return id;
  }

  /// End a voice call session and record the duration.
  Future<void> endVoiceCallSession({
    required int sessionId,
    required int durationSeconds,
    String? endReason,
  }) async {
    final db = await _db.database;
    final endedAt = DateTime.now().toIso8601String();

    await db.update(
      'voice_call_sessions',
      {
        'duration_seconds': max(0, durationSeconds),
        'end_reason': endReason ?? 'completed',
        'ended_at': endedAt,
      },
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    debugPrint(
        'VoiceCallUsageService: Ended session $sessionId with duration ${durationSeconds}s');
  }

  /// Get total usage in seconds overlapping a given [windowStart, windowEnd] range.
  Future<int> _getUsageSecondsInWindow({
    required int profileId,
    required DateTime windowStart,
    required DateTime windowEnd,
  }) async {
    if (!windowEnd.isAfter(windowStart)) return 0;

    final db = await _db.database;

    final rows = await db.rawQuery('''
      SELECT started_at, ended_at, duration_seconds
      FROM voice_call_sessions
      WHERE profile_id = ?
        AND started_at < ?
        AND (ended_at IS NULL OR ended_at > ? OR duration_seconds > 0)
    ''', [
      profileId,
      windowEnd.toIso8601String(),
      windowStart.toIso8601String()
    ]);

    var total = 0;
    for (final row in rows) {
      final startedAt = row['started_at']?.toString();
      if (startedAt == null || startedAt.isEmpty) continue;

      final start = DateTime.tryParse(startedAt);
      if (start == null) continue;

      final endedAtRaw = row['ended_at']?.toString();
      final durationRaw = row['duration_seconds'];
      final durationSeconds = durationRaw is int
          ? durationRaw
          : (durationRaw is num ? durationRaw.toInt() : 0);
      final end = _deriveSessionEnd(
        start: start,
        endedAtRaw: endedAtRaw,
        durationSeconds: durationSeconds,
      );

      final overlapStart = start.isAfter(windowStart) ? start : windowStart;
      final overlapEnd = end.isBefore(windowEnd) ? end : windowEnd;
      if (overlapEnd.isAfter(overlapStart)) {
        total += overlapEnd.difference(overlapStart).inSeconds;
      }
    }

    return total;
  }

  DateTime _deriveSessionEnd({
    required DateTime start,
    required String? endedAtRaw,
    required int durationSeconds,
  }) {
    final parsedEnd = (endedAtRaw == null || endedAtRaw.isEmpty)
        ? null
        : DateTime.tryParse(endedAtRaw);
    final fallbackEnd = start.add(Duration(seconds: max(0, durationSeconds)));
    final end = parsedEnd ?? fallbackEnd;
    if (end.isBefore(start)) return start;
    return end;
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
