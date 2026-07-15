import 'package:flutter/material.dart';

import '../../workspace/presentation/workspace_empty_state.dart';

class ActionsWorkspaceScreen extends StatelessWidget {
  const ActionsWorkspaceScreen({
    super.key,
    required this.onCreateInChat,
  });

  final VoidCallback onCreateInChat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Actions'),
      ),
      body: WorkspaceEmptyState(
        icon: Icons.checklist_rounded,
        eyebrow: 'COMING IN THIS RELEASE',
        title: 'Your actions, in one place',
        description:
            'Reminders and recurring reminders will appear here after you review and approve them in chat or voice.',
        actionLabel: 'Create in Chat',
        onAction: onCreateInChat,
      ),
    );
  }
}
