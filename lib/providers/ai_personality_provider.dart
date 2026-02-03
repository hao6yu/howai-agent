import 'package:flutter/foundation.dart';
import '../models/ai_personality.dart';
import '../services/database_service.dart';

class AIPersonalityProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  Map<int, AIPersonality> _personalitiesByProfile = {};
  bool _isLoading = false;

  Map<int, AIPersonality> get personalitiesByProfile => _personalitiesByProfile;
  bool get isLoading => _isLoading;

  // Get AI personality for a specific profile
  AIPersonality? getPersonalityForProfile(int profileId) {
    return _personalitiesByProfile[profileId];
  }

  // Load AI personality for a specific profile
  Future<void> loadPersonalityForProfile(int profileId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final personalityMap = await _db.getAIPersonalityForProfile(profileId);
      if (personalityMap != null) {
        _personalitiesByProfile[profileId] = AIPersonality.fromMap(personalityMap);
      } else {
        // Create default personality if none exists
        final defaultPersonality = AIPersonality.createDefault(profileId);
        final id = await _db.insertAIPersonality(defaultPersonality);
        _personalitiesByProfile[profileId] = defaultPersonality.copyWith(id: id);
      }
    } catch (e) {
      // debugPrint('Error loading AI personality for profile $profileId: $e');
      // Fallback to default personality
      _personalitiesByProfile[profileId] = AIPersonality.createDefault(profileId);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update AI personality
  Future<bool> updatePersonality(AIPersonality personality) async {
    try {
      await _db.updateAIPersonality(personality);
      _personalitiesByProfile[personality.profileId] = personality;
      notifyListeners();
      return true;
    } catch (e) {
      // debugPrint('Error updating AI personality: $e');
      return false;
    }
  }

  // Create new AI personality
  Future<bool> createPersonality(AIPersonality personality) async {
    try {
      final id = await _db.insertAIPersonality(personality);
      _personalitiesByProfile[personality.profileId] = personality.copyWith(id: id);
      notifyListeners();
      return true;
    } catch (e) {
      // debugPrint('Error creating AI personality: $e');
      return false;
    }
  }

  // Reset to default personality
  Future<bool> resetToDefault(int profileId) async {
    try {
      final defaultPersonality = AIPersonality.createDefault(profileId);
      final existingPersonality = _personalitiesByProfile[profileId];

      if (existingPersonality != null) {
        // Update existing
        final updatedPersonality = defaultPersonality.copyWith(id: existingPersonality.id);
        await _db.updateAIPersonality(updatedPersonality);
        _personalitiesByProfile[profileId] = updatedPersonality;
      } else {
        // Create new
        final id = await _db.insertAIPersonality(defaultPersonality);
        _personalitiesByProfile[profileId] = defaultPersonality.copyWith(id: id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      // debugPrint('Error resetting AI personality to default: $e');
      return false;
    }
  }

  // Clear all personalities (used when profile is deleted)
  void clearPersonalityForProfile(int profileId) {
    _personalitiesByProfile.remove(profileId);
    notifyListeners();
  }

  // Clear all personalities
  void clearAll() {
    _personalitiesByProfile.clear();
    notifyListeners();
  }
}
