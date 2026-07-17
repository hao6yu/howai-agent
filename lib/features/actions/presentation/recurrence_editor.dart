import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/reminder.dart';

enum _MonthlyPattern { dayOfMonth, ordinalWeekday }

class RecurrenceEditResult {
  const RecurrenceEditResult(this.recurrence);

  final ReminderRecurrence? recurrence;
}

Future<RecurrenceEditResult?> showRecurrenceEditor({
  required BuildContext context,
  required ReminderRecurrence? initial,
  required DateTime start,
}) {
  return showDialog<RecurrenceEditResult>(
    context: context,
    builder: (_) => _RecurrenceEditorDialog(initial: initial, start: start),
  );
}

DateTime alignStartToRecurrence(
  DateTime start,
  ReminderRecurrence? recurrence,
) {
  if (recurrence == null || recurrence.frequency == ReminderFrequency.daily) {
    return start;
  }
  if (recurrence.frequency == ReminderFrequency.weekly) {
    for (var offset = 0; offset < 7; offset++) {
      final candidate = DateTime(
        start.year,
        start.month,
        start.day + offset,
        start.hour,
        start.minute,
        start.second,
      );
      if (recurrence.weekdays.contains(candidate.weekday)) return candidate;
    }
    return start;
  }

  for (var monthOffset = 0; monthOffset < 24; monthOffset++) {
    final monthIndex = start.month - 1 + monthOffset;
    final year = start.year + monthIndex ~/ 12;
    final month = monthIndex % 12 + 1;
    final day = recurrence.dayOfMonth ??
        _ordinalWeekdayDay(
          year,
          month,
          recurrence.monthWeek ?? 1,
          recurrence.monthWeekday ?? start.weekday,
        );
    if (day > _daysInMonth(year, month)) continue;
    final candidate = DateTime(
      year,
      month,
      day,
      start.hour,
      start.minute,
      start.second,
    );
    if (!candidate.isBefore(start)) return candidate;
  }
  return start;
}

class _RecurrenceEditorDialog extends StatefulWidget {
  const _RecurrenceEditorDialog({required this.initial, required this.start});

  final ReminderRecurrence? initial;
  final DateTime start;

  @override
  State<_RecurrenceEditorDialog> createState() =>
      _RecurrenceEditorDialogState();
}

class _RecurrenceEditorDialogState extends State<_RecurrenceEditorDialog> {
  late bool _repeats;
  late ReminderFrequency _frequency;
  late int _interval;
  late Set<int> _weekdays;
  late _MonthlyPattern _monthlyPattern;
  late int _dayOfMonth;
  late int _monthWeek;
  late int _monthWeekday;
  late bool _hasEnd;
  late DateTime _endDate;
  late bool _endDateEdited;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _repeats = initial != null;
    _frequency = initial?.frequency ?? ReminderFrequency.daily;
    _interval = initial?.interval ?? 1;
    _weekdays = {
      ...?initial?.weekdays,
      if (initial == null) widget.start.weekday,
    };
    _monthlyPattern = initial?.dayOfMonth == null && initial?.monthWeek != null
        ? _MonthlyPattern.ordinalWeekday
        : _MonthlyPattern.dayOfMonth;
    _dayOfMonth = initial?.dayOfMonth ?? widget.start.day;
    _monthWeek = initial?.monthWeek ?? _weekOfMonth(widget.start);
    _monthWeekday = initial?.monthWeekday ?? widget.start.weekday;
    _hasEnd = initial?.endsAt != null || initial?.endsOnDate != null;
    _endDate = initial?.endsAt?.toLocal() ??
        (initial?.endsOnDate == null
            ? widget.start.add(const Duration(days: 30))
            : DateTime.parse(initial!.endsOnDate!));
    _endDateEdited = initial?.endsOnDate != null;
  }

  int get _maxInterval {
    switch (_frequency) {
      case ReminderFrequency.daily:
        return 30;
      case ReminderFrequency.weekly:
      case ReminderFrequency.monthly:
        return 12;
    }
  }

  String get _intervalUnit {
    switch (_frequency) {
      case ReminderFrequency.daily:
        return _interval == 1 ? 'day' : 'days';
      case ReminderFrequency.weekly:
        return _interval == 1 ? 'week' : 'weeks';
      case ReminderFrequency.monthly:
        return _interval == 1 ? 'month' : 'months';
    }
  }

  ReminderRecurrence? _buildRecurrence() {
    if (!_repeats) return null;
    return ReminderRecurrence(
      frequency: _frequency,
      interval: _interval,
      weekdays: _frequency == ReminderFrequency.weekly
          ? (_weekdays.toList()..sort())
          : const [],
      dayOfMonth: _frequency == ReminderFrequency.monthly &&
              _monthlyPattern == _MonthlyPattern.dayOfMonth
          ? _dayOfMonth
          : null,
      monthWeek: _frequency == ReminderFrequency.monthly &&
              _monthlyPattern == _MonthlyPattern.ordinalWeekday
          ? _monthWeek
          : null,
      monthWeekday: _frequency == ReminderFrequency.monthly &&
              _monthlyPattern == _MonthlyPattern.ordinalWeekday
          ? _monthWeekday
          : null,
      endsAt: _hasEnd && !_endDateEdited && widget.initial?.endsAt != null
          ? widget.initial!.endsAt
          : null,
      endsOnDate: _hasEnd && (_endDateEdited || widget.initial?.endsAt == null)
          ? _dateOnly(_endDate)
          : null,
    );
  }

  bool get _canSave {
    if (!_repeats) return true;
    if (_frequency == ReminderFrequency.weekly && _weekdays.isEmpty) {
      return false;
    }
    if (!_hasEnd) return true;
    final recurrence = _buildRecurrence();
    final first = alignStartToRecurrence(widget.start, recurrence);
    final firstDate = DateTime(first.year, first.month, first.day);
    final endDate = DateTime(_endDate.year, _endDate.month, _endDate.day);
    return !endDate.isBefore(firstDate);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      title: const Text('Repeat'),
      content: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recurring automation'),
                subtitle: const Text('Run this automation more than once'),
                value: _repeats,
                onChanged: (value) => setState(() => _repeats = value),
              ),
              if (_repeats) ...[
                const SizedBox(height: 8),
                DropdownButtonFormField<ReminderFrequency>(
                  initialValue: _frequency,
                  decoration: const InputDecoration(labelText: 'Frequency'),
                  items: ReminderFrequency.values
                      .map(
                        (value) => DropdownMenuItem(
                          value: value,
                          child: Text(_frequencyLabel(value)),
                        ),
                      )
                      .toList(growable: false),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      _frequency = value;
                      _interval = _interval.clamp(1, _maxInterval).toInt();
                    });
                  },
                ),
                const SizedBox(height: 16),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    const Text('Every'),
                    DropdownButton<int>(
                      value: _interval,
                      borderRadius: BorderRadius.circular(12),
                      items: List.generate(
                        _maxInterval,
                        (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1}'),
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _interval = value ?? 1),
                    ),
                    Text(_intervalUnit),
                  ],
                ),
                if (_frequency == ReminderFrequency.weekly) ...[
                  const SizedBox(height: 20),
                  Text(
                    'On these days',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(7, (index) {
                      final day = index + 1;
                      return FilterChip(
                        label: Text(reminderWeekdayName(day)),
                        selected: _weekdays.contains(day),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _weekdays.add(day);
                            } else {
                              _weekdays.remove(day);
                            }
                          });
                        },
                      );
                    }),
                  ),
                  if (_weekdays.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Choose at least one day.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                ],
                if (_frequency == ReminderFrequency.monthly) ...[
                  const SizedBox(height: 16),
                  Semantics(
                    selected: _monthlyPattern == _MonthlyPattern.dayOfMonth,
                    button: true,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _monthlyPattern == _MonthlyPattern.dayOfMonth
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                      ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 10,
                        children: [
                          const Text('On day'),
                          DropdownButton<int>(
                            value: _dayOfMonth,
                            items: List.generate(
                              31,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text('${index + 1}'),
                              ),
                            ),
                            onChanged: (value) => setState(() {
                              _dayOfMonth = value ?? 1;
                              _monthlyPattern = _MonthlyPattern.dayOfMonth;
                            }),
                          ),
                        ],
                      ),
                      onTap: () => setState(
                        () => _monthlyPattern = _MonthlyPattern.dayOfMonth,
                      ),
                    ),
                  ),
                  Semantics(
                    selected: _monthlyPattern == _MonthlyPattern.ordinalWeekday,
                    button: true,
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        _monthlyPattern == _MonthlyPattern.ordinalWeekday
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_off_rounded,
                      ),
                      title: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        children: [
                          const Text('On the'),
                          DropdownButton<int>(
                            value: _monthWeek,
                            items: const [
                              DropdownMenuItem(value: 1, child: Text('first')),
                              DropdownMenuItem(
                                value: 2,
                                child: Text('second'),
                              ),
                              DropdownMenuItem(value: 3, child: Text('third')),
                              DropdownMenuItem(
                                value: 4,
                                child: Text('fourth'),
                              ),
                              DropdownMenuItem(value: -1, child: Text('last')),
                            ],
                            onChanged: (value) => setState(() {
                              _monthWeek = value ?? 1;
                              _monthlyPattern = _MonthlyPattern.ordinalWeekday;
                            }),
                          ),
                          DropdownButton<int>(
                            value: _monthWeekday,
                            items: List.generate(
                              7,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(reminderWeekdayName(index + 1)),
                              ),
                            ),
                            onChanged: (value) => setState(() {
                              _monthWeekday = value ?? 1;
                              _monthlyPattern = _MonthlyPattern.ordinalWeekday;
                            }),
                          ),
                        ],
                      ),
                      onTap: () => setState(
                        () => _monthlyPattern = _MonthlyPattern.ordinalWeekday,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                const Divider(),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End on a date'),
                  subtitle: Text(
                    _hasEnd
                        ? DateFormat.yMMMd().format(_endDate)
                        : 'No end date',
                  ),
                  value: _hasEnd,
                  onChanged: (value) => setState(() => _hasEnd = value),
                ),
                if (_hasEnd)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.event_outlined),
                        title: Text(DateFormat.yMMMd().format(_endDate)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _pickEndDate,
                      ),
                      if (!_canSave)
                        Text(
                          'The end date must be after the first occurrence.',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                    ],
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canSave
              ? () => Navigator.pop(
                    context,
                    RecurrenceEditResult(_buildRecurrence()),
                  )
              : null,
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _pickEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _endDate.isBefore(widget.start) ? widget.start : _endDate,
      firstDate: DateTime(
        widget.start.year,
        widget.start.month,
        widget.start.day,
      ),
      lastDate: widget.start.add(const Duration(days: 3650)),
    );
    if (selected != null) {
      setState(() {
        _endDate = selected;
        _endDateEdited = true;
      });
    }
  }
}

String _frequencyLabel(ReminderFrequency frequency) {
  switch (frequency) {
    case ReminderFrequency.daily:
      return 'Daily';
    case ReminderFrequency.weekly:
      return 'Weekly';
    case ReminderFrequency.monthly:
      return 'Monthly';
  }
}

int _daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

int _weekOfMonth(DateTime value) {
  final nextWeek = value.day + 7;
  if (nextWeek > _daysInMonth(value.year, value.month)) return -1;
  return ((value.day - 1) ~/ 7 + 1).clamp(1, 4).toInt();
}

int _ordinalWeekdayDay(int year, int month, int week, int weekday) {
  if (week == -1) {
    final lastDay = _daysInMonth(year, month);
    final lastWeekday = DateTime(year, month, lastDay).weekday;
    return lastDay - ((lastWeekday - weekday + 7) % 7);
  }
  final firstWeekday = DateTime(year, month).weekday;
  return 1 + ((weekday - firstWeekday + 7) % 7) + (week - 1) * 7;
}

String _dateOnly(DateTime value) => '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';
