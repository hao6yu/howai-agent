import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../models/generated_automation.dart';

class GeneratedAutomationEditResult {
  const GeneratedAutomationEditResult({
    required this.title,
    required this.start,
    required this.frequency,
    required this.interval,
    required this.weekdays,
    required this.config,
  });

  final String title;
  final DateTime start;
  final GeneratedAutomationFrequency frequency;
  final int interval;
  final List<int> weekdays;
  final Map<String, dynamic> config;
}

Future<GeneratedAutomationEditResult?> showGeneratedAutomationEditDialog({
  required BuildContext context,
  required GeneratedAutomation automation,
}) {
  return showDialog<GeneratedAutomationEditResult>(
    context: context,
    builder: (_) => _GeneratedAutomationEditDialog(automation: automation),
  );
}

class _GeneratedAutomationEditDialog extends StatefulWidget {
  const _GeneratedAutomationEditDialog({required this.automation});

  final GeneratedAutomation automation;

  @override
  State<_GeneratedAutomationEditDialog> createState() =>
      _GeneratedAutomationEditDialogState();
}

class _GeneratedAutomationEditDialogState
    extends State<_GeneratedAutomationEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _interval;
  late final TextEditingController _topics;
  late final TextEditingController _itemCount;
  late final TextEditingController _focus;
  late DateTime _start;
  late GeneratedAutomationFrequency _frequency;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    final automation = widget.automation;
    _title = TextEditingController(text: automation.title);
    _interval = TextEditingController(
      text: automation.schedule.interval.toString(),
    );
    _topics = TextEditingController(
      text: (automation.config['topics'] as List? ?? const []).join(', '),
    );
    _itemCount = TextEditingController(
      text:
          ((automation.config['item_count'] as num?)?.toInt() ?? 5).toString(),
    );
    _focus = TextEditingController(
      text: automation.config['focus']?.toString() ?? '',
    );
    _start = automation.startLocal;
    _frequency = automation.schedule.frequency;
    _weekdays = automation.schedule.weekdays.toSet();
  }

  @override
  void dispose() {
    _title.dispose();
    _interval.dispose();
    _topics.dispose();
    _itemCount.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final maxHeight =
        (MediaQuery.sizeOf(context).height - 32).clamp(320.0, 760.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480, maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 8, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Edit automation',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Material(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        leading: const Icon(Icons.schedule_rounded),
                        title: Text(DateFormat.yMMMd().add_jm().format(_start)),
                        subtitle: Text(widget.automation.timezone),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _pickStart,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<GeneratedAutomationFrequency>(
                      initialValue: _frequency,
                      decoration: const InputDecoration(labelText: 'Repeat'),
                      items: const [
                        DropdownMenuItem(
                          value: GeneratedAutomationFrequency.once,
                          child: Text('Does not repeat'),
                        ),
                        DropdownMenuItem(
                          value: GeneratedAutomationFrequency.daily,
                          child: Text('Daily'),
                        ),
                        DropdownMenuItem(
                          value: GeneratedAutomationFrequency.weekly,
                          child: Text('Weekly'),
                        ),
                        DropdownMenuItem(
                          value: GeneratedAutomationFrequency.marketDays,
                          child: Text('Market days'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() {
                          _frequency = value;
                          if (value == GeneratedAutomationFrequency.once ||
                              value ==
                                  GeneratedAutomationFrequency.marketDays) {
                            _interval.text = '1';
                          }
                          if (value == GeneratedAutomationFrequency.weekly &&
                              _weekdays.isEmpty) {
                            _weekdays = {_start.weekday};
                          }
                        });
                      },
                    ),
                    if (_frequency == GeneratedAutomationFrequency.daily ||
                        _frequency == GeneratedAutomationFrequency.weekly) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _interval,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: InputDecoration(
                          labelText:
                              _frequency == GeneratedAutomationFrequency.daily
                                  ? 'Every number of days'
                                  : 'Every number of weeks',
                        ),
                      ),
                    ],
                    if (_frequency == GeneratedAutomationFrequency.weekly) ...[
                      const SizedBox(height: 14),
                      Text(
                        'Days',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(7, (index) {
                          final day = index + 1;
                          return FilterChip(
                            label: Text(
                              const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][index],
                            ),
                            selected: _weekdays.contains(day),
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _weekdays.add(day);
                                } else if (_weekdays.length > 1) {
                                  _weekdays.remove(day);
                                }
                              });
                            },
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 18),
                    TextField(
                      controller: _title,
                      maxLines: 2,
                      maxLength: 200,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (widget.automation.kind ==
                        GeneratedAutomationKind.newsBriefing) ...[
                      TextField(
                        controller: _topics,
                        minLines: 2,
                        maxLines: 3,
                        maxLength: 400,
                        decoration: const InputDecoration(
                          labelText: 'Topics',
                          hintText: 'Separate topics with commas',
                          alignLabelWithHint: true,
                          counterText: '',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _itemCount,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Number of stories (1–10)',
                        ),
                      ),
                    ] else
                      TextField(
                        controller: _focus,
                        minLines: 2,
                        maxLines: 3,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          labelText: 'Focus (optional)',
                          alignLabelWithHint: true,
                          counterText: '',
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Review'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initialDate = _start.isBefore(today) ? today : _start;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 3650)),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
    );
    if (time == null || !mounted) return;
    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final interval = int.tryParse(_interval.text) ?? 1;
    final maxInterval =
        _frequency == GeneratedAutomationFrequency.weekly ? 52 : 365;
    if (interval < 1 || interval > maxInterval) {
      _showError('Choose an interval from 1 to $maxInterval.');
      return;
    }

    final config = Map<String, dynamic>.from(widget.automation.config);
    if (widget.automation.kind == GeneratedAutomationKind.newsBriefing) {
      final topics = _topics.text
          .split(',')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
      final itemCount = int.tryParse(_itemCount.text);
      if (topics.isEmpty ||
          topics.length > 10 ||
          itemCount == null ||
          itemCount < 1 ||
          itemCount > 10) {
        _showError('Add 1–10 topics and choose 1–10 stories.');
        return;
      }
      config['topics'] = topics;
      config['item_count'] = itemCount;
    } else {
      final focus = _focus.text.trim();
      config['focus'] = focus.isEmpty ? null : focus;
    }

    Navigator.pop(
      context,
      GeneratedAutomationEditResult(
        title: title,
        start: _start,
        frequency: _frequency,
        interval: _frequency == GeneratedAutomationFrequency.once ||
                _frequency == GeneratedAutomationFrequency.marketDays
            ? 1
            : interval,
        weekdays: switch (_frequency) {
          GeneratedAutomationFrequency.weekly => _weekdays.toList()..sort(),
          GeneratedAutomationFrequency.marketDays => const [1, 2, 3, 4, 5],
          _ => const [],
        },
        config: config,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
