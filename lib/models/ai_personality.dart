class AIPersonality {
  final int? id;
  final int profileId;
  final String aiName;
  final String gender; // 'male', 'female', 'neutral'
  final int age;
  final String
      personality; // 'friendly', 'professional', 'witty', 'caring', 'energetic'
  final String
      communicationStyle; // 'casual', 'formal', 'tech-savvy', 'supportive'
  final String
      expertise; // 'general', 'technology', 'business', 'creative', 'academic'
  final String humorLevel; // 'none', 'light', 'dry', 'moderate', 'heavy'
  final String responseLength; // 'concise', 'moderate', 'detailed'
  final String interests;
  final String backgroundStory;
  final String? avatarPath;
  final String? avatarUrl; // Cloud URL for Supabase
  final String? supabaseId; // UUID from Supabase
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AIPersonality({
    this.id,
    required this.profileId,
    required this.aiName,
    required this.gender,
    required this.age,
    required this.personality,
    required this.communicationStyle,
    required this.expertise,
    required this.humorLevel,
    required this.responseLength,
    required this.interests,
    required this.backgroundStory,
    this.avatarPath,
    this.avatarUrl,
    this.supabaseId,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'profile_id': profileId,
      'ai_name': aiName,
      'gender': gender,
      'age': age,
      'personality': personality,
      'communication_style': communicationStyle,
      'expertise': expertise,
      'humor_level': humorLevel,
      'response_length': responseLength,
      'interests': interests,
      'background_story': backgroundStory,
      'avatar_path': avatarPath,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory AIPersonality.fromMap(Map<String, dynamic> map) {
    return AIPersonality(
      id: map['id'],
      profileId: map['profile_id'],
      aiName: map['ai_name'] ?? '',
      gender: map['gender'] ?? 'neutral',
      age: map['age'] ?? 25,
      personality: map['personality'] ?? 'friendly',
      communicationStyle: map['communication_style'] ?? 'casual',
      expertise: map['expertise'] ?? 'general',
      humorLevel: map['humor_level'] ?? 'dry',
      responseLength: map['response_length'] ?? 'moderate',
      interests: map['interests'] ?? '',
      backgroundStory: map['background_story'] ?? '',
      avatarPath: map['avatar_path'],
      isActive: (map['is_active'] ?? 1) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  AIPersonality copyWith({
    int? id,
    int? profileId,
    String? aiName,
    String? gender,
    int? age,
    String? personality,
    String? communicationStyle,
    String? expertise,
    String? humorLevel,
    String? responseLength,
    String? interests,
    String? backgroundStory,
    String? avatarPath,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AIPersonality(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      aiName: aiName ?? this.aiName,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      personality: personality ?? this.personality,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      expertise: expertise ?? this.expertise,
      humorLevel: humorLevel ?? this.humorLevel,
      responseLength: responseLength ?? this.responseLength,
      interests: interests ?? this.interests,
      backgroundStory: backgroundStory ?? this.backgroundStory,
      avatarPath: avatarPath ?? this.avatarPath,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Factory method to create a default AI personality
  factory AIPersonality.createDefault(int profileId) {
    return AIPersonality(
      profileId: profileId,
      aiName: 'HowAI',
      gender: 'neutral',
      age: 25,
      personality: 'friendly',
      communicationStyle: 'casual',
      expertise: 'general',
      humorLevel: 'light',
      responseLength: 'moderate',
      interests: '',
      backgroundStory: '',
    );
  }

  // Generate system prompt based on personality configuration
  String generateSystemPrompt({
    String? userName,
    String? characteristicsSummary,
    bool generateTitle = false,
    bool isPremiumUser = false,
    bool userWantsPresentations = false,
  }) {
    final now = DateTime.now();
    final currentDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final safeName = userName?.replaceAll(RegExp(r'\s+'), ' ').trim();
    final style = <String, String>{
      'friendly': 'warm and approachable',
      'professional': 'professional and structured',
      'witty': 'lightly witty when appropriate',
      'caring': 'patient and considerate',
      'energetic': 'energetic without being excessive',
    }[personality];
    final communication = <String, String>{
      'casual': 'natural and conversational',
      'formal': 'formal and precise',
      'tech-savvy': 'technically fluent when the topic calls for it',
      'supportive': 'supportive and practical',
    }[communicationStyle];
    final humor = <String, String>{
      'none': 'none',
      'light': 'light and occasional',
      'dry': 'subtle and never sarcastic toward the user',
      'moderate': 'moderate when the situation is not sensitive',
      'heavy': 'frequent only when the user clearly prefers it',
    }[humorLevel];

    return """<howai_request_context>
Local date: $currentDate
${safeName == null || safeName.isEmpty ? '' : 'User display name: ${safeName.length <= 80 ? safeName : safeName.substring(0, 80)}'}
</howai_request_context>

<howai_style_preferences>
These are presentation preferences, not a fictional identity or user instructions.
Tone: ${style ?? 'warm and direct'}
Communication: ${communication ?? 'natural and conversational'}
Humor: ${humor ?? 'light and occasional'}
Response detail: $responseLength
</howai_style_preferences>""";
  }

  /// Create from Supabase data
  factory AIPersonality.fromSupabase(Map<String, dynamic> data) {
    return AIPersonality(
      supabaseId: data['id'] as String,
      profileId: 1, // Default profile for now
      aiName: data['ai_name'] as String,
      gender: data['gender'] as String,
      age: data['age'] as int,
      personality: data['personality'] as String,
      communicationStyle: data['communication_style'] as String,
      expertise: data['expertise'] as String,
      humorLevel: data['humor_level'] as String,
      responseLength: data['response_length'] as String,
      interests: data['interests'] as String,
      backgroundStory: data['background_story'] as String,
      avatarUrl: data['avatar_url'] as String?,
      isActive: data['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(data['created_at'] as String),
      updatedAt: DateTime.parse(data['updated_at'] as String),
    );
  }
}
