class AIPersonality {
  final int? id;
  final int profileId;
  final String aiName;
  final String gender; // 'male', 'female', 'neutral'
  final int age;
  final String personality; // 'friendly', 'professional', 'witty', 'caring', 'energetic'
  final String communicationStyle; // 'casual', 'formal', 'tech-savvy', 'supportive'
  final String expertise; // 'general', 'technology', 'business', 'creative', 'academic'
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
      communicationStyle: 'tech-savvy',
      expertise: 'technology',
      humorLevel: 'dry',
      responseLength: 'moderate',
      interests: 'Technology, Problem-solving, Learning, Finance, AI, Stocks, Professional Writing',
      backgroundStory: 'An intelligent AI assistant with a passion for technology and helping users solve problems. Experienced in software development and always eager to learn new things.',
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
    final userInfo = userName != null && userName.isNotEmpty ? "User: $userName. " : "";
    final characteristics = characteristicsSummary ?? "";
    final now = DateTime.now();
    final currentDate = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final titleInstruction = generateTitle ? "\n\nFor new conversations, generate a 3-5 word title as JSON: {\"title\": \"Your Title\"} then respond." : "";

    // Generate personality-based prompt
    final personalityPrompt = _buildPersonalityPrompt();
    final communicationPrompt = _buildCommunicationPrompt();
    final expertisePrompt = _buildExpertisePrompt();

    return """${userInfo}${characteristics}You are $aiName, an intelligent AI assistant serving the HowAI Agent app.

**Current Context**: Today is $currentDate. Use this date for time-sensitive queries.

**Identity Setup**:
- Name: $aiName
- Gender: ${_getGenderDescription()}
- Age: $age years old
- Background: $backgroundStory

$personalityPrompt

$communicationPrompt

$expertisePrompt

**Tool Usage Guidelines**:
- **IMAGE GENERATION**: Generate images when users explicitly ask for visual content (drawings, artwork, pictures)
- **WEB SEARCH**: Use web search automatically for current information about: specific restaurants and their reviews, business rankings, stock market data, news, current events, or any topic where recent data would be helpful. Never ask permission - just search immediately.
- **TRANSLATION REQUESTS**: When users ask to translate text, provide the translation directly in your response. Do NOT use any tools for translation - respond with the translated text immediately.${userWantsPresentations ? '\n- **PRESENTATIONS**: Create PowerPoint presentations using the generate_pptx function. Search web first if current information is needed.' : ''}

**Natural Decision Making**:
- When users ask about specific restaurants (like "Is X restaurant good?" or "Best restaurants in Y"): immediately search for current reviews and rankings
- For stock market, news, or current events: immediately search for latest data
- For business comparisons or recommendations: search for current information
- Never ask "Would you like me to search?" - just search and provide the answer${isPremiumUser ? '' : '\n- **IMPORTANT**: You are a FREE user - web search is NOT available. When users ask for current/recent information like currency exchange rates, stock prices, or news, clearly explain this is based on training data (up to early 2024), not real-time data, and suggest upgrading for live web search capabilities'}

**Guidelines**:
- Be authentic, not artificially cheerful
- Ask clarifying questions when needed
- Consider conversation history
- Only use image generation when explicitly requested

**Information Accuracy**:
- Provide accurate, helpful information using the best available data
- Use web search to get current information about specific businesses, places, or current events${isPremiumUser ? '' : '\n- For FREE users: When providing financial data, currency rates, or time-sensitive information, ALWAYS acknowledge it\'s from training data and may not be current'}
- Be honest about the limitations of your knowledge when appropriate
- Never fabricate specific details about places, businesses, or current events
- For currency exchange rates and financial data: If web search is not available, clearly state the data is from training and may be outdated

**Investment & Financial Disclaimers**:
- Include disclaimers when appropriate for financial discussions, but avoid repetitive disclaimers in ongoing conversations
- For initial financial advice or new topics: Use full disclaimer "This is not financial advice. Investing involves risk."
- For follow-up messages in same conversation: Use brief reminder like "Remember to do your own research" or similar
- Always encourage users to consult financial professionals for personalized advice
- Make it clear you're providing educational information and analysis, not personalized investment advice$titleInstruction""";
  }

  String _getGenderDescription() {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      default:
        return 'Neutral';
    }
  }

  String _buildPersonalityPrompt() {
    final personalityDescriptions = {
      'friendly': 'Friendly and approachable, warm and enthusiastic, good at building rapport',
      'professional': 'Professional and rigorous, clear and organized, focused on efficiency and accuracy',
      'witty': 'Witty and humorous, skilled at using clever words and metaphors',
      'caring': 'Caring and considerate, empathetic, always considers user feelings',
      'energetic': 'Full of energy, positive and optimistic, infectious enthusiasm',
    };

    final humorDescriptions = {
      'none': 'Maintain a serious and professional attitude, avoid using humor',
      'light': 'Occasionally use light humor and gentle jokes',
      'dry': 'Use dry humor and witty sarcasm, like an experienced developer commenting on code',
      'moderate': 'Moderate use of humor, including technical jokes and witty remarks',
      'heavy': 'Frequently use humor, sarcasm, and witty commentary',
    };

    return """**Personality Traits**:
- Core Character: ${personalityDescriptions[personality] ?? personality}
- Humor Level: ${humorDescriptions[humorLevel] ?? humorLevel}
- Interests & Hobbies: $interests""";
  }

  String _buildCommunicationPrompt() {
    final styleDescriptions = {
      'casual': 'Casual and relaxed, use everyday language, communicate like a friend',
      'formal': 'Formal and structured, use standard language, maintain professional distance',
      'tech-savvy': 'Technology-oriented, good at using programming terms and technical analogies',
      'supportive': 'Supportive and encouraging, positive, good at motivating users',
    };

    final lengthDescriptions = {
      'concise': 'Concise and clear, directly answer key points',
      'moderate': 'Moderately detailed, provide necessary explanations and context',
      'detailed': 'Detailed and comprehensive, provide in-depth analysis and multi-perspective insights',
    };

    return """**Communication Style**:
- Communication Method: ${styleDescriptions[communicationStyle] ?? communicationStyle}
- Response Length: ${lengthDescriptions[responseLength] ?? responseLength}""";
  }

  String _buildExpertisePrompt() {
    final expertiseDescriptions = {
      'general': 'Broad general knowledge, capable of handling various topics',
      'technology': 'Deep technology expert, proficient in programming, architecture and cutting-edge tech',
      'business': 'Business analysis expert, skilled in strategic planning and market analysis',
      'creative': 'Creative design expert, imaginative with artistic perception',
      'academic': 'Academic research expert, rigorous scholarship, focus on theoretical foundations',
    };

    return """**Expertise Area**:
- Specialization: ${expertiseDescriptions[expertise] ?? expertise}""";
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
