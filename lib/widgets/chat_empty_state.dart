import 'package:flutter/material.dart';

import '../core/theme/howai_theme.dart';
import '../generated/app_localizations.dart';

class ChatEmptyState extends StatelessWidget {
  const ChatEmptyState({
    super.key,
    required this.onPromptSelected,
    required this.onAnalyzePhoto,
  });

  final ValueChanged<String> onPromptSelected;
  final VoidCallback onAnalyzePhoto;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.howaiColors;
    final actions = <_StarterActionData>[
      _StarterActionData(
        keyName: 'explain',
        icon: Icons.lightbulb_outline_rounded,
        label: l10n.featureConceptExplanation,
        onTap: () => onPromptSelected(l10n.inputExplainConcept),
      ),
      _StarterActionData(
        keyName: 'write',
        icon: Icons.edit_outlined,
        label: l10n.featureProfessionalWriting,
        onTap: () => onPromptSelected(l10n.inputProfessionalContent),
      ),
      _StarterActionData(
        keyName: 'brainstorm',
        icon: Icons.bubble_chart_outlined,
        label: l10n.featureIdeaGeneration,
        onTap: () => onPromptSelected(l10n.inputBrainstormIdeas),
      ),
      _StarterActionData(
        keyName: 'photo',
        icon: Icons.image_outlined,
        label: l10n.featurePhotoAnalysis,
        onTap: onAnalyzePhoto,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          key: const ValueKey<String>('chat_empty_state'),
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.hasBoundedHeight
                  ? (constraints.maxHeight - 48).clamp(0, double.infinity)
                  : 0,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: colors.accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      l10n.chatLandingTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.4,
                          ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      l10n.chatLandingSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    LayoutBuilder(
                      builder: (context, actionConstraints) {
                        const spacing = 10.0;
                        final useTwoColumns = actionConstraints.maxWidth >= 330;
                        final actionWidth = useTwoColumns
                            ? (actionConstraints.maxWidth - spacing) / 2
                            : actionConstraints.maxWidth;
                        return Wrap(
                          spacing: spacing,
                          runSpacing: spacing,
                          children: [
                            for (final action in actions)
                              SizedBox(
                                width: actionWidth,
                                child: _StarterAction(action: action),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StarterActionData {
  const _StarterActionData({
    required this.keyName,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String keyName;
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _StarterAction extends StatelessWidget {
  const _StarterAction({required this.action});

  final _StarterActionData action;

  @override
  Widget build(BuildContext context) {
    final colors = context.howaiColors;
    return Semantics(
      button: true,
      label: action.label,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          key: ValueKey<String>('chat_starter_${action.keyName}'),
          onTap: action.onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Icon(action.icon, size: 20, color: colors.textSecondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      action.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: colors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
