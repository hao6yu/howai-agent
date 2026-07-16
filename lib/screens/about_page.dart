import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:haogpt/generated/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/howai_theme.dart';
import '../widgets/custom_back_button.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _open(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.howaiColors;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(title: l10n.aboutHowAiTitle),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/icon/icon.png',
                    width: 64,
                    height: 64,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutHowdyAgent,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.aboutPocketCompanion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.aboutBio,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.textPrimary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Divider(color: colors.divider),
                      const SizedBox(height: 12),
                      Text.rich(
                        TextSpan(
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.textSecondary,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: l10n.aboutIdeasInvite),
                            TextSpan(
                              text: l10n.aboutLetsMakeBetter,
                              style: TextStyle(
                                color: colors.accent,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () =>
                                    _open(Uri.parse('mailto:support@haoyu.io')),
                            ),
                            TextSpan(text: l10n.aboutBotsEnjoyRide),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.aboutFriendlyDev,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _open(
                      Uri.parse('https://buymeacoffee.com/hao_yu'),
                    ),
                    icon: const Icon(Icons.coffee_outlined),
                    label: const Text('Buy Me a Coffee'),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.aboutBuiltWith,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
