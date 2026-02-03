import 'package:flutter/material.dart';
import '../services/migration_service.dart';

/// A minimal, non-intrusive widget to show migration status
/// Only shown if user explicitly wants to see it
class MigrationStatusWidget extends StatefulWidget {
  const MigrationStatusWidget({super.key});

  @override
  State<MigrationStatusWidget> createState() => _MigrationStatusWidgetState();
}

class _MigrationStatusWidgetState extends State<MigrationStatusWidget> {
  final MigrationService _migrationService = MigrationService();

  @override
  Widget build(BuildContext context) {
    if (!_migrationService.isMigrating) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.withOpacity(0.1),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Syncing your data...',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (_migrationService.migrationProgress > 0)
                  LinearProgressIndicator(
                    value: _migrationService.migrationProgress,
                    minHeight: 2,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Simple toast notification for migration (dismissible)
class MigrationToast {
  static void show(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static void showMigrationStarted(BuildContext context) {
    show(context, 'Syncing your data in background...');
  }

  static void showMigrationCompleted(BuildContext context) {
    show(context, 'Data synced successfully');
  }

  static void showMigrationError(BuildContext context) {
    show(context, 'Sync will retry later');
  }
}

/// Optional dialog to prompt user about migration (only shown on first sign-in)
class MigrationPromptDialog extends StatelessWidget {
  final VoidCallback onMigrate;
  final VoidCallback onSkip;

  const MigrationPromptDialog({
    super.key,
    required this.onMigrate,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sync Your Data?'),
      content: const Text(
        'Would you like to sync your existing conversations to the cloud? '
        'This will allow you to access them from any device.\n\n'
        'You can also skip this and sync later from Settings.',
      ),
      actions: [
        TextButton(
          onPressed: onSkip,
          child: const Text('Skip for now'),
        ),
        ElevatedButton(
          onPressed: onMigrate,
          child: const Text('Sync Now'),
        ),
      ],
    );
  }

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MigrationPromptDialog(
        onMigrate: () => Navigator.of(context).pop(true),
        onSkip: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }
}




