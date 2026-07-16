enum ReminderStatus { active, paused, completed }

enum ReminderFrequency { daily, weekly, monthly }

class ReminderRecurrence {
  const ReminderRecurrence({
    required this.frequency,
    required this.interval,
    required this.weekdays,
    this.dayOfMonth,
    this.monthWeek,
    this.monthWeekday,
    this.endsAt,
    this.endsOnDate,
  }) : assert(endsAt == null || endsOnDate == null);

  factory ReminderRecurrence.fromJson(Map<String, dynamic> json) {
    return ReminderRecurrence(
      frequency: ReminderFrequency.values.byName(json['frequency'] as String),
      interval: (json['interval'] as num).toInt(),
      weekdays: (json['weekdays'] as List? ?? const [])
          .map((value) => (value as num).toInt())
          .toList(growable: false),
      dayOfMonth: (json['day_of_month'] as num?)?.toInt(),
      monthWeek: (json['month_week'] as num?)?.toInt(),
      monthWeekday: (json['month_weekday'] as num?)?.toInt(),
      endsAt: json['ends_at'] == null
          ? null
          : DateTime.parse(json['ends_at'] as String).toUtc(),
    );
  }

  final ReminderFrequency frequency;
  final int interval;
  final List<int> weekdays;
  final int? dayOfMonth;
  final int? monthWeek;
  final int? monthWeekday;
  final DateTime? endsAt;
  final String? endsOnDate;

  Map<String, dynamic> toJson() => {
        'frequency': frequency.name,
        'interval': interval,
        'weekdays': weekdays,
        'day_of_month': dayOfMonth,
        'month_week': monthWeek,
        'month_weekday': monthWeekday,
        'ends_at': endsOnDate ?? endsAt?.toUtc().toIso8601String(),
      };

  String get compactLabel {
    switch (frequency) {
      case ReminderFrequency.daily:
        return interval == 1 ? 'Daily' : 'Every $interval days';
      case ReminderFrequency.weekly:
        final days = weekdays.map(reminderWeekdayName).join(', ');
        return interval == 1
            ? 'Weekly · $days'
            : 'Every $interval weeks · $days';
      case ReminderFrequency.monthly:
        final pattern = dayOfMonth != null
            ? 'day $dayOfMonth'
            : '${reminderOrdinalName(monthWeek)} '
                '${reminderWeekdayName(monthWeekday ?? 1)}';
        return interval == 1
            ? 'Monthly · $pattern'
            : 'Every $interval months · $pattern';
    }
  }
}

String reminderWeekdayName(int day) =>
    const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];

String reminderOrdinalName(int? week) {
  switch (week) {
    case 1:
      return 'First';
    case 2:
      return 'Second';
    case 3:
      return 'Third';
    case 4:
      return 'Fourth';
    case -1:
      return 'Last';
    default:
      return 'First';
  }
}

class Reminder {
  const Reminder({
    required this.id,
    required this.userId,
    required this.title,
    required this.timezone,
    required this.startLocal,
    required this.nextFireAt,
    required this.status,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
    this.conversationId,
    this.notes,
    this.recurrence,
    this.lastDeliveryStatus,
    this.lastDeliveryAt,
  });

  factory Reminder.fromJson(Map<String, dynamic> json) {
    final recurrence = json['recurrence_rule'];
    return Reminder(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      conversationId: json['conversation_id'] as String?,
      title: json['title'] as String,
      notes: json['notes'] as String?,
      timezone: json['timezone'] as String,
      startLocal: DateTime.parse(
        (json['start_local'] as String).replaceFirst(' ', 'T'),
      ),
      nextFireAt: DateTime.parse(json['next_fire_at'] as String).toUtc(),
      recurrence: recurrence is Map
          ? ReminderRecurrence.fromJson(Map<String, dynamic>.from(recurrence))
          : null,
      status: ReminderStatus.values.byName(json['status'] as String),
      version: (json['version'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      updatedAt: DateTime.parse(json['updated_at'] as String).toUtc(),
      lastDeliveryStatus: json['last_delivery_status'] as String?,
      lastDeliveryAt: json['last_delivery_at'] == null
          ? null
          : DateTime.parse(json['last_delivery_at'] as String).toUtc(),
    );
  }

  final String id;
  final String userId;
  final String? conversationId;
  final String title;
  final String? notes;
  final String timezone;
  final DateTime startLocal;
  final DateTime nextFireAt;
  final ReminderRecurrence? recurrence;
  final ReminderStatus status;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? lastDeliveryStatus;
  final DateTime? lastDeliveryAt;

  bool get isRecurring => recurrence != null;

  bool get lastDeliveryNeedsAttention =>
      lastDeliveryStatus == 'failed' || lastDeliveryStatus == 'no_devices';

  Map<String, dynamic> scheduleArguments() => {
        'title': title,
        'notes': notes,
        'timezone': timezone,
        'start_local': _localTimestamp(startLocal),
        'recurrence': recurrence?.toJson(),
      };

  /// Bounded, user-owned state supplied to the reminder update tool. The
  /// backend still validates ownership and [version] before execution.
  Map<String, dynamic> agentUpdateContext() => {
        'reminder_id': id,
        'expected_version': version,
        'status': status.name,
        ...scheduleArguments(),
      };

  static String _localTimestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-'
        '${two(value.month)}-${two(value.day)}T${two(value.hour)}:'
        '${two(value.minute)}:${two(value.second)}';
  }
}
