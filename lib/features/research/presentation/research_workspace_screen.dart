import 'package:flutter/material.dart';

import '../../workspace/presentation/workspace_empty_state.dart';

class ResearchWorkspaceScreen extends StatelessWidget {
  const ResearchWorkspaceScreen({
    super.key,
    required this.onStartInChat,
  });

  final VoidCallback onStartInChat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Research'),
      ),
      body: WorkspaceEmptyState(
        icon: Icons.travel_explore_rounded,
        eyebrow: 'COMING IN THIS RELEASE',
        title: 'Research that keeps working',
        description:
            'Start a research project, leave the app, and return to a saved report with durable sources and progress.',
        actionLabel: 'Start in Chat',
        onAction: onStartInChat,
      ),
    );
  }
}
