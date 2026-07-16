import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../models/reminder.dart';
import 'recurrence_editor.dart';

class AutomationEditResult {
  const AutomationEditResult({
    required this.title,
    required this.start,
    required this.recurrence,
    this.notes,
  });

  final String title;
  final String? notes;
  final DateTime start;
  final ReminderRecurrence? recurrence;
}

Future<AutomationEditResult?> showAutomationEditDialog({
  required BuildContext context,
  required Reminder reminder,
}) {
  return showDialog<AutomationEditResult>(
    context: context,
    builder: (_) => AutomationEditDialog(reminder: reminder),
  );
}

class AutomationEditDialog extends StatefulWidget {
  const AutomationEditDialog({super.key, required this.reminder});

  final Reminder reminder;

  @override
  State<AutomationEditDialog> createState() => _AutomationEditDialogState();
}

class _AutomationEditDialogState extends State<AutomationEditDialog> {
  late final TextEditingController _title;
  late final TextEditingController _notes;
  late DateTime _start;
  late ReminderRecurrence? _recurrence;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.reminder.title);
    _notes = TextEditingController(text: widget.reminder.notes ?? '');
    _start = widget.reminder.startLocal;
    _recurrence = widget.reminder.recurrence;
  }

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final availableHeight =
        (MediaQuery.sizeOf(context).height - 32).clamp(240.0, 720.0);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 460, maxHeight: availableHeight),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.schedule_rounded),
                          title: Text(
                            DateFormat.yMMMd().add_jm().format(_start),
                          ),
                          subtitle: Text(widget.reminder.timezone),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _pickStart,
                        ),
                        Divider(
                          height: 1,
                          indent: 52,
                          color: colors.outlineVariant,
                        ),
                        ListTile(
                          dense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          leading: const Icon(Icons.repeat_rounded),
                          title: const Text('Repeat'),
                          subtitle: Text(
                            _recurrence?.compactLabel ?? 'Does not repeat',
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: _editRecurrence,
                        ),
                      ],
                    ),
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
                    TextField(
                      controller: _title,
                      maxLines: 2,
                      maxLength: 200,
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        counterText: '',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notes,
                      minLines: 2,
                      maxLines: 4,
                      maxLength: 4000,
                      keyboardType: TextInputType.multiline,
                      textInputAction: TextInputAction.newline,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'Add details for this automation',
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
    if (time == null) return;
    setState(() {
      _start = alignStartToRecurrence(
        DateTime(date.year, date.month, date.day, time.hour, time.minute),
        _recurrence,
      );
    });
  }

  Future<void> _editRecurrence() async {
    final result = await showRecurrenceEditor(
      context: context,
      initial: _recurrence,
      start: _start,
    );
    if (result == null || !mounted) return;
    setState(() {
      _recurrence = result.recurrence;
      _start = alignStartToRecurrence(_start, _recurrence);
    });
  }

  void _submit() {
    final title = _title.text.trim();
    if (title.isEmpty) return;
    final notes = _notes.text.trim();
    Navigator.pop(
      context,
      AutomationEditResult(
        title: title,
        notes: notes.isEmpty ? null : notes,
        start: _start,
        recurrence: _recurrence,
      ),
    );
  }
}
