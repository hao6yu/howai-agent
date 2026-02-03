class Profile {
  final int? id;
  final String name;
  final DateTime createdAt;
  final Map<String, dynamic> characteristics;
  final Map<String, dynamic> preferences;
  final String? avatarPath;

  Profile({
    this.id,
    required this.name,
    DateTime? createdAt,
    this.characteristics = const {},
    this.preferences = const {},
    this.avatarPath,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
      'characteristics': characteristics,
      'preferences': preferences,
      'avatarPath': avatarPath,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      name: map['name'],
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
      characteristics: map['characteristics'] ?? {},
      preferences: map['preferences'] ?? {},
      avatarPath: map['avatarPath'],
    );
  }

  Profile copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    Map<String, dynamic>? characteristics,
    Map<String, dynamic>? preferences,
    String? avatarPath,
  }) {
    return Profile(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      characteristics: characteristics ?? this.characteristics,
      preferences: preferences ?? this.preferences,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }
}
