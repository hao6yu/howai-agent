import 'package:flutter/foundation.dart';
import '../models/profile.dart';
import '../services/database_service.dart';
import '../services/supabase_service.dart';
import '../services/image_service.dart';

class ProfileProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  List<Profile> _profiles = [];
  int? _selectedProfileId;
  bool _chatHistoryCleared = false;

  List<Profile> get profiles => _profiles;
  int? get selectedProfileId => _selectedProfileId;
  bool get chatHistoryCleared => _chatHistoryCleared;

  Future<void> loadProfiles() async {
    _profiles = await _db.getProfiles();

    // If no profile is selected and we have profiles, select the first one
    if (_selectedProfileId == null && _profiles.isNotEmpty) {
      _selectedProfileId = _profiles.first.id;
    }

    notifyListeners();
  }

  Future<void> addProfile(Profile profile) async {
    final id = await _db.insertProfile(profile);
    final newProfile = Profile(
      id: id,
      name: profile.name,
      createdAt: profile.createdAt,
    );
    _profiles.add(newProfile);
    notifyListeners();
  }

  void selectProfile(int? id) {
    _selectedProfileId = id;
    notifyListeners();
  }

  Future<void> updateProfile(Profile profile) async {
    await _db.updateProfile(profile);
    final index = _profiles.indexWhere((p) => p.id == profile.id);
    if (index != -1) {
      _profiles[index] = profile;
      notifyListeners();
      
      // Sync to Supabase in background
      _syncProfileToSupabase(profile);
    }
  }

  Future<void> updateProfileCharacteristics(int id, Map<String, dynamic> characteristics) async {
    final profile = _profiles.firstWhere((p) => p.id == id);
    final updatedProfile = profile.copyWith(
      characteristics: characteristics,
    );
    await _db.updateProfile(updatedProfile);
    await loadProfiles();
    
    // Sync characteristics to Supabase in background
    _syncProfileToSupabase(updatedProfile);
  }

  Future<void> updateProfilePreferences(int id, Map<String, dynamic> preferences) async {
    final profile = _profiles.firstWhere((p) => p.id == id);
    final updatedProfile = profile.copyWith(
      preferences: preferences,
    );
    await _db.updateProfile(updatedProfile);
    await loadProfiles();
    
    // Sync preferences to Supabase in background
    _syncProfileToSupabase(updatedProfile);
  }

  Future<void> deleteProfile(int id) async {
    await _db.deleteProfile(id);
    _profiles.removeWhere((profile) => profile.id == id);
    if (_selectedProfileId == id) {
      _selectedProfileId = null;
    }
    notifyListeners();
  }

  Future<void> resetDatabase() async {
    await _db.deleteDatabase();
    _profiles = [];
    _selectedProfileId = null;
    notifyListeners();
  }

  void clearChatHistoryNotify() {
    _chatHistoryCleared = true;
    notifyListeners();
  }

  void resetChatHistoryClearedFlag() {
    _chatHistoryCleared = false;
  }

  /// Sync profile to Supabase (silent background operation)
  void _syncProfileToSupabase(Profile profile) {
    Future.microtask(() async {
      try {
        final supabase = SupabaseService();
        
        if (!supabase.isAuthenticated) {
          debugPrint('[ProfileProvider] Not authenticated, skipping profile sync');
          return;
        }

        final userId = supabase.currentUser!.id;
        
        // Upload avatar if it's a local file
        String? avatarUrl;
        if (profile.avatarPath != null && !profile.avatarPath!.startsWith('http')) {
          avatarUrl = await ImageService.uploadImageToSupabase(profile.avatarPath!);
        } else {
          avatarUrl = profile.avatarPath;
        }
        
        // Sync basic profile info to 'profiles' table
        final profileData = {
          'user_id': userId,
          'name': profile.name,
          'avatar_url': avatarUrl,
          'updated_at': DateTime.now().toIso8601String(),
        };

        await supabase.client
            .from('profiles')
            .upsert(profileData);
        
        debugPrint('[ProfileProvider] Basic profile synced to Supabase');
        
        // Sync characteristics/AI insights to 'user_profiles' table
        await _syncCharacteristicsToSupabase(profile, userId);
        
      } catch (e) {
        debugPrint('[ProfileProvider] Error syncing profile (silent): $e');
        // Silent failure - profile still works locally
      }
    });
  }
  
  /// Sync characteristics/AI insights to user_profiles table
  Future<void> _syncCharacteristicsToSupabase(Profile profile, String userId) async {
    try {
      final supabase = SupabaseService();
      final characteristics = profile.characteristics;
      
      if (characteristics.isEmpty) {
        debugPrint('[ProfileProvider] No characteristics to sync');
        return;
      }
      
      // Map local characteristics to user_profiles table columns
      final userProfileData = {
        'user_id': userId,
        'communication_style': characteristics['communication_style'] ?? {},
        'topic_interests': characteristics['interests'] ?? {},
        'characteristics': {
          'personality': characteristics['personality'],
          'expertise': characteristics['expertise'],
        },
        'preferences': profile.preferences,
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      // Upsert to user_profiles table (insert or update based on user_id)
      await supabase.client
          .from('user_profiles')
          .upsert(userProfileData, onConflict: 'user_id');
      
      debugPrint('[ProfileProvider] Characteristics synced to user_profiles table');
    } catch (e) {
      debugPrint('[ProfileProvider] Error syncing characteristics (silent): $e');
      // Silent failure - characteristics still work locally
    }
  }

  /// Load profile from Supabase (for cross-device sync)
  Future<void> loadProfileFromSupabase() async {
    try {
      final supabase = SupabaseService();
      
      if (!supabase.isAuthenticated) {
        debugPrint('[ProfileProvider] Not authenticated, skipping profile load');
        return;
      }

      final userId = supabase.currentUser!.id;
      
      // Load basic profile from 'profiles' table
      final profileResponse = await supabase.client
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      String? name;
      String? avatarUrl;
      
      if (profileResponse != null) {
        name = profileResponse['name'] as String?;
        avatarUrl = profileResponse['avatar_url'] as String?;
        debugPrint('[ProfileProvider] Loaded basic profile: name=$name');
      }
      
      // Load characteristics/AI insights from 'user_profiles' table
      final userProfileResponse = await supabase.client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();
      
      Map<String, dynamic> characteristics = {};
      Map<String, dynamic> preferences = {};
      
      if (userProfileResponse != null) {
        // Map user_profiles columns back to local characteristics format
        final communicationStyle = userProfileResponse['communication_style'];
        final topicInterests = userProfileResponse['topic_interests'];
        final charData = userProfileResponse['characteristics'] as Map<String, dynamic>?;
        final prefsData = userProfileResponse['preferences'] as Map<String, dynamic>?;
        
        if (communicationStyle != null) {
          characteristics['communication_style'] = communicationStyle;
        }
        if (topicInterests != null) {
          characteristics['interests'] = topicInterests;
        }
        if (charData != null) {
          if (charData['personality'] != null) {
            characteristics['personality'] = charData['personality'];
          }
          if (charData['expertise'] != null) {
            characteristics['expertise'] = charData['expertise'];
          }
        }
        if (prefsData != null) {
          preferences = prefsData;
        }
        
        debugPrint('[ProfileProvider] Loaded characteristics from user_profiles: ${characteristics.keys.toList()}');
      }
      
      // Update local profile if we have data
      if (_profiles.isNotEmpty) {
        final currentProfile = _profiles.first;
        
        // Only update if we have new data from cloud
        final hasCloudData = name != null || 
                             avatarUrl != null || 
                             characteristics.isNotEmpty || 
                             preferences.isNotEmpty;
        
        if (hasCloudData) {
          // Merge cloud characteristics with local (cloud takes precedence)
          final mergedCharacteristics = Map<String, dynamic>.from(currentProfile.characteristics);
          mergedCharacteristics.addAll(characteristics);
          
          final mergedPreferences = Map<String, dynamic>.from(currentProfile.preferences);
          mergedPreferences.addAll(preferences);
          
          final updatedProfile = currentProfile.copyWith(
            name: name ?? currentProfile.name,
            avatarPath: avatarUrl ?? currentProfile.avatarPath,
            characteristics: mergedCharacteristics,
            preferences: mergedPreferences,
          );
          
          await _db.updateProfile(updatedProfile);
          await loadProfiles();
          
          debugPrint('[ProfileProvider] Profile synced from Supabase successfully');
        }
      }
    } catch (e) {
      debugPrint('[ProfileProvider] Error loading profile from Supabase (silent): $e');
      // Silent failure - use local profile
    }
  }
}
