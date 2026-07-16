import 'package:flutter/material.dart';

import '../generated/app_localizations.dart';

/// The single new-conversation affordance used across the chat shell.
///
/// Keeping the icon, tooltip, tap target, and visual treatment here prevents
/// the header and conversation drawer from drifting apart.
class NewConversationButton extends StatelessWidget {
  const NewConversationButton({
    super.key,
    required this.onPressed,
    this.iconSize = 22,
  });

  final VoidCallback onPressed;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const ValueKey<String>('new_conversation_button'),
      tooltip: AppLocalizations.of(context)!.newConversation,
      onPressed: onPressed,
      icon: Icon(
        Icons.edit_square,
        size: iconSize,
      ),
    );
  }
}
