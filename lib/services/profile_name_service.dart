import 'package:flutter/foundation.dart';

import 'database_service.dart';
import 'supabase_service.dart';

class ProfileNameServiceException implements Exception {
  const ProfileNameServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ProfileNameToolResult {
  const ProfileNameToolResult({
    required this.status,
    this.displayName,
  });

  final String status;
  final String? displayName;

  Map<String, dynamic> toToolResult() => {
        'status': 'succeeded',
        'name_status': status,
        'display_name': displayName,
        'message': status == 'known'
            ? 'The preferred display name was saved. Address the user by this name naturally, without repeating it excessively.'
            : 'The user declined to share a preferred name. Do not ask again.',
      };
}

/// Applies the same reversible preferred-name update for text and voice tools.
class ProfileNameService {
  ProfileNameService({
    SupabaseService? supabaseService,
    DatabaseService? databaseService,
  })  : _supabase = supabaseService ?? SupabaseService(),
        _database = databaseService ?? DatabaseService();

  static const String toolName = 'profiles_update_display_name';

  final SupabaseService _supabase;
  final DatabaseService _database;

  static Map<String, dynamic> toolDefinition() => {
        'type': 'function',
        'name': toolName,
        'description':
            'Update how the signed-in user wants HowAI to address them. Call action=set only after the user clearly identifies their own preferred name or explicitly asks to be called something. Call action=decline only when the user clearly declines to share a name or asks not to be prompted again. Never infer a name from another person, a document, an email address, or uncertain context.',
        'strict': true,
        'parameters': {
          'type': 'object',
          'additionalProperties': false,
          'properties': {
            'action': {
              'type': 'string',
              'enum': ['set', 'decline'],
            },
            'display_name': {
              'type': ['string', 'null'],
              'description':
                  'The user’s explicitly stated preferred name for action=set; null for action=decline.',
            },
          },
          'required': ['action', 'display_name'],
        },
      };

  Future<ProfileNameToolResult> applyToolCall({
    required int profileId,
    required Map<String, dynamic> arguments,
  }) async {
    final action = arguments['action']?.toString();
    if (action != 'set' && action != 'decline') {
      throw const ProfileNameServiceException(
        'The preferred-name action was invalid.',
      );
    }

    if (action == 'decline') {
      if (arguments['display_name'] != null) {
        throw const ProfileNameServiceException(
          'A declined name prompt cannot include a display name.',
        );
      }
      await _persistCloudState(
        status: 'declined',
        source: 'user',
      );
      return const ProfileNameToolResult(status: 'declined');
    }

    final displayName = normalizeDisplayName(arguments['display_name']);
    if (displayName == null) {
      throw const ProfileNameServiceException(
        'Please ask the user what they would like to be called.',
      );
    }

    await _persistCloudState(
      status: 'known',
      source: 'assistant',
      displayName: displayName,
    );
    final current = await _database.getProfile(profileId);
    if (current != null) {
      await _database.updateProfile(current.copyWith(name: displayName));
    }
    return ProfileNameToolResult(
      status: 'known',
      displayName: displayName,
    );
  }

  static String? normalizeDisplayName(Object? value) {
    if (value is! String) return null;
    final compact = value.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (compact.isEmpty ||
        compact.length > 80 ||
        compact.toLowerCase() == 'user' ||
        compact.contains(RegExp(r'[\u0000-\u001f\u007f]'))) {
      return null;
    }
    return compact;
  }

  Future<void> _persistCloudState({
    required String status,
    required String source,
    String? displayName,
  }) async {
    if (!_supabase.isAuthenticated || _supabase.currentUser == null) {
      throw const ProfileNameServiceException(
        'Sign in to save how HowAI should address you.',
      );
    }
    final now = DateTime.now().toUtc().toIso8601String();
    final user = _supabase.currentUser!;
    try {
      await _supabase.client
          .from('profiles')
          .upsert({
            'id': user.id,
            if (user.email != null) 'email': user.email,
            if (displayName != null) 'name': displayName,
            'name_status': status,
            'name_source': source,
            'name_prompted_at': now,
            'updated_at': now,
          })
          .select('id')
          .single();
    } catch (error) {
      debugPrint('[ProfileNameService] Preferred name update failed: $error');
      throw const ProfileNameServiceException(
        'I could not save that preferred name right now.',
      );
    }
  }
}
