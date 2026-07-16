import 'package:flutter/material.dart';

import '../../../core/agent/agent_action_contracts.dart';

class ActionApprovalCard extends StatelessWidget {
  const ActionApprovalCard({
    super.key,
    required this.proposal,
    required this.onApprove,
    required this.onReject,
    this.isBusy = false,
  });

  final ActionProposal proposal;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      container: true,
      label: 'Review proposed action: ${proposal.summary}',
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      proposal.actionType.startsWith('automations_')
                          ? Icons.auto_awesome_outlined
                          : Icons.notification_add_outlined,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Review action',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _actionLabel(proposal.actionType),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                proposal.summary,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
              if (proposal.actionType == 'automations_create') ...[
                const SizedBox(height: 12),
                _AutomationProposalDetails(arguments: proposal.arguments),
              ],
              if (proposal.warnings.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...proposal.warnings.map(
                  (warning) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: colors.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(child: Text(warning)),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isBusy ? null : onReject,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: isBusy ? null : onApprove,
                    style: proposal.actionType == 'reminders_delete'
                        ? FilledButton.styleFrom(
                            backgroundColor: colors.error,
                            foregroundColor: colors.onError,
                          )
                        : null,
                    icon: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.check_rounded),
                    label: Text(_approvalLabel(proposal.actionType)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _actionLabel(String actionType) {
    return actionType
        .replaceFirst('reminders_', '')
        .replaceFirst('automations_', '')
        .replaceAll('_', ' ')
        .toUpperCase();
  }

  String _approvalLabel(String actionType) {
    switch (actionType) {
      case 'reminders_create':
      case 'automations_create':
        return 'Create';
      case 'reminders_update':
        return 'Save changes';
      case 'reminders_resume':
        return 'Resume';
      case 'reminders_pause':
        return 'Pause';
      case 'reminders_snooze':
        return 'Snooze';
      case 'reminders_skip_next':
        return 'Skip';
      case 'reminders_complete':
        return 'Complete';
      case 'reminders_delete':
        return 'Delete';
      default:
        return 'Approve';
    }
  }
}

class _AutomationProposalDetails extends StatelessWidget {
  const _AutomationProposalDetails({required this.arguments});

  final Map<String, dynamic> arguments;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final config = arguments['config'] is Map
        ? Map<String, dynamic>.from(arguments['config'] as Map)
        : const <String, dynamic>{};
    final schedule = arguments['schedule_rule'] is Map
        ? Map<String, dynamic>.from(arguments['schedule_rule'] as Map)
        : const <String, dynamic>{};
    final kind = arguments['kind'] == 'market_briefing'
        ? 'Market briefing'
        : 'News briefing';
    final scope = arguments['kind'] == 'market_briefing'
        ? config['scope'] == 'watchlist'
            ? _join(config['symbols'])
            : 'U.S. market'
        : _join(config['topics']);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _detail(context, 'Type', kind),
          _detail(context, 'Topics / scope', scope),
          _detail(context, 'Schedule', _schedule(schedule)),
          _detail(context, 'Timezone', arguments['timezone']?.toString() ?? ''),
          _detail(
            context,
            'Delivery',
            (arguments['delivery_preferences'] as Map?)?['push'] == true
                ? 'Push notification + history'
                : 'Automations history',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _detail(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 7),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _join(dynamic value) => value is List
      ? value
          .map((item) => item.toString())
          .where((item) => item.isNotEmpty)
          .join(', ')
      : value?.toString() ?? '';

  static String _schedule(Map<String, dynamic> schedule) {
    switch (schedule['frequency']) {
      case 'market_days':
        return 'Market days';
      case 'weekly':
        final days = (schedule['weekdays'] as List? ?? const [])
            .whereType<num>()
            .map((day) => const [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ][day.toInt() - 1])
            .join(', ');
        return days.isEmpty ? 'Weekly' : 'Every $days';
      default:
        return 'Daily';
    }
  }
}
