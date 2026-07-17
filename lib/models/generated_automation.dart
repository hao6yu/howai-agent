enum GeneratedAutomationKind { newsBriefing, marketBriefing }

enum GeneratedAutomationStatus { active, paused, completed }

enum GeneratedAutomationFrequency { once, daily, weekly, marketDays }

class GeneratedAutomationSchedule {
  const GeneratedAutomationSchedule({
    required this.frequency,
    required this.interval,
    required this.weekdays,
    this.endsAt,
  });

  factory GeneratedAutomationSchedule.fromJson(Map<String, dynamic> json) {
    return GeneratedAutomationSchedule(
      frequency: switch (json['frequency']) {
        'once' => GeneratedAutomationFrequency.once,
        'daily' => GeneratedAutomationFrequency.daily,
        'weekly' => GeneratedAutomationFrequency.weekly,
        'market_days' => GeneratedAutomationFrequency.marketDays,
        _ => throw const FormatException('Unsupported Automation frequency.'),
      },
      interval: (json['interval'] as num?)?.toInt() ?? 1,
      weekdays: (json['weekdays'] as List? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(growable: false),
      endsAt: json['ends_at'] == null
          ? null
          : DateTime.parse(json['ends_at'] as String).toUtc(),
    );
  }

  final GeneratedAutomationFrequency frequency;
  final int interval;
  final List<int> weekdays;
  final DateTime? endsAt;

  bool get isRecurring => frequency != GeneratedAutomationFrequency.once;

  String get compactLabel {
    switch (frequency) {
      case GeneratedAutomationFrequency.once:
        return 'One time';
      case GeneratedAutomationFrequency.daily:
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case GeneratedAutomationFrequency.weekly:
        final days = weekdays.map(_weekdayName).join(', ');
        final cadence = interval == 1 ? 'Weekly' : 'Every $interval weeks';
        return days.isEmpty ? cadence : '$cadence · $days';
      case GeneratedAutomationFrequency.marketDays:
        return interval == 1 ? 'Market days' : 'Every $interval market days';
    }
  }

  static String _weekdayName(int value) {
    if (value < DateTime.monday || value > DateTime.sunday) return 'Day';
    return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][value - 1];
  }
}

class GeneratedAutomation {
  const GeneratedAutomation({
    required this.id,
    required this.userId,
    required this.kind,
    required this.title,
    required this.status,
    required this.version,
    required this.timezone,
    required this.startLocal,
    required this.schedule,
    required this.nextRunAt,
    required this.config,
    required this.sourcePolicy,
    required this.deliveryPreferences,
    required this.createdAt,
    required this.updatedAt,
    this.conversationId,
    this.lastRunAt,
  });

  factory GeneratedAutomation.fromJson(Map<String, dynamic> json) {
    final schedule = json['schedule_rule'];
    final config = json['config'];
    final sourcePolicy = json['source_policy'];
    final deliveryPreferences = json['delivery_preferences'];
    if (schedule is! Map ||
        config is! Map ||
        sourcePolicy is! Map ||
        deliveryPreferences is! Map) {
      throw const FormatException('Invalid Automation data.');
    }
    return GeneratedAutomation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String?,
      kind: switch (json['kind']) {
        'news_briefing' => GeneratedAutomationKind.newsBriefing,
        'market_briefing' => GeneratedAutomationKind.marketBriefing,
        _ => throw const FormatException('Unsupported Automation kind.'),
      },
      title: json['title'] as String,
      status: switch (json['status']) {
        'active' => GeneratedAutomationStatus.active,
        'paused' => GeneratedAutomationStatus.paused,
        'completed' => GeneratedAutomationStatus.completed,
        _ => throw const FormatException('Unsupported Automation status.'),
      },
      version: (json['version'] as num).toInt(),
      timezone: json['timezone'] as String,
      startLocal: DateTime.parse(
        (json['start_local'] as String).replaceFirst(' ', 'T'),
      ),
      schedule: GeneratedAutomationSchedule.fromJson(
        Map<String, dynamic>.from(schedule),
      ),
      nextRunAt: DateTime.parse(json['next_run_at'] as String).toUtc(),
      config: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(config),
      ),
      sourcePolicy: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(sourcePolicy),
      ),
      deliveryPreferences: Map<String, dynamic>.unmodifiable(
        Map<String, dynamic>.from(deliveryPreferences),
      ),
      lastRunAt: json['last_run_at'] == null
          ? null
          : DateTime.parse(json['last_run_at'] as String).toUtc(),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
    );
  }

  final String id;
  final String userId;
  final String? conversationId;
  final GeneratedAutomationKind kind;
  final String title;
  final GeneratedAutomationStatus status;
  final int version;
  final String timezone;
  final DateTime startLocal;
  final GeneratedAutomationSchedule schedule;
  final DateTime nextRunAt;
  final Map<String, dynamic> config;
  final Map<String, dynamic> sourcePolicy;
  final Map<String, dynamic> deliveryPreferences;
  final DateTime? lastRunAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get kindLabel => kind == GeneratedAutomationKind.newsBriefing
      ? 'News briefing'
      : 'Market briefing';

  String get scopeLabel {
    if (kind == GeneratedAutomationKind.newsBriefing) {
      final count = (config['item_count'] as num?)?.toInt();
      final topics = (config['topics'] as List? ?? const [])
          .whereType<String>()
          .map((topic) => topic.trim())
          .where((topic) => topic.isNotEmpty)
          .take(2)
          .join(', ');
      final countLabel = count == null ? null : '$count stories';
      return [countLabel, if (topics.isNotEmpty) topics]
          .whereType<String>()
          .join(' · ');
    }
    return kindLabel;
  }
}
