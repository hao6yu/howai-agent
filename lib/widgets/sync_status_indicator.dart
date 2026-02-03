import 'package:flutter/material.dart';
import '../services/sync_service.dart';

/// A minimal sync status indicator widget
/// Shows a small icon indicating sync status
class SyncStatusIndicator extends StatelessWidget {
  final SyncService syncService;
  final bool showLabel;

  const SyncStatusIndicator({
    super.key,
    required this.syncService,
    this.showLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!syncService.isAuthenticated) {
      return const SizedBox.shrink(); // Don't show if not authenticated
    }

    final status = syncService.syncStatus;
    final isSyncing = syncService.isSyncing;

    IconData icon;
    Color color;
    String label;

    if (isSyncing) {
      icon = Icons.sync;
      color = Colors.blue;
      label = 'Syncing...';
    } else if (status == 'error') {
      icon = Icons.sync_problem;
      color = Colors.orange;
      label = 'Sync issue';
    } else {
      icon = Icons.cloud_done;
      color = Colors.green;
      label = 'Synced';
    }

    return Tooltip(
      message: syncService.lastError ?? label,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }
}




