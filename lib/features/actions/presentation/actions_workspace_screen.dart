import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../core/agent/agent_action_contracts.dart';
import '../../../models/generated_automation.dart';
import '../../../models/reminder.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/push_notification_provider.dart';
import 'action_approval_card.dart';
import 'automation_edit_dialog.dart';
import 'generated_automation_edit_dialog.dart';

enum _ReminderMenuAction {
  edit,
  snooze,
  complete,
  pause,
  resume,
  skipNext,
  delete,
}

enum _GeneratedAutomationMenuAction {
  edit,
  runNow,
  pause,
  resume,
  delete,
}

class ActionsWorkspaceScreen extends StatefulWidget {
  const ActionsWorkspaceScreen({
    super.key,
    required this.onCreateInChat,
  });

  final VoidCallback onCreateInChat;

  @override
  State<ActionsWorkspaceScreen> createState() => _ActionsWorkspaceScreenState();
}

class _ActionsWorkspaceScreenState extends State<ActionsWorkspaceScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A reminder can complete while this screen is closed. Always reconcile
      // with the server when the user opens Automations instead of showing cache.
      context.read<ReminderProvider>().ensureInitialized(force: true);
      context.read<PushNotificationProvider>().ensureInitialized();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automations'),
        actions: [
          Consumer<ReminderProvider>(
            builder: (context, provider, _) => provider.isAvailable
                ? IconButton(
                    tooltip: 'Refresh',
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Consumer2<ReminderProvider, PushNotificationProvider>(
        builder: (context, provider, pushProvider, _) {
          if (provider.isLoading &&
              provider.reminders.isEmpty &&
              provider.automations.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!provider.isAvailable) {
            return _UnavailableState(onCreateInChat: widget.onCreateInChat);
          }

          final active = provider.reminders
              .where((item) => item.status == ReminderStatus.active)
              .toList(growable: false);
          final paused = provider.reminders
              .where((item) => item.status == ReminderStatus.paused)
              .toList(growable: false);
          final completed = provider.reminders
              .where((item) => item.status == ReminderStatus.completed)
              .toList(growable: false);
          final activeAutomations = provider.automations
              .where(
                (item) => item.status == GeneratedAutomationStatus.active,
              )
              .toList(growable: false);
          final pausedAutomations = provider.automations
              .where(
                (item) => item.status == GeneratedAutomationStatus.paused,
              )
              .toList(growable: false);
          final completedAutomations = provider.automations
              .where(
                (item) => item.status == GeneratedAutomationStatus.completed,
              )
              .toList(growable: false);

          final upcomingEntries = <_WorkspaceEntry>[
            ...active.map(_WorkspaceEntry.reminder),
            ...activeAutomations.map(_WorkspaceEntry.automation),
          ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          final pausedEntries = <_WorkspaceEntry>[
            ...paused.map(_WorkspaceEntry.reminder),
            ...pausedAutomations.map(_WorkspaceEntry.automation),
          ]..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
          final completedEntries = <_WorkspaceEntry>[
            ...completed.map(_WorkspaceEntry.reminder),
            ...completedAutomations.map(_WorkspaceEntry.automation),
          ]..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                if (pushProvider.isAvailable && !pushProvider.canDeliver)
                  _PushNotificationBanner(
                    provider: pushProvider,
                    onOpenSettings: openAppSettings,
                  ),
                if (provider.errorMessage != null)
                  _ErrorBanner(message: provider.errorMessage!),
                if (provider.pendingProposals.isNotEmpty) ...[
                  _SectionTitle(
                    title: 'Waiting for review',
                    count: provider.pendingProposals.length,
                  ),
                  ...provider.pendingProposals.map(
                    (proposal) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ActionApprovalCard(
                        proposal: proposal,
                        onApprove: () => _decide(
                          provider,
                          proposal,
                          AgentActionDecision.approved,
                        ),
                        onReject: () => _decide(
                          provider,
                          proposal,
                          AgentActionDecision.rejected,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (upcomingEntries.isEmpty &&
                    pausedEntries.isEmpty &&
                    completedEntries.isEmpty &&
                    provider.pendingProposals.isEmpty)
                  _EmptyActions(onCreateInChat: widget.onCreateInChat)
                else ...[
                  if (upcomingEntries.isNotEmpty) ...[
                    _SectionTitle(
                      title: 'Upcoming',
                      count: upcomingEntries.length,
                    ),
                    ...upcomingEntries.map(
                      (item) => _workspaceCard(provider, item),
                    ),
                  ],
                  if (pausedEntries.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionTitle(
                      title: 'Paused',
                      count: pausedEntries.length,
                    ),
                    ...pausedEntries.map(
                      (item) => _workspaceCard(provider, item),
                    ),
                  ],
                  if (completedEntries.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _SectionTitle(
                      title: 'Completed',
                      count: completedEntries.length,
                    ),
                    ...completedEntries.map(
                      (item) => _workspaceCard(provider, item),
                    ),
                  ],
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: widget.onCreateInChat,
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
                    label: const Text('Create another in Chat'),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _workspaceCard(ReminderProvider provider, _WorkspaceEntry entry) {
    final reminder = entry.reminder;
    return reminder != null
        ? _reminderCard(provider, reminder)
        : _automationCard(provider, entry.automation!);
  }

  Widget _automationCard(
    ReminderProvider provider,
    GeneratedAutomation automation,
  ) {
    final theme = Theme.of(context);
    final isCompleted =
        automation.status == GeneratedAutomationStatus.completed;
    final date = DateFormat.yMMMd().add_jm().format(
          automation.nextRunAt.toLocal(),
        );
    final scope = automation.scopeLabel;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : automation.status == GeneratedAutomationStatus.paused
                      ? Icons.pause_circle_outline_rounded
                      : automation.kind == GeneratedAutomationKind.newsBriefing
                          ? Icons.newspaper_rounded
                          : Icons.show_chart_rounded,
              color: isCompleted
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    automation.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isCompleted ? 'Last scheduled' : 'Next'} $date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${automation.schedule.compactLabel} · ${automation.timezone}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scope.isEmpty
                        ? automation.kindLabel
                        : '${automation.kindLabel} · $scope',
                  ),
                ],
              ),
            ),
            PopupMenuButton<_GeneratedAutomationMenuAction>(
              tooltip: 'Automation options',
              onSelected: (action) =>
                  _handleAutomationMenuAction(provider, automation, action),
              itemBuilder: (_) => _automationMenuItems(automation),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<_GeneratedAutomationMenuAction>> _automationMenuItems(
    GeneratedAutomation automation,
  ) {
    return [
      if (automation.status != GeneratedAutomationStatus.completed)
        const PopupMenuItem(
          value: _GeneratedAutomationMenuAction.edit,
          child: Text('Edit'),
        ),
      if (automation.status != GeneratedAutomationStatus.completed)
        const PopupMenuItem(
          value: _GeneratedAutomationMenuAction.runNow,
          child: Text('Run now'),
        ),
      if (automation.status == GeneratedAutomationStatus.active)
        const PopupMenuItem(
          value: _GeneratedAutomationMenuAction.pause,
          child: Text('Pause'),
        ),
      if (automation.status == GeneratedAutomationStatus.paused)
        const PopupMenuItem(
          value: _GeneratedAutomationMenuAction.resume,
          child: Text('Resume'),
        ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: _GeneratedAutomationMenuAction.delete,
        child: Text('Delete'),
      ),
    ];
  }

  Future<void> _handleAutomationMenuAction(
    ReminderProvider provider,
    GeneratedAutomation automation,
    _GeneratedAutomationMenuAction action,
  ) async {
    final base = {
      'automation_id': automation.id,
      'expected_version': automation.version,
    };
    late final String actionType;
    late final Map<String, dynamic> arguments;

    switch (action) {
      case _GeneratedAutomationMenuAction.edit:
        final edit = await showGeneratedAutomationEditDialog(
          context: context,
          automation: automation,
        );
        if (edit == null) return;
        actionType = 'automations_update';
        arguments = {
          ...base,
          'title': edit.title,
          'timezone': automation.timezone,
          'start_local': _localTimestamp(edit.start),
          'schedule': {
            'frequency': _frequencyName(edit.frequency),
            'interval': edit.interval,
            'weekdays': edit.weekdays,
            'ends_at': edit.frequency == GeneratedAutomationFrequency.once
                ? null
                : automation.schedule.endsAt?.toIso8601String(),
          },
          'config': edit.config,
          'source_policy': automation.sourcePolicy,
          'delivery_preferences': automation.deliveryPreferences,
        };
        break;
      case _GeneratedAutomationMenuAction.runNow:
        actionType = 'automations_run_now';
        arguments = base;
        break;
      case _GeneratedAutomationMenuAction.pause:
        actionType = 'automations_pause';
        arguments = base;
        break;
      case _GeneratedAutomationMenuAction.resume:
        actionType = 'automations_resume';
        arguments = base;
        break;
      case _GeneratedAutomationMenuAction.delete:
        actionType = 'automations_delete';
        arguments = base;
        break;
    }

    try {
      final proposal = await provider.proposeAutomation(
        actionType: actionType,
        arguments: arguments,
      );
      if (!mounted) return;
      await _showApprovalDialog(provider, proposal);
    } catch (error) {
      _showError(error.toString());
    }
  }

  String _frequencyName(GeneratedAutomationFrequency frequency) {
    return switch (frequency) {
      GeneratedAutomationFrequency.once => 'once',
      GeneratedAutomationFrequency.daily => 'daily',
      GeneratedAutomationFrequency.weekly => 'weekly',
      GeneratedAutomationFrequency.marketDays => 'market_days',
    };
  }

  Widget _reminderCard(ReminderProvider provider, Reminder reminder) {
    final theme = Theme.of(context);
    final isCompleted = reminder.status == ReminderStatus.completed;
    final date =
        DateFormat.yMMMd().add_jm().format(reminder.nextFireAt.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : reminder.status == ReminderStatus.paused
                      ? Icons.pause_circle_outline_rounded
                      : Icons.notifications_none_rounded,
              color: isCompleted
                  ? theme.colorScheme.outline
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration:
                          isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${isCompleted ? 'Last scheduled' : 'Next'} $date',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (reminder.isRecurring) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${reminder.recurrence!.compactLabel} · ${reminder.timezone}',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                  if (reminder.notes?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: 8),
                    Text(reminder.notes!),
                  ],
                  if (reminder.lastDeliveryNeedsAttention) ...[
                    const SizedBox(height: 8),
                    Text(
                      reminder.lastDeliveryStatus == 'no_devices'
                          ? 'Notification was not delivered because no device was registered.'
                          : 'The last notification could not be delivered.',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<_ReminderMenuAction>(
              tooltip: 'Automation options',
              onSelected: (action) =>
                  _handleMenuAction(provider, reminder, action),
              itemBuilder: (_) => _menuItems(reminder),
            ),
          ],
        ),
      ),
    );
  }

  List<PopupMenuEntry<_ReminderMenuAction>> _menuItems(Reminder reminder) {
    return [
      if (reminder.status != ReminderStatus.completed)
        const PopupMenuItem(
          value: _ReminderMenuAction.edit,
          child: Text('Edit'),
        ),
      if (reminder.status == ReminderStatus.active) ...[
        const PopupMenuItem(
          value: _ReminderMenuAction.snooze,
          child: Text('Snooze 10 minutes'),
        ),
        const PopupMenuItem(
          value: _ReminderMenuAction.pause,
          child: Text('Pause'),
        ),
        if (reminder.isRecurring)
          const PopupMenuItem(
            value: _ReminderMenuAction.skipNext,
            child: Text('Skip next'),
          ),
        const PopupMenuItem(
          value: _ReminderMenuAction.complete,
          child: Text('Complete'),
        ),
      ],
      if (reminder.status == ReminderStatus.paused)
        const PopupMenuItem(
          value: _ReminderMenuAction.resume,
          child: Text('Resume'),
        ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: _ReminderMenuAction.delete,
        child: Text('Delete'),
      ),
    ];
  }

  Future<void> _handleMenuAction(
    ReminderProvider provider,
    Reminder reminder,
    _ReminderMenuAction action,
  ) async {
    Map<String, dynamic>? arguments;
    String actionType;
    final base = {
      'reminder_id': reminder.id,
      'expected_version': reminder.version,
    };

    switch (action) {
      case _ReminderMenuAction.edit:
        final schedule = await _showEditDialog(reminder);
        if (schedule == null) return;
        actionType = 'reminders_update';
        arguments = {...base, ...schedule};
        break;
      case _ReminderMenuAction.snooze:
        actionType = 'reminders_snooze';
        arguments = {
          ...base,
          'snooze_minutes': 10,
        };
        break;
      case _ReminderMenuAction.complete:
        actionType = 'reminders_complete';
        arguments = base;
        break;
      case _ReminderMenuAction.pause:
        actionType = 'reminders_pause';
        arguments = base;
        break;
      case _ReminderMenuAction.resume:
        actionType = 'reminders_resume';
        arguments = base;
        break;
      case _ReminderMenuAction.skipNext:
        actionType = 'reminders_skip_next';
        arguments = base;
        break;
      case _ReminderMenuAction.delete:
        actionType = 'reminders_delete';
        arguments = base;
        break;
    }

    try {
      final proposal = await provider.propose(
        actionType: actionType,
        arguments: arguments,
      );
      if (!mounted) return;
      await _showApprovalDialog(provider, proposal);
    } catch (error) {
      _showError(error.toString());
    }
  }

  Future<Map<String, dynamic>?> _showEditDialog(Reminder reminder) async {
    final result = await showAutomationEditDialog(
      context: context,
      reminder: reminder,
    );
    if (result == null) return null;
    final schedule = reminder.scheduleArguments();
    schedule['title'] = result.title;
    schedule['notes'] = result.notes;
    schedule['start_local'] = _localTimestamp(result.start);
    schedule['recurrence'] = result.recurrence?.toJson();
    return schedule;
  }

  Future<void> _showApprovalDialog(
    ReminderProvider provider,
    ActionProposal proposal,
  ) {
    return showDialog<void>(
      context: context,
      builder: (_) => _ActionApprovalDialog(
        proposal: proposal,
        onDecision: (decision) => provider.decide(proposal, decision),
      ),
    );
  }

  Future<void> _decide(
    ReminderProvider provider,
    ActionProposal proposal,
    AgentActionDecision decision,
  ) async {
    try {
      final result = await provider.decide(proposal, decision);
      if (!mounted) return;
      if (decision == AgentActionDecision.approved &&
          proposal.actionType == 'reminders_create' &&
          result?.isSuccess == true) {
        await context.read<PushNotificationProvider>().enable();
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result?.displayMessage ?? 'Action dismissed.',
          ),
        ),
      );
    } catch (error) {
      _showError(error.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _localTimestamp(DateTime value) {
    String two(int number) => number.toString().padLeft(2, '0');
    return '${value.year.toString().padLeft(4, '0')}-'
        '${two(value.month)}-${two(value.day)}T${two(value.hour)}:'
        '${two(value.minute)}:00';
  }
}

class _ActionApprovalDialog extends StatefulWidget {
  const _ActionApprovalDialog({
    required this.proposal,
    required this.onDecision,
  });

  final ActionProposal proposal;
  final Future<ActionResult?> Function(AgentActionDecision) onDecision;

  @override
  State<_ActionApprovalDialog> createState() => _ActionApprovalDialogState();
}

class _ActionApprovalDialogState extends State<_ActionApprovalDialog> {
  bool _busy = false;

  Future<void> _decide(AgentActionDecision decision) async {
    setState(() => _busy = true);
    try {
      final result = await widget.onDecision(decision);
      if (decision == AgentActionDecision.approved &&
          widget.proposal.actionType == 'reminders_create' &&
          result?.isSuccess == true &&
          mounted) {
        await context.read<PushNotificationProvider>().enable();
      }
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result?.displayMessage ?? 'Action dismissed.')),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: ActionApprovalCard(
          proposal: widget.proposal,
          isBusy: _busy,
          onApprove: () => _decide(AgentActionDecision.approved),
          onReject: () => _decide(AgentActionDecision.rejected),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        '$title  $count',
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _EmptyActions extends StatelessWidget {
  const _EmptyActions({required this.onCreateInChat});

  final VoidCallback onCreateInChat;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96, horizontal: 24),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 18),
          Text(
            'No automations yet',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ask HowAI for a reminder or briefing, then review it before anything is activated.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: onCreateInChat,
            icon: const Icon(Icons.chat_bubble_outline_rounded),
            label: const Text('Create in Chat'),
          ),
        ],
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState({required this.onCreateInChat});

  final VoidCallback onCreateInChat;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              'Automations are in internal beta',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in with an enabled test account to create and manage automations.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: onCreateInChat,
              child: const Text('Back to Chat'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(message),
    );
  }
}

class _PushNotificationBanner extends StatelessWidget {
  const _PushNotificationBanner({
    required this.provider,
    required this.onOpenSettings,
  });

  final PushNotificationProvider provider;
  final Future<bool> Function() onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.notifications_active_outlined,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.isDenied
                      ? 'Notifications are off'
                      : 'Get automation alerts on this device',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  provider.errorMessage ??
                      'Allow HowAI to notify you when an automation is ready.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: provider.isLoading
                ? null
                : provider.isDenied
                    ? onOpenSettings
                    : provider.enable,
            child: provider.isLoading
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(provider.isDenied ? 'Settings' : 'Enable'),
          ),
        ],
      ),
    );
  }
}

class _WorkspaceEntry {
  const _WorkspaceEntry.reminder(Reminder value)
      : reminder = value,
        automation = null;

  const _WorkspaceEntry.automation(GeneratedAutomation value)
      : reminder = null,
        automation = value;

  final Reminder? reminder;
  final GeneratedAutomation? automation;

  DateTime get scheduledAt => reminder?.nextFireAt ?? automation!.nextRunAt;
}
