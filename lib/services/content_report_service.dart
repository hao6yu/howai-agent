import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/content_report.dart';
import '../services/database_service.dart';

class ContentReportService {
  static final ContentReportService _instance = ContentReportService._internal();
  factory ContentReportService() => _instance;
  ContentReportService._internal();

  final DatabaseService _databaseService = DatabaseService();

  /// Submit a content report (stores both in database and SharedPreferences as backup)
  Future<bool> submitContentReport(ContentReport report) async {
    try {
      // Store in database
      final db = await _databaseService.database;
      await db.insert('content_reports', report.toMap());

      // Also store in SharedPreferences as backup (for Google Play compliance)
      await _storeReportInPreferences(report);

      // print('📝 Content report submitted successfully: ${report.reason.name} for message ${report.messageId}');
      return true;
    } catch (e) {
      // print('❌ Error submitting content report: $e');

      // Fallback to SharedPreferences only if database fails
      try {
        await _storeReportInPreferences(report);
        // print('📝 Content report stored in preferences as fallback');
        return true;
      } catch (prefError) {
        // print('❌ Failed to store report in preferences: $prefError');
        return false;
      }
    }
  }

  /// Store report in SharedPreferences (backup method)
  Future<void> _storeReportInPreferences(ContentReport report) async {
    final prefs = await SharedPreferences.getInstance();
    final reports = prefs.getStringList('content_reports') ?? [];

    final reportData = {
      'messageId': report.messageId,
      'reason': report.reason.name,
      'description': report.description,
      'timestamp': report.createdAt,
    };

    reports.add(jsonEncode(reportData));
    await prefs.setStringList('content_reports', reports);
  }

  /// Get all content reports from database
  Future<List<ContentReport>> getAllReports() async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'content_reports',
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => ContentReport.fromMap(maps[i]));
    } catch (e) {
      // print('❌ Error getting content reports: $e');
      return [];
    }
  }

  /// Check if a specific message has been reported
  Future<bool> isMessageReported(int messageId) async {
    try {
      final db = await _databaseService.database;
      final result = await db.query(
        'content_reports',
        where: 'message_id = ?',
        whereArgs: [messageId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      // print('❌ Error checking if message is reported: $e');
      return false;
    }
  }

  /// Get report count for a specific message
  Future<int> getReportCount(int messageId) async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) FROM content_reports WHERE message_id = ?',
        [messageId],
      );
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      // print('❌ Error getting report count for message $messageId: $e');
      return 0;
    }
  }

  /// Check if message should be hidden (images hidden immediately, text stays visible)
  Future<bool> shouldHideMessage(int messageId, {bool hasImages = false}) async {
    try {
      final isReported = await isMessageReported(messageId);

      // For single-user app: only hide AI-generated images when reported
      if (hasImages && isReported) {
        return true; // Hide images immediately when reported
      } else {
        return false; // Keep text visible (just show flagged indicator)
      }
    } catch (e) {
      // print('❌ Error checking if message should be hidden: $e');
      return false;
    }
  }

  /// Get reports count for statistics
  Future<int> getReportsCount() async {
    try {
      final db = await _databaseService.database;
      final result = await db.rawQuery('SELECT COUNT(*) FROM content_reports');
      return Sqflite.firstIntValue(result) ?? 0;
    } catch (e) {
      // print('❌ Error getting reports count: $e');

      // Fallback to SharedPreferences count
      try {
        final prefs = await SharedPreferences.getInstance();
        final reports = prefs.getStringList('content_reports') ?? [];
        return reports.length;
      } catch (prefError) {
        return 0;
      }
    }
  }

  /// Get reports for a specific message
  Future<List<ContentReport>> getReportsForMessage(int messageId) async {
    try {
      final db = await _databaseService.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'content_reports',
        where: 'message_id = ?',
        whereArgs: [messageId],
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => ContentReport.fromMap(maps[i]));
    } catch (e) {
      // print('❌ Error getting reports for message $messageId: $e');
      return [];
    }
  }

  /// Mark a report as resolved (for admin/debugging purposes)
  Future<bool> resolveReport(int reportId, String resolutionAction) async {
    try {
      final db = await _databaseService.database;
      final result = await db.update(
        'content_reports',
        {
          'is_resolved': 1,
          'resolution_action': resolutionAction,
        },
        where: 'id = ?',
        whereArgs: [reportId],
      );
      return result > 0;
    } catch (e) {
      // print('❌ Error resolving report: $e');
      return false;
    }
  }

  /// Get report statistics for debugging/analytics
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final reports = await getAllReports();
      final stats = <String, int>{};

      for (final report in reports) {
        final reason = report.reason.name;
        stats[reason] = (stats[reason] ?? 0) + 1;
      }

      return {
        'totalReports': reports.length,
        'reasonBreakdown': stats,
        'resolvedCount': reports.where((r) => r.isResolved).length,
        'pendingCount': reports.where((r) => !r.isResolved).length,
      };
    } catch (e) {
      // print('❌ Error getting report statistics: $e');
      return {'totalReports': 0, 'reasonBreakdown': {}, 'resolvedCount': 0, 'pendingCount': 0};
    }
  }

  /// Clear all reports (for testing/debugging)
  Future<bool> clearAllReports() async {
    try {
      final db = await _databaseService.database;
      await db.delete('content_reports');

      // Also clear SharedPreferences backup
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('content_reports');

      // print('🗑️ All content reports cleared');
      return true;
    } catch (e) {
      // print('❌ Error clearing reports: $e');
      return false;
    }
  }
}
